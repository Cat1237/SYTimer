

//
//  SYTimer.m
//  SYTimer
//
//  Created by ws 2018/12/5.
//  Copyright © 2018 ws. All rights reserved.
//

#import <SYTimer/SYTimerBase.h>
#import <SYTimer/SYBase.h>
#import <SYTimer/SYThread.h>
#import <SYTimer/SYTimerBase+Private.h>
#import <SYTimer/SYTimerBaseInternal.h>

@implementation SYTimerBase

@synthesize heapItem;

- (NSTimeInterval)nextFireInterval {
    return [self _nextFireInterval].seconds();
}

- (NSTimeInterval)repeatInterval {
    return [self _repeatInterval].seconds();
}

- (NSTimeInterval)nextUnalignedFireInterval {
    return [self _nextUnalignedFireInterval].seconds();
}

- (void)augmentFireInterval:(NSTimeInterval)delta {
    [self _augmentFireInterval:Seconds(delta)];
}
- (void)augmentRepeatInterval:(NSTimeInterval)delta {
    [self _augmentRepeatInterval:Seconds(delta)];
}

- (void)startOneShot:(NSTimeInterval)interval {
    [self _startOneShot:Seconds(interval)];
}
- (void)startRepeating:(NSTimeInterval)interval {
    [self _startRepeating:Seconds(interval)];
}

- (void)start:(NSTimeInterval)nextFireInterval repeatInterval:(NSTimeInterval)repeatInterval {
    [self _start:Seconds(nextFireInterval) repeatInterval:Seconds(repeatInterval)];
}

+ (void)fireTimersInNestedEventLoop {
    if (SYIsMainThread()) {
        [[SYTimerGlobalData.timerGlobalData threadTimersForRunLoopMode:kCFRunLoopDefaultMode] fireTimersInNestedEventLoop];
        [[SYTimerGlobalData.timerGlobalData threadTimersForRunLoopMode:kCFRunLoopCommonModes] fireTimersInNestedEventLoop];

    }
}

- (BOOL)isPaused {
    SYTimerAssertTrue([self canAccessThreadLocalDataForThread:_currentThread]);
    return self.isActive;
}
- (void)setPaused:(BOOL)paused {
    SYTimerAssertTrue([self canAccessThreadLocalDataForThread:_currentThread]);
    if (paused) {
        if (_runLoopTimer) {
            [_runLoopTimer stop];
        } else {
            [self setNextFireTime:MonotonicTime { }];
            SYTimerAssertTrue(!static_cast<bool>(self.nextFireTime));
            SYTimerAssertTrue(!self.heapItem.isInHeap);
        }
    } else {
        [self _startRepeating:_repeatInterval];
    }
}
- (void)stop
{
    SYTimerAssertTrue([self canAccessThreadLocalDataForThread:_currentThread]);
    _repeatInterval = 0_s;
    if (_runLoopTimer) {
        [_runLoopTimer stop];
    } else {

        [self setNextFireTime:MonotonicTime { }];
        
        SYTimerAssertTrue(!static_cast<bool>(self.nextFireTime));
        SYTimerAssertTrue(_repeatInterval == 0_s);
        SYTimerAssertTrue(!self.heapItem.isInHeap);
    }
}
- (BOOL)isActive
{
    if (_runLoopTimer) {
        return _runLoopTimer.isActive;
    } else {
        SYTimerAssertTrue([self canAccessThreadLocalDataForThread:_currentThread]);
        return static_cast<bool>(self.nextFireTime);
    }
}

- (instancetype)init
{
    return [self initWithRunLoop:nil runLoopMode:kCFRunLoopCommonModes];
}

- (instancetype)initWithRunLoop:(SYRunLoop * _Nullable)runLoop runLoopMode:(CFRunLoopMode)runLoopMode {
    self = [super init];
    if (self) {
        _runLoopMode = runLoopMode;
        _currentThread = [NSThread currentThread];
        if (!SYIsMainThread()) {
            _runLoopTimer = [[SYRunLoopTimer alloc] initWithTarget:self selector:@selector(fired) runLoop:runLoop runLoopMode:runLoopMode];
        }
    }
    return self;
}

- (void)didChangeAlignmentInterval {
    [self setNextFireTime:_unalignedNextFireTime];
}

- (void)dealloc
{
    SYTimerAssertTrue([self canAccessThreadLocalDataForThread:_currentThread]);
    if (_runLoopTimer) {
        [_runLoopTimer stop];
        _runLoopTimer = nil;
    } else {
        [self stop];
        SYHeapTimerItem *item = self.heapItem;
        SYTimerAssertTrue(!item.isInHeap);
        if (item) {
            [item clearItem];
        }
    }
    _unalignedNextFireTime = MonotonicTime::nan();
}

