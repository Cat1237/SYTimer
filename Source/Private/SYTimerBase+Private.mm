//
//  SYTimerBase+Private.mm
//  SYTimer
//
//  Created by ws on 2020/2/16.
//  Copyright © 2020 Tino. All rights reserved.
//

#import <SYTimer/SYTimerBase+Private.h>
#import <SYTimer/SYTimerBaseInternal.h>
#import <SYTimer/SYRunLoopTimer+Private.h>
#import <SYTimer/SYBase.h>

@implementation SYTimerBase (Private)


- (void)_augmentFireInterval:(Seconds)delta {
    [self setNextFireTime:self.nextFireTime + delta];
}

- (void)_augmentRepeatInterval:(Seconds)delta {
    [self _augmentFireInterval:delta];
    _repeatInterval += delta;
}
- (void)_startRepeating:(Seconds)repeatInterval
{
    [self _start:repeatInterval repeatInterval:repeatInterval];
}
- (void)_start:(Seconds)nextFireInterval repeatInterval:(Seconds)repeatInterval
{
    SYTimerAssertTrue([self canAccessThreadLocalDataForThread:_currentThread]);
    _repeatInterval = repeatInterval;
    if (_runLoopTimer) {
        [_runLoopTimer _startInterval:nextFireInterval repeat:repeatInterval];
    } else {
        [self setNextFireTime:MonotonicTime::now() + nextFireInterval];
    }
}

- (void)_startOneShot:(Seconds)interval
{
    [self _start:interval repeatInterval:0_s];
}

- (MonotonicTime)alignedFireTime:(MonotonicTime)newTime {
    return MonotonicTime::nan();
}

- (MonotonicTime)nextFireTime {
    MonotonicTime time = MonotonicTime {};
    if (_runLoopTimer) {
        time = MonotonicTime::now() + _runLoopTimer._secondsUntilFire;
    } else {
        SYHeapTimerItem *item = self.heapItem;
        time = item.time;
    }
    return time;
}
- (void)setNextFireTime:(MonotonicTime)newTime
{
    SYTimerAssertTrue([self canAccessThreadLocalDataForThread:_currentThread]);
    if (_unalignedNextFireTime != newTime)
        _unalignedNextFireTime = newTime;
    SYTimerAssertTrue(!std::isnan(_unalignedNextFireTime));
    if (_unalignedNextFireTime != newTime) {
        SYTimerAssertTrue(!std::isnan(newTime));
        _unalignedNextFireTime = newTime;
    }
    
    // Keep heap valid while changing the next-fire time.
    MonotonicTime oldTime = self.nextFireTime;
    // Don't realign zero-delay timers.
    if (newTime) {
       MonotonicTime newAlignedTime = [self alignedFireTime:newTime];
       if (!std::isnan(newAlignedTime)) {
           newTime = newAlignedTime;
       }
    }
    if (oldTime != newTime) {
        // FIXME: This should be part of ThreadTimers, or another per-thread structure.
        static std::atomic<NSUInteger> currentHeapInsertionOrder;
        auto newOrder = currentHeapInsertionOrder++;
        if (!self.heapItem) {
            self.heapItem = [[SYHeapTimerItem alloc] initWithTimer:self time:newTime insertionOrder:0];
        }
        SYHeapTimerItem *heapItem = self.heapItem;
        heapItem.time = newTime;
        heapItem.insertionOrder = newOrder;
        BOOL wasFirstTimerInHeap = heapItem.isFirstInHeap;
        [self updateHeapIfNeeded:oldTime];

        BOOL isFirstTimerInHeap = heapItem.isFirstInHeap;

        if (wasFirstTimerInHeap || isFirstTimerInHeap) {
            [[SYTimerGlobalData.timerGlobalData threadTimersForRunLoopMode:_runLoopMode] updateSharedTimer];
        }
    }
    [self.heapItem checkConsistency];
}

- (void)updateHeapIfNeeded:(MonotonicTime)oldTime
{
    SYHeapTimerItem *heapItem = self.heapItem;
    MonotonicTime fireTime = self.nextFireTime;
    if (fireTime && heapItem.hasValidHeapPosition)
        return;
    if (!oldTime)
        [heapItem heapInsert];
    else if (!fireTime)
    {
        [heapItem heapDelete];
    }
    else if (fireTime < oldTime)
        [heapItem heapIncreaseKey];
    else
        [heapItem heapDecreaseKey];
    SYTimerAssertTrue(!heapItem.isInHeap || heapItem.hasValidHeapPosition);

}


- (Seconds)_nextUnalignedFireInterval {
    SYTimerAssertTrue(self.isActive);
    auto result = std::max(_unalignedNextFireTime - MonotonicTime::now(), 0_s);
    SYTimerAssertTrue(std::isfinite(result));
    return result;
}


- (Seconds)_nextFireInterval
{
    SYTimerAssertTrue(self.isActive);
    if (!_runLoopTimer) {
        SYTimerAssertTrue(self.heapItem);
    }
    MonotonicTime current = MonotonicTime::now();
    MonotonicTime fireTime = self.nextFireTime;
    if (fireTime < current)
        return 0_s;
    return fireTime - current;
}
- (Seconds)_repeatInterval
{
    return _repeatInterval;
}

- (CFRunLoopMode)runLoopMode {
    return _runLoopMode;
}
- (BOOL)canAccessThreadLocalDataForThread:(NSThread *)t
{
    return t == [NSThread currentThread];
}
- (void)fired
{
    SYTimerAssertTrue([self canAccessThreadLocalDataForThread:_currentThread]);
}
@end
