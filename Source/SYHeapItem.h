//
//  SYHeapItem.h
//  SYTimer
//
//  Created by ws on 2020/2/9.
//  Copyright © 2020 ws. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SYTimer/SYHeap.h>
NS_ASSUME_NONNULL_BEGIN

@class SYHeapItem;

typedef SYHeap <__kindof SYHeapItem *>* SYItemsHeap;

@protocol SYHeapItemProtocol

@property (nonatomic, strong) __kindof SYHeapItem *heapItem;

@end

@interface SYHeapItem : NSObject
/**
* An object which it's packaged as SYHeapItem and store it in a heap which it's SYHeap.
*
* @discussion This class is useful for handling item in heap. You can pass this in place
* of the item to something which need handling in SYHeap.
*
* @return an instance of SYHeapItem
*/
- (instancetype)initWithItem:(id<SYHeapItemProtocol>)item;

/**
* @return item The item which it's packaged as an SYHeapItem and store it in a heap which it's SYHeap.
*/
@property (nonatomic, weak, readonly) id<SYHeapItemProtocol> item;

/**
* Return the index for item in heap.
*/
- (NSUInteger)heapIndex;

/**
* Return All the item in this heap.
*/
- (SYItemsHeap)itemHeap;

/**
Return if the item is in heap.
*/
- (BOOL)isInHeap;

/**
Return if the item is first in heap.
*/
- (BOOL)isFirstInHeap;

/**
Return if the heapItem still hold item.
*/
- (BOOL)hasItem;

/**
Remove item from HeapItem.
*/
- (void)clearItem;

/**
Check the heapItem index is in heap when DEBUG.
*/
- (void)checkHeapIndex;

/**
Useful as a fast check to see if consistency.
*/
- (void)checkConsistency;

// named `HEAP-DECREASE-KEY` in CRLS
- (void)heapDecreaseKey;

/**
* Remove item from heap.
*/
- (void)heapDelete;

// named `HEAP-INCREASE-KEY` in CRLS
- (void)heapIncreaseKey;

/**
 Append item.
*/
- (void)heapInsert;

- (BOOL)hasValidHeapPosition;
@end

@interface SYHeapItem(Comparable)
- (NSComparisonResult)compare:(__kindof SYHeapItem *)item;

@end


NS_ASSUME_NONNULL_END