@end

@interface SYTimer()
{
    void (^_fireBlock)(SYTimer * _Nonnull);
    __weak id _target;
    SEL _selector;
}

@end

@implementation SYTimer

+ (instancetype)mainRunLoopTimerWithRunLoopMode:(CFRunLoopMode)runLoopMode block:(void(^)(SYTimer *))block {
    return [[self alloc] initWithRunLoop:[SYRunLoop main] runLoopMode:runLoopMode block:block];
}

- (instancetype)initWithTarget:(id)target selector:(SEL)selector runLoop:(SYRunLoop *)runLoop runLoopMode:(CFRunLoopMode)runLoopMode {
    self = [super initWithRunLoop:runLoop runLoopMode:runLoopMode];
    if (self) {
        _target = target;
        _selector = selector;
    }
    return self;
}
- (instancetype)initWithRunLoop:(SYRunLoop *)runLoop runLoopMode:(CFRunLoopMode)runLoopMode block:(void (^)(SYTimer * _Nonnull))block {
    self = [super initWithRunLoop:runLoop runLoopMode:runLoopMode];
    if (self) {
        _fireBlock = block;
    }
    return self;
}

- (void)fired {
    [super fired];
    if (_fireBlock) {
       _fireBlock(self);
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
      [_target performSelector:_selector withObject:self];
#pragma clang diagnostic pop
    }
}


@end

@interface SYDeferrableOneShotTimer ()
{
    Seconds _delay;
    BOOL _shouldRestartWhenTimerFires;
    __weak id _target;
    SEL _selector;
    void (^_fireBlock)(SYDeferrableOneShotTimer * _Nonnull);
}

@end

@implementation SYDeferrableOneShotTimer

- (instancetype)initWithTarget:(id)target
                      selector:(SEL)selector
                         delay:(NSTimeInterval)delay
                       runLoop:(SYRunLoop * _Nullable)runLoop
                   runLoopMode:(CFRunLoopMode)runLoopMode {
    return [self _initWithTarget:target selector:selector delay:Seconds(delay) runLoop:runLoop runLoopMode:runLoopMode];
}

- (instancetype)initWithRunLoop:(SYRunLoop * _Nullable)runLoop
                    runLoopMode:(CFRunLoopMode)runLoopMode
                          delay:(NSTimeInterval)delay
                          block:(void(^)(SYDeferrableOneShotTimer *))block {
    return [self _initWithRunLoop:runLoop runLoopMode:runLoopMode delay:Seconds(delay) block:block];
    
}

- (instancetype)_initWithTarget:(id)target
                      selector:(SEL)selector
                         delay:(Seconds)delay
                       runLoop:(SYRunLoop *)runLoop
                   runLoopMode:(CFRunLoopMode)runLoopMode {
    self = [super initWithRunLoop:runLoop runLoopMode:runLoopMode];
    if (self) {
        _target = target;
        _selector = selector;
        _delay = delay;
        _shouldRestartWhenTimerFires = NO;
    }
    return self;
}

- (instancetype)_initWithRunLoop:(SYRunLoop *)runLoop
                    runLoopMode:(CFRunLoopMode)runLoopMode
                          delay:(Seconds)delay
                          block:(void (^)(SYDeferrableOneShotTimer * _Nonnull))block {
    self = [super initWithRunLoop:runLoop runLoopMode:runLoopMode];
    if (self) {
        _fireBlock = block;
        _delay = delay;
        _shouldRestartWhenTimerFires = NO;
    }
    return self;
}

- (void)restart
{
    SYTimerAssertTrue([self canAccessThreadLocalDataForThread:_currentThread]);
    // Setting this boolean is much more efficient than calling startOneShot
    // again, which might result in rescheduling the system timer which
    // can be quite expensive.
    
    if (self.isActive) {
        _shouldRestartWhenTimerFires = true;
        return;
    }
    [self _startOneShot:_delay];
}
- (void)stop
{
    _shouldRestartWhenTimerFires = false;
    [super stop];
}
- (void)fired
{
    [super fired];
    if (_shouldRestartWhenTimerFires) {
        _shouldRestartWhenTimerFires = false;
        [self _startOneShot:_delay];
        return;
    }
    if (_fireBlock) {
           _fireBlock(self);
        } else {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
          [_target performSelector:_selector withObject:self];
    #pragma clang diagnostic pop
    }
}
@end



