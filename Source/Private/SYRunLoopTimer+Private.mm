//
//  SYRunLoopTimer+Private.m
//  SYTimer
//
//  Created by ws on 2020/2/16.
//  Copyright © 2020 Tino. All rights reserved.
//

#import <SYTimer/SYRunLoopTimer+Private.h>
#import <algorithm>
#import <SYTimer/SYRunLoopTimerInternal.h>

@implementation SYRunLoopTimerBase (Private)
- (void)_startOneShot:(Seconds)interval
{
    [self _startInterval:interval repeat:0_s];
}
- (void)_startRepeating:(Seconds)repeatInterval
{
    [self _startInterval:repeatInterval repeat:repeatInterval];
}
- (void)_startInterval:(Seconds)nextFireInterval repeat:(Seconds)repeatInterval
{
    [self _start:nextFireInterval repeat:repeatInterval];
}
static void timerFired(CFRunLoopTimerRef, void *context)
{
    @autoreleasepool {
        SYRunLoopTimerBase* timer = (__bridge SYRunLoopTimerBase *)context;
        [timer fired];
    }
}

- (void)_start:(Seconds)nextFireInterval repeat:(Seconds)repeatInterval
{
    BOOL newRepeatInterval = NO;
    _nextFireInterval = nextFireInterval;
    if (_repeatInterval != repeatInterval) {
        _repeatInterval = repeatInterval;
        newRepeatInterval = YES;
    }
    if (newRepeatInterval && _timer) {
        [self invalidate];
    }
    CFAbsoluteTime fireDate = CFAbsoluteTimeGetCurrent() + nextFireInterval.seconds();
    if (!_timer) {
        CFRunLoopTimerContext context = { 0, (__bridge void *)self, 0, 0, 0 };
        _timer = CFRunLoopTimerCreate(0, fireDate, repeatInterval.seconds(), 0, 0, timerFired, &context);

       CFRunLoopAddTimer(_runLoop.getCFRunLoop, _timer, _runLoopMode);
       return;
    }
    CFRunLoopTimerSetNextFireDate(_timer, fireDate);
}
- (Seconds)_secondsUntilFire
{
    if (self.isActive)
        return std::max<Seconds>(Seconds { CFRunLoopTimerGetNextFireDate(_timer) - CFAbsoluteTimeGetCurrent() }, 0_s);
    return 0_s;
}


- (void)fired
{
    
}
- (void)invalidate {
    if (!_timer)
        return;
    
    CFRunLoopTimerInvalidate(_timer);
    CFRelease(_timer);
    _timer = nil;
}

@end
