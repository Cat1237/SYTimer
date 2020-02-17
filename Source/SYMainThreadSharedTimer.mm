//
//  SYMainThreadSharedTimer.m
//  SYCSSParser
//
//  Created by ws on 2018/12/6.
//  Copyright © 2018 ws. All rights reserved.
//

#import <SYTimer/SYMainThreadSharedTimer.h>
#import <SYTimer/SYThread.h>
#import <SYTimer/SYBase.h>

static const CFTimeInterval kCFTimeIntervalDistantFuture = std::numeric_limits<CFTimeInterval>::max();

static void timerFired(CFRunLoopTimerRef t, void* context)
{
    @autoreleasepool {
        SYMainThreadSharedTimer *timer = (__bridge SYMainThreadSharedTimer *)context;
        [timer fired];
    }
}

static void restartSharedTimer()
{
    [[SYMainThreadSharedTimer singletonWithRunLoopMode:kCFRunLoopDefaultMode] stop];
    [[SYMainThreadSharedTimer singletonWithRunLoopMode:kCFRunLoopDefaultMode] fired];
    [[SYMainThreadSharedTimer singletonWithRunLoopMode:kCFRunLoopCommonModes] stop];
    [[SYMainThreadSharedTimer singletonWithRunLoopMode:kCFRunLoopCommonModes] fired];
}
static void applicationDidBecomeActive(CFNotificationCenterRef n, void* v, CFStringRef s, const void* vc, CFDictionaryRef d)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        restartSharedTimer();
    });
}

static void setupPowerObserver()
{
    static bool registeredForApplicationNotification = false;
    if (!registeredForApplicationNotification) {
        registeredForApplicationNotification = true;
        CFNotificationCenterRef notificationCenter = CFNotificationCenterGetLocalCenter();
        CFNotificationCenterAddObserver(notificationCenter, Nil, applicationDidBecomeActive, CFSTR("UIApplicationDidBecomeActiveNotification"), Nil, CFNotificationSuspensionBehaviorCoalesce);
    }
}
@interface SYMainThreadSharedTimer ()
{
    void(^_firedFunction)(void);
    CFRunLoopMode _mode;
    CFRunLoopTimerRef sharedTimer;
}
@end

@implementation SYMainThreadSharedTimer

- (instancetype)initWithRunLoopMode:(CFRunLoopMode)mode {
    self = [super init];
    if (self) {
        _mode = mode;
    }
    return self;
}
+ (instancetype)singletonWithRunLoopMode:(CFRunLoopMode)mode
{
    static dispatch_once_t onceToken;
    static SYMainThreadSharedTimer *timerDefault_;
    static SYMainThreadSharedTimer *timerCommon_;
    dispatch_once(&onceToken, ^{
        timerDefault_ = [[self alloc] initWithRunLoopMode:kCFRunLoopDefaultMode];
        timerCommon_ = [[self alloc] initWithRunLoopMode:kCFRunLoopCommonModes];
    });
    if (mode == kCFRunLoopCommonModes) {
        return timerCommon_;
    }
    if (mode == kCFRunLoopDefaultMode) {
        return timerDefault_;
    }
    return timerCommon_;
}
- (void)invalidate {
    if (!sharedTimer)
        return;
    
    CFRunLoopTimerInvalidate(sharedTimer);
    CFRelease(sharedTimer);
    sharedTimer = nil;
}
- (void)setFireInterval:(NSTimeInterval)interval {
    SYTimerAssertTrue(_firedFunction);
    SYTimerAssertTrue(SYIsMainThread());
    CFAbsoluteTime fireDate = CFAbsoluteTimeGetCurrent() + interval;
    if (!sharedTimer) {
        CFRunLoopTimerContext context = { 0, (__bridge void *)self, 0, 0, 0 };
        sharedTimer = CFRunLoopTimerCreate(nil, fireDate, kCFTimeIntervalDistantFuture, 0, 0, timerFired, &context);
        CFRunLoopAddTimer(CFRunLoopGetMain(), sharedTimer, _mode);
        
        setupPowerObserver();
        return;
    }
 
    CFRunLoopTimerSetNextFireDate(sharedTimer, fireDate);

}

- (void)setFiredFunction:(nullable void (^)(void))function {
    _firedFunction = function;
    
}
- (void)fired
{
    SYTimerAssertTrue(_firedFunction);
    _firedFunction();
}
- (void)stop {
    if (!sharedTimer)
        return;
    
    CFRunLoopTimerSetNextFireDate(sharedTimer, kCFTimeIntervalDistantFuture);
}
@end


