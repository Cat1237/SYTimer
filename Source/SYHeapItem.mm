//
//  SYHeapItem.m
//  SYTimer
//
//  Created by ws on 2020/2/9.
//  Copyright © 2020 ws. All rights reserved.
//

#import <SYTimer/SYHeapItem.h>
#import <SYTimer/SYTimerBase.h>
#import <SYTimer/SYThreadTimers.h>
#import <SYTimer/SYTimerGlobalData.h>
#import <SYTimer/SYBase.h>

@interface SYHeapItem()
{
    __weak id<SYHeapItemProtocol> _item;
    SYItemsHeap _tempHeap;
}
@end

@implementation SYHeapItem
- (instancetype)initWithItem:(id)item {
    self = [super init];
    if (self) {
        _item = item;
    }
    return self;
}
- (NSComparisonResult)compare:(__kindof SYHeapItem *)item {
    return NSOrderedSame;
}
- (BOOL)hasItem {
    return _item != nil;
}
- (id<SYHeapItemProtocol>)item {
    return _item;
}
- (SYItemsHeap)itemHeap {
    if (!_tempHeap) {
        _tempHeap = [[SYHeap alloc] initWithHeapType:SYMinHeap usingComparator:^NSComparisonResult(SYHeapItem * _Nonnull obj1, SYHeapItem * _Nonnull obj2) {
            return [obj2 compare:obj1];
        }];
    }
    return _tempHeap;
}

- (void)clearItem {
    SYTimerAssertTrue(!self.isInHeap);
    _item = nil;
}
- (NSUInteger)heapIndex {
    return [self.itemHeap indexOfObject:self];
}


- (BOOL)isInHeap {
    return [self.itemHeap containsObject:self];
}

- (BOOL)isFirstInHeap {
    return ![self.itemHeap containsObject:self];
}
- (void)checkHeapIndex {
#if DEBUG
    SYItemsHeap heap = self.itemHeap;
    SYTimerAssertTrue(!heap.isEmpty);
    SYTimerAssertTrue(self.isInHeap);
    SYTimerAssertTrue(self.heapIndex < heap.count);
    SYTimerAssertTrue([heap objectAtIndex:self.heapIndex] == self);
    for (NSInteger i = 0, size = heap.count; i < size; i++) {
        SYHeapItem *heapItem = [heap objectAtIndex:i];
        SYTimerAssertTrue(heapItem.heapIndex == i);
    }
#endif
}

- (void)checkConsistency {
    // Items should be in the heap if and only if they have a non-null next item.
    if (self.isInHeap) {
        [self checkHeapIndex];
    }
}
- (void)heapDecreaseKey {
    [self checkHeapIndex];
    [self.itemHeap heapDecreaseAtIndex:self.heapIndex];
    [self checkHeapIndex];
}
- (void)heapDelete {
    [self.itemHeap removeObject:self];
}

- (void)heapIncreaseKey {
    [self checkHeapIndex];
    [self.itemHeap heapIncreaseAtIndex:self.heapIndex];
    [self checkHeapIndex];
}

- (void)heapInsert {
    SYTimerAssertTrue(!self.isInHeap);
    [self.itemHeap addObject:self];
}

+ (BOOL)parentHeapPropertyHolds:(SYHeapItem *)current heap:(SYItemsHeap)heap currentIndex:(NSUInteger)currentIndex {
    if (!currentIndex) {
        return YES;
    }
    NSUInteger parentIndex = (currentIndex - 1) / 2;
    return [current compare:[heap objectAtIndex:parentIndex]] == NSOrderedAscending;
}
+ (BOOL)childHeapPropertyHolds:(SYHeapItem *)current heap:(SYItemsHeap)heap childIndex:(NSUInteger)childIndex {
    if (childIndex >= heap.count) {
        return YES;
    }
    return [[heap objectAtIndex:childIndex] compare:current]  == NSOrderedAscending;
}

- (BOOL)hasValidHeapPosition {
    SYTimerAssertTrue(self.item.heapItem);
    if (!self.isInHeap) {
        return NO;
    }
    // Check if the heap property still holds with the new item. If it does we don't need to do anything.
    // This assumes that the heap is a standard binary heap. In an unlikely event it is not, the assertions
    // in updateHeapIfNeeded will get hit.
    SYItemsHeap heap = self.itemHeap;
    NSUInteger heapIndex = self.heapIndex;
    if (![self.class parentHeapPropertyHolds:self heap:heap currentIndex:heapIndex]) {
        return NO;
    }
    NSUInteger childIndex1 = 2 * heapIndex + 1;
    NSUInteger childIndex2 = childIndex1 + 1;
    return [self.class childHeapPropertyHolds:self heap:heap childIndex:childIndex1] && [self.class childHeapPropertyHolds:self heap:heap childIndex:childIndex2];
}

- (void)dealloc {
    
}
@end


