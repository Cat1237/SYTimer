//
//  SYHeap.m
//  SYTimer
//
//  Created by ws on 2020/2/11.
//  Copyright © 2020 ws. All rights reserved.
//

#import <SYTimer/SYHeap.h>
#import <tgmath.h>

@interface SYHeap()
{
    NSMutableArray * _storage;
    SYHeapType _type;
    NSComparator _comparator;
}

@property (nonatomic, copy) NSComparator comparator;
@end

@implementation SYHeap

- (instancetype)initWithHeapType:(SYHeapType)type usingComparator:(nonnull NSComparator NS_NOESCAPE)comparator {
    self = [super init];
    if (self) {
        _comparator = comparator;
        _type = type;
        _storage = @[].mutableCopy;
        _comparator = comparator;
    }
    return self;
}

- (SYHeapType)type {
    return _type;
}

- (NSArray<id> *)storage {
    return [_storage copy];
}

- (NSUInteger)count {
    return _storage.count;
}

- (BOOL)isEmpty {
    return _storage.count == 0;
}

- (id)firstObject {
    return _storage.firstObject;
}

- (id)lastObject {
    return _storage.lastObject;
}

// named `PARENT` in SYRS
- (NSInteger)parentIndex:(NSInteger)index {
    return (index-1) / 2;
}

// named `LEFT` in SYRS
- (NSInteger)leftIndex:(NSInteger)index {
    return 2*index + 1;
}

// named `RIGHT` in SYRS
- (NSInteger)rightIndex:(NSInteger)index {
    return 2*index + 2;
}
- (BOOL)comparator:(id)a b:(id)b {
    switch (_type) {
        case SYMaxHeap:
            return self.comparator(a, b) == NSOrderedDescending;
        case SYMinHeap:
            return self.comparator(a, b) == NSOrderedAscending;
    }
}

- (NSUInteger)indexOfObject:(id)object {
    return [_storage indexOfObject:object];
}

- (BOOL)containsObject:(id)object {
    return [_storage containsObject:object];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [_storage objectAtIndex:index];
}

// named `MAX-HEAPIFY` in SYRS
- (void)heapify:(NSInteger)index {
    NSInteger left = [self leftIndex:index];
    NSInteger right = [self rightIndex:index];

    NSInteger root = 0;
    if (left <= (_storage.count - 1) && [self comparator:_storage[left] b:_storage[index]]) {
        root = left;
    } else {
        root = index;
    }

    if (right <= (_storage.count - 1) && [self comparator:_storage[right] b:_storage[root]]) {
        root = right;
    }

    if (root != index) {
        [_storage exchangeObjectAtIndex:index withObjectAtIndex:root];
        [self heapify:root];
    }
}

// named `HEAP-INCREASE-KEY` in CRLS

- (void)heapIncreaseAtIndex:(NSUInteger)index {
    while (index > 0 && [self comparator:_storage[index] b:_storage[[self parentIndex:index]]]) {
        [_storage exchangeObjectAtIndex:index withObjectAtIndex:[self parentIndex:index]];
        index = [self parentIndex:index];
    }
}

- (void)heapIncreaseAtIndex:(NSUInteger)index key:(id)key {
    NSAssert(![self comparator:_storage[index] b:key], @"New key must be closer to the root than current key");
    _storage[index] = key;
    [self heapIncreaseAtIndex:index];
}

// named `HEAP-DECREASE-KEY` in CRLS
- (void)heapDecreaseAtIndex:(NSUInteger)index {
    [self heapify:index];
}
- (void)heapDecreaseAtIndex:(NSUInteger)index key:(id)key {
    NSAssert([self comparator:_storage[index] b:key], @"New key must not be closer to the root than current key");
    _storage[index] = key;
    [self heapDecreaseAtIndex:index];
}

- (BOOL)isEqualToHeap:(SYHeap<id> *)otherHeap {
    return [_storage isEqualToArray:otherHeap->_storage];
}

- (void)addObject:(id)anObject {
    NSInteger i = _storage.count;
    [_storage addObject:anObject];
    while (i > 0 && [self comparator:_storage[i] b:_storage[[self parentIndex:i]]]) {
        [_storage exchangeObjectAtIndex:i withObjectAtIndex:[self parentIndex:i]];
        i = [self parentIndex:i];
    }
}

- (id _Nullable)removeRootObject {
    return [self removeObjectAtIndex:0];
}
- (id _Nullable)removeLastObject {
    return [self removeObjectAtIndex:_storage.count - 1];
}

