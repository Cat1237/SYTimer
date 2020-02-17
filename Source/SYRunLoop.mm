//
//  SYRunLoop.m
//  SYTimer
//
//  Created by ws on 2019/1/23.
//  Copyright © 2019 ws. All rights reserved.
//

#import <SYTimer/SYRunLoop.h>
#import <mutex>
#import <deque>
#import <SYTimer/SYThreadSpecificVariable.h>
#import <SYTimer/SYRunLoopTimer+Private.h>
#import <SYTimer/SYRunLoopTimerInternal.h>
#import <SYTimer/SYBase.h>

@interface SYRunLoopHolder : NSObject

- (SYRunLoop *)runLoop;
@end

@interface SYRunLoopHolder() {
    SYRunLoop *_runLoop;
}


@end

@implementation SYRunLoopHolder

- (instancetype)init
{
    self = [super init];
    if (self) {
        _runLoop = [SYRunLoop new];
    }
    return self;
}
- (SYRunLoop *)runLoop {
    return _runLoop;
}


@end


@interface SYRunLoop ()
{
    @package
    std::mutex  _functionQueueLock;
    std::deque<void(^)(void)> _functionQueue;
    CFRunLoopSourceRef _runLoopSource;
    CFRunLoopRef _runLoop;
}
- (instancetype)initWithRunLoop:(CFRunLoopRef)runLoop;
@end

static SYRunLoop *s_mainRunLoop = [[SYRunLoop alloc] initWithRunLoop: CFRunLoopGetMain()];

@implementation SYRunLoop

- (instancetype)init
{
    return [self initWithRunLoop:nil];
}

- (instancetype)initWithRunLoop:(CFRunLoopRef)runLoop
{   
    self = [super init];
    if (self) {
        _runLoop = runLoop ? runLoop : CFRunLoopGetCurrent();
        
        CFRunLoopSourceContext context = { 0, (__bridge void *)self, 0, 0, 0, 0, 0, 0, 0, performWork };
        _runLoopSource = CFRunLoopSourceCreate(kCFAllocatorDefault, 0, &context);
        CFRunLoopAddSource(_runLoop, _runLoopSource, kCFRunLoopCommonModes);
    }
    return self;
}

+ (instancetype)current
{
    static SYThreadSpecificVariable<SYRunLoopHolder *> *runLoopHolder;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        runLoopHolder = [[SYThreadSpecificVariable alloc] initWithValue:^id _Nullable{
            return [SYRunLoopHolder new];
        }];
    });
    return runLoopHolder.currentValue.runLoop;
}
+ (instancetype)main
{
    SYTimerAssertTrue(s_mainRunLoop);
    return s_mainRunLoop;

}
+ (BOOL)isMain
{
    SYTimerAssertTrue(s_mainRunLoop);
    return s_mainRunLoop == [SYRunLoop current];
}

- (CFRunLoopRef)getCFRunLoop {
    return _runLoop;
}

