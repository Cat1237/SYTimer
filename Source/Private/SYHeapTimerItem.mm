//
//  SYHeapTimerItem.m
//  SYTimer
//
//  Created by ws on 2020/2/9.
//  Copyright © 2020 ws. All rights reserved.
//

#import <SYTimer/SYHeapTimerItem.h>
#import <SYTimer/SYThreadTimers.h>
#import <SYTimer/SYTimerBase.h>
#import <SYTimer/SYTimerGlobalData.h>
#import <SYTimer/SYTimerBase+SYHeapItem.h>
#import <SYTimer/SYBase.h>

@interface SYHeapTimerItem()
{
    SYThreadTimers *_threadTimers;
}

@end

@implementation SYHeapTimerItem

- (SYTimerBase *)timerItem {
    return (SYTimerBase *)[self item];
}
- (SYItemsHeap)itemHeap {
    return _threadTimers.timerHeap;
}
- (instancetype)initWithTimer:(SYTimerBase *)timer time:(MonotonicTime)time insertionOrder:(NSUInteger)insertionOrder
{

    self = [super initWithItem:timer];
    if (self) {
        _threadTimers = [SYTimerGlobalData.timerGlobalData threadTimersForRunLoopMode:timer.runLoopMode];
        _time = time;
        _insertionOrder = insertionOrder;
    }
    return self;
}
- (NSComparisonResult)compare:(__kindof SYHeapItem *)item {
    if ([item isKindOfClass:[SYHeapTimerItem class]]) {
        SYHeapTimerItem *other = item;
        return [self compare:other.time order:other.insertionOrder];
    }
    return NSOrderedSame;
}
- (NSComparisonResult)compare:(MonotonicTime)time order:(NSUInteger)order {
    // The comparisons below are "backwards" because the heap puts the largest
    // element first and we want the lowest time to be the first one in the heap.
    if (time != self.time) {
       return time < self.time ? NSOrderedAscending : NSOrderedDescending;
    }
        
    // We need to look at the difference of the insertion orders instead of comparing the two
    // outright in case of overflow.
    NSUInteger difference = self.insertionOrder - order;
    return difference < std::numeric_limits<NSUInteger>::max() /2 ? NSOrderedAscending : NSOrderedDescending;
}
- (void)checkHeapIndex {
#if DEBUG
    SYTimerAssertTrue([self.itemHeap isEqualToHeap:[SYTimerGlobalData timerGlobalTimerHeapForRunLoopMode:self.timerItem.runLoopMode]]);

    [super checkHeapIndex];
#endif
}
- (void)checkConsistency {
    SYTimerAssertTrue(self.isInHeap == self.timerItem.isActive);
    [super checkConsistency];
}
- (void)heapDecreaseKey {
    SYTimerAssertTrue(self.timerItem.isActive);
    [super heapDecreaseKey];
}
- (void)heapDelete {
    SYTimerAssertTrue(!self.timerItem.isActive);
    [super heapDelete];
}

- (void)heapIncreaseKey {
    SYTimerAssertTrue(self.timerItem.isActive);
    [super heapIncreaseKey];
}

- (BOOL)hasValidHeapPosition {
    SYTimerAssertTrue(self.timerItem.isActive);
    return [super hasValidHeapPosition];
}
@end


