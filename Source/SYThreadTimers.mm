
//
//  SYThreadTimers.m
//  SYCSSParser
//
//  Created by ws on 2018/12/6.
//  Copyright © 2018 ws. All rights reserved.
//

#import <SYTimer/SYThreadTimers.h>
#import <SYTimer/SYMainThreadSharedTimer.h>
#import <SYTimer/SYTimerBase+Private.h>
#import <SYTimer/SYThread.h>
#import <algorithm>
#import <SYTimer/SYMonotonicTime.h>
#import <SYTimer/SYTimerGlobalData.h>
#import <SYTimer/SYHeapTimerItem.h>
#import <SYTimer/SYTimerBase+Private.h>
#import <SYTimer/SYBase.h>


static const Seconds maxDurationOfFiringTimers { 50_ms };

@interface SYThreadTimers ()
{
    id<SYShareTimer> _sharedTimer;// External object, can be a run loop on a worker thread. Normally set/reset by worker thread
    BOOL _firingTimers;
    SYItemsHeap _timerHeap;
    MonotonicTime _pendingSharedTimerFireTime;
    CFRunLoopMode _mode;
}
@end
@implementation SYThreadTimers

- (instancetype)initWithRunLoopMode:(CFRunLoopMode)mode {
    self = [super init];
    if (self) {
        _mode = mode;
        if (SYIsMainThread()) {
            [self setSharedTimer:[SYMainThreadSharedTimer singletonWithRunLoopMode:mode]];
        }
    }
    return self;
}
- (instancetype)init
{
    return [self initWithRunLoopMode:kCFRunLoopCommonModes];
}

- (SYItemsHeap)timerHeap {
    if (!_timerHeap) {
        _timerHeap = [[SYHeap alloc] initWithHeapType:SYMinHeap usingComparator:^NSComparisonResult(SYHeapTimerItem * _Nonnull obj1, SYHeapTimerItem * _Nonnull obj2) {
            return [obj2 compare:obj1];
        }];
    }
    return _timerHeap;
}

- (void)setSharedTimer:(id<SYShareTimer>)sharedTimer
{
    if (_sharedTimer) {
        [_sharedTimer setFiredFunction:nil];
        [_sharedTimer stop];
        _pendingSharedTimerFireTime = MonotonicTime { };;
    }
    
    _sharedTimer = sharedTimer;
    
    if (sharedTimer) {
        CFRunLoopMode mode = _mode;
        [_sharedTimer setFiredFunction:^{
            [[SYTimerGlobalData.timerGlobalData threadTimersForRunLoopMode:mode] sharedTimerFiredInternal];
        }];
        [self updateSharedTimer];
    }
}
- (void)sharedTimerFiredInternal
{
    // Do a re-entrancy check.
    if (_firingTimers)
        return;
    _firingTimers = true;
    _pendingSharedTimerFireTime = MonotonicTime { };
    
    MonotonicTime fireTime = MonotonicTime::now();
    MonotonicTime timeToQuit = fireTime + maxDurationOfFiringTimers;
    while (!self.timerHeap.isEmpty) {
        SYHeapTimerItem *item = self.timerHeap.firstObject;
        SYTimerAssertTrue(item.hasItem);
        if (!item.hasItem) {
            [self heapDeleteNullMin];
            continue;
        }
        if (item.time > fireTime) {
            break;
        }
        SYTimer *timer = (SYTimer *)item.item;
        Seconds interval = Seconds(timer.repeatInterval);
        [timer setNextFireTime:(interval ? fireTime + interval : MonotonicTime { })];
        
        // Once the timer has been fired, it may be deleted, so do nothing else with it after this point.
        [timer fired];
        
        // Catch the case where the timer asked timers to fire in a nested event loop, or we are over time limit.
        if (!_firingTimers || timeToQuit < MonotonicTime::now())
            break;
    }
    
    _firingTimers = false;
    [self updateSharedTimer];
}

- (void)updateSharedTimer
{
    if (!_sharedTimer)
        return;
    while (!self.timerHeap.isEmpty && !self.timerHeap.firstObject.hasItem) {
        [self heapDeleteNullMin];
    }
    SYTimerAssertTrue(self.timerHeap.isEmpty|| self.timerHeap.firstObject.hasItem);

    if (_firingTimers || self.timerHeap.count == 0) {
        _pendingSharedTimerFireTime = MonotonicTime { };
        [_sharedTimer stop];
    } else {
        SYHeapTimerItem *firstItem = self.timerHeap.firstObject;
        MonotonicTime nextFireTime = firstItem.time;
        MonotonicTime currentMonotonicTime = MonotonicTime::now();
        if (_pendingSharedTimerFireTime) {
            // No need to restart the timer if both the pending fire time and the new fire time are in the past.
            if (_pendingSharedTimerFireTime <= currentMonotonicTime && nextFireTime <= currentMonotonicTime)
                return;
        }
        _pendingSharedTimerFireTime = nextFireTime;
        
        [_sharedTimer setFireInterval:std::max(nextFireTime - currentMonotonicTime, 0_s).seconds()];
    }
}
- (void)heapDeleteNullMin {
    SYTimerAssertTrue(!self.timerHeap.firstObject.hasItem);
    SYHeapTimerItem *item = self.timerHeap.firstObject;
    item.time = -MonotonicTime::infinity();
    [self.timerHeap removeRootObject];
}
- (void)fireTimersInNestedEventLoop
{
    // Reset the reentrancy guard so the timers can fire again.
    _firingTimers = false;
    
    if (_sharedTimer) {
        [_sharedTimer invalidate];
        _pendingSharedTimerFireTime = MonotonicTime { };
    }
    
    [self updateSharedTimer];
}

@end