- (BOOL)removeObject:(id)object {
    if ([_storage containsObject:object]) {
        NSUInteger index = [_storage indexOfObject:object];
        [self removeObjectAtIndex:index];
        return YES;
    }
    return NO;
}

- (id _Nullable)removeObjectAtIndex:(NSUInteger)index {
    if (_storage.count == 0) {
        return nil;
    }
    id element = _storage[index];
    if (_storage.count == 1 || _storage[index] == _storage[_storage.count - 1]) {
        [_storage removeLastObject];
    } else if (![self comparator:_storage[index] b:_storage[_storage.count - 1]]) {
        [self heapIncreaseAtIndex:index key:_storage[_storage.count - 1]];
        [_storage removeLastObject];
    } else {
        _storage[index] = _storage[_storage.count - 1];
        [_storage removeLastObject];
        [self heapify:index];
    }
    return element;
}

- (BOOL)checkHeapProperty {
    return [self checkHeapProperty:0];
}

- (BOOL)checkHeapProperty:(NSInteger)index {
    NSInteger li = [self leftIndex:index];
    NSInteger ri = [self rightIndex:index];
    if (index >= _storage.count) {
        return YES;
    } else {
        id me = _storage[index];
        BOOL lCond = YES;
        BOOL rCond = YES;
        if (li < _storage.count) {
            id l = _storage[li];
            lCond = ![self comparator:l b:me];
        }
        if (ri < _storage.count) {
            id r = _storage[ri];
            rCond = ![self comparator:r b:me];
        }
        return lCond && rCond && [self checkHeapProperty:li] && [self checkHeapProperty:ri];
    }
};
- (NSString *)description {
    if (_storage.count == 0) {
        return @"<empty heap>";
    }
    NSMutableArray<NSString *>* descriptions = [NSMutableArray arrayWithCapacity:_storage.count];
    __block NSInteger maxLen = 0; // storage checked non-empty above
    [_storage enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *description = [NSString stringWithFormat:@"%@", obj];
        [descriptions addObject:description];
        maxLen = description.length > maxLen ? description.length : maxLen;
    }];
    NSMutableArray<NSString *>* paddedDescs = [NSMutableArray arrayWithCapacity:descriptions.count];
    [descriptions enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *desc = obj;
        while (desc.length < maxLen) {
            if (desc.length % 2 == 0) {
                desc = [NSString stringWithFormat:@" %@",desc];
            } else {
                desc = [NSString stringWithFormat:@"%@ ",desc];
            }
        }
        [paddedDescs addObject:desc];
    }];

    NSMutableString *all = [NSMutableString stringWithString:@"\n"];
    NSMutableString *spacing = [NSMutableString string];
    for (NSInteger i = 0; i <= maxLen; i++) {
        [spacing appendString:@" "];
    }
    
    [paddedDescs enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        std::tuple<NSInteger, NSInteger> tuple = [self subtreeWidths:idx maxLength:maxLen];
        NSInteger leftWidth = std::get<0>(tuple);
        NSInteger rightWidth = std::get<1>(tuple);

        for (int i = 0; i <= leftWidth; i++) {
            [all appendString:@" "];
        }
        [all appendString:obj];
        
        for (int i = 0; i <= rightWidth; i++) {
            [all appendString:@" "];
        }
        NSInteger(^height)(NSInteger index) = ^(NSInteger index){
            return (NSInteger)log2(double(index + 1));
        };
        
        NSInteger myHeight = height(idx);
        NSInteger nextHeight = height(idx + 1);
        if (myHeight != nextHeight) {
            [all appendString:@"\n"];
        } else {
            [all appendString:spacing];
        }
    }];
    [all appendString:@"\n"];
    return all;
}

- (std::tuple<NSInteger, NSInteger>)subtreeWidths:(NSInteger)rootIndex maxLength:(NSUInteger)maxLen {
    NSInteger lcIdx = [self leftIndex:rootIndex];
    NSInteger rcIdx = [self rightIndex:rootIndex];
    NSInteger leftSpace = 0;
    NSInteger rightSpace = 0;
    if (lcIdx < _storage.count) {
        std::tuple<NSInteger, NSInteger> sws = [self subtreeWidths:lcIdx maxLength:maxLen];
        leftSpace += std::get<0>(sws) + std::get<1>(sws) + maxLen;
    }
    if (rcIdx < _storage.count) {
        std::tuple<NSInteger, NSInteger> sws = [self subtreeWidths:rcIdx maxLength:maxLen];
        rightSpace += std::get<0>(sws) + std::get<1>(sws) + maxLen;
    }
    return std::make_tuple(leftSpace, rightSpace);
};


@end
