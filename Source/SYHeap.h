//
//  SYHeap.h
//  SYTimer
//
//  Created by ws on 2020/2/11.
//  Copyright © 2020 ws. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SYHeapType) {
    SYMaxHeap,
    SYMinHeap
};

@interface SYHeap<__covariant ObjectType> : NSObject

- (instancetype)initWithHeapType:(SYHeapType)type usingComparator:(NSComparator NS_NOESCAPE)comparator;

@property (nonatomic, readonly) SYHeapType type;

@property (nonatomic, copy, readonly) NSArray<ObjectType> *storage;

@property (nullable, nonatomic, readonly) ObjectType firstObject;

@property (nullable, nonatomic, readonly) ObjectType lastObject;

@property (readonly) NSUInteger count;

@property (readonly, getter = isEmpty) BOOL empty;

- (void)addObject:(ObjectType)anObject;

- (ObjectType _Nullable)removeRootObject;

- (ObjectType _Nullable)removeLastObject;

- (BOOL)removeObject:(id)object;

- (ObjectType _Nullable)removeObjectAtIndex:(NSUInteger)index;

- (NSUInteger)indexOfObject:(ObjectType)object;

- (BOOL)containsObject:(id)object;

- (ObjectType)objectAtIndex:(NSUInteger)index;

- (BOOL)comparator:(id)a b:(id)b;

- (BOOL)isEqualToHeap:(SYHeap<ObjectType> *)otherHeap;

// named `HEAP-INCREASE-KEY` in CRLS
- (void)heapIncreaseAtIndex:(NSUInteger)index;
- (void)heapIncreaseAtIndex:(NSUInteger)index key:(ObjectType)key;

// named `HEAP-DECREASE-KEY` in CRLS
- (void)heapDecreaseAtIndex:(NSUInteger)index;
- (void)heapDecreaseAtIndex:(NSUInteger)index key:(ObjectType)key;

- (BOOL)checkHeapProperty;
@end

NS_ASSUME_NONNULL_END