- (void)dispatch:(void(^)(void))function
{
    {
        std::lock_guard<std::mutex> locker(_functionQueueLock);
        _functionQueue.push_back(function);
    }
    
    [self wakeUp];
}
+ (void)run
{
    @autoreleasepool {
        CFRunLoopRun();
    }
}
- (void)stop
{
    SYTimerAssertTrue(_runLoop == CFRunLoopGetCurrent());
    CFRunLoopStop(_runLoop);
}
- (void)wakeUp
{
    CFRunLoopSourceSignal(_runLoopSource);
    CFRunLoopWakeUp(_runLoop);
}
- (void)runForDuration:(NSTimeInterval)duration {
    [self _runForDuration:Seconds(duration)];
}
- (void)_runForDuration:(Seconds)duration
{
    CFRunLoopRunInMode(kCFRunLoopDefaultMode, duration.seconds(), true);
}
static void performWork(void *context)
{
    @autoreleasepool {
        SYRunLoop *l = (__bridge SYRunLoop *)context;
        [l performWork];
    }
}
- (void)performWork
{
    // It is important to handle the functions in the queue one at a time because while inside one of these
    // functions we might re-enter performWork and we need to be able to pick up where we left off.
    
    // One possible scenario when handling the function queue is as follows:
    // - performWork is invoked with 1 function on the queue
    // - Handling that function results in 1 more function being enqueued
    // - Handling that one results in yet another being enqueued
    // - And so on
    //
    // In this situation one invocation of performWork never returns so all other event sources are blocked.
    // By only handling up to the number of functions that were in the queue when performWork is called
    // we guarantee to occasionally return from the run loop so other event sources will be allowed to spin.
    
    size_t functionsToHandle = 0;
    {
        void(^function)(void);
        {
            std::lock_guard<std::mutex> locker(_functionQueueLock);
            functionsToHandle = _functionQueue.size();
            
            if (_functionQueue.empty())
                return;
            
            function = _functionQueue.front();
        }
        
        function();
    }
    
    for (size_t functionsHandled = 1; functionsHandled < functionsToHandle; ++functionsHandled) {
        void(^function)(void);
        {
            std::lock_guard<std::mutex> locker(_functionQueueLock);

            // Even if we start off with N functions to handle and we've only handled less than N functions, the queue
            // still might be empty because those functions might have been handled in an inner RunLoop::performWork().
            // In that case we should bail here.
            if (_functionQueue.empty())
                break;
            
            function = _functionQueue.front();
        }
        
        function();
    }
}

- (void)dealloc
{
    CFRunLoopSourceInvalidate(_runLoopSource);
}
@end


@implementation SYRunLoopTimerBase

- (instancetype)init
{
    return [self initWithRunLoop:[SYRunLoop current] runLoopMode:kCFRunLoopCommonModes];
}

- (instancetype)initWithRunLoop:(SYRunLoop *)runLoop runLoopMode:(CFRunLoopMode)runLoopMode
{
    self = [super init];
    if (self) {
        _runLoop = runLoop ?: [SYRunLoop current];
        _runLoopMode = runLoopMode;
    }
    return self;
}

- (void)startOneShot:(NSTimeInterval)interval {
    return [self _startOneShot:Seconds(interval)];
}
- (void)startRepeating:(NSTimeInterval)repeatInterval {
    return [self _startOneShot:Seconds(repeatInterval)];
}
- (void)startInterval:(NSTimeInterval)nextFireInterval repeat:(NSTimeInterval)repeatInterval {
    return [self _startInterval:Seconds(nextFireInterval) repeat:Seconds(repeatInterval)];
}
- (NSTimeInterval)secondsUntilFire {
    return [self _secondsUntilFire].seconds();
}


- (void)restartTimer {
    if (!_timer)
        return;
    [self _startInterval:_nextFireInterval repeat:_repeatInterval];
}
- (void)stop {
    if (!_timer)
        return;
    
    CFRunLoopTimerSetNextFireDate(_timer, std::numeric_limits<CFTimeInterval>::max());
}


- (BOOL)isActive
{
    return _timer && CFRunLoopTimerIsValid(_timer);
}



- (void)dealloc {
    [self invalidate];
}
@end

@interface SYRunLoopTimer ()
{
    __weak id _object;
    SEL _function;
}

@end

@implementation SYRunLoopTimer


- (instancetype)initWithTarget:(id)target selector:(SEL)selector
{
    return [self initWithTarget:target selector:selector runLoop:nil runLoopMode:kCFRunLoopCommonModes];
}

- (instancetype)initWithTarget:(id)target selector:(SEL)selector runLoop:(SYRunLoop *)runLoop runLoopMode: (CFRunLoopMode)runLoopMode {
    self = [super initWithRunLoop:runLoop runLoopMode:runLoopMode];
    if (self) {
        _object = target;
        _function = selector;
    }
    return self;
}

- (void)fired
{
    [_object performSelector:_function withObject:nil afterDelay:0];
}
@end
