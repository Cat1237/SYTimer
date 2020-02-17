//
//  SYHeapTest.m
//  SYTimer
//
//  Created by ws on 2020/2/11.
//  Copyright © 2020 016. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <SYTimer/SYHeap.h>

@interface SYHeapTest : XCTestCase

@end

@implementation SYHeapTest

- (NSArray <NSNumber *>*)getRandomNumbers:(NSUInteger)count {
    NSMutableArray<NSNumber *> *original = @[].mutableCopy;
    for (int i = 0; i < count; i++) {
        [original addObject:@(arc4random_uniform(25))];
    }
    return original.copy;
}

- (void)testSimple {
    SYHeap<NSNumber *>* h = [[SYHeap alloc] initWithHeapType:SYMaxHeap usingComparator:^NSComparisonResult(NSNumber *_Nonnull obj1, NSNumber *  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    [h addObject:@(1)];
    [h addObject:@(3)];
    [h addObject:@(2)];

    XCTAssertEqual(@(3), [h removeRootObject]);
    XCTAssertTrue([h checkHeapProperty]);
}

- (void)testSortedDesc {
    
    SYHeap<NSNumber *>* maxHeap = [[SYHeap alloc] initWithHeapType:SYMaxHeap usingComparator:^NSComparisonResult(NSNumber *_Nonnull obj1, NSNumber *  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    SYHeap<NSNumber *>* minHeap = [[SYHeap alloc] initWithHeapType:SYMinHeap usingComparator:^NSComparisonResult(NSNumber *_Nonnull obj1, NSNumber *  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];

    NSArray *input = @[@(16), @(14), @(10), @(9), @(8), @(7), @(4), @(3), @(2), @(1)];
    for (NSNumber *i in input) {
        [minHeap addObject:i];
        [maxHeap addObject:i];
        XCTAssertTrue(minHeap.checkHeapProperty);
        XCTAssertTrue(minHeap.checkHeapProperty);
    }
    
    NSUInteger minHeapInputPtr = input.count - 1;
    NSUInteger maxHeapInputPtr = 0;
    __block NSNumber *maxHeapRoot = nil;
    __block NSNumber *minHeapRoot = nil;

    BOOL(^maxHeapRemoveRootObject)(void) = ^{
        maxHeapRoot = [maxHeap removeRootObject];
        if (maxHeapRoot == nil) {
            return NO;
        }
        return YES;
    };
    BOOL(^minHeapRemoveRootObject)(void) = ^{
        minHeapRoot = [minHeap removeRootObject];
        if (minHeapRoot == nil) {
            return NO;
        }
        return YES;
    };
    while (maxHeapRemoveRootObject() && minHeapRemoveRootObject()) {
        XCTAssertEqual(maxHeapRoot, input[maxHeapInputPtr], @"%@", maxHeap.description);
        XCTAssertEqual(minHeapRoot, input[minHeapInputPtr]);
        maxHeapInputPtr += 1;
        minHeapInputPtr -= 1;
        XCTAssertTrue(minHeap.checkHeapProperty, @"%@", minHeap.description);
        XCTAssertTrue(maxHeap.checkHeapProperty);
    }
    XCTAssertEqual(-1, minHeapInputPtr);
    XCTAssertEqual(input.count, maxHeapInputPtr);
}

- (void)testAddAndRemoveRandomNumbers {
    SYHeap<NSNumber *>* maxHeap = [[SYHeap alloc] initWithHeapType:SYMaxHeap usingComparator:^NSComparisonResult(NSNumber *_Nonnull obj1, NSNumber *  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    SYHeap<NSNumber *>* minHeap = [[SYHeap alloc] initWithHeapType:SYMinHeap usingComparator:^NSComparisonResult(NSNumber *_Nonnull obj1, NSNumber *  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    NSInteger maxHeapLast = INT_MAX;
    NSInteger minHeapLast = INT_MIN;

    NSUInteger N = 10;

    for (NSNumber *n in [self getRandomNumbers:N]) {
        [maxHeap addObject:n];
        [minHeap addObject:n];
        XCTAssertTrue(maxHeap.checkHeapProperty, @"%@", maxHeap.description);
        XCTAssertTrue(minHeap.checkHeapProperty, @"%@", minHeap.description);
    }
    for (int i = 0; i < N/2; i++) {
        NSNumber *value = maxHeap.removeRootObject;
        XCTAssertLessThanOrEqual(value.intValue, maxHeapLast);
        maxHeapLast = value.intValue;
        value = minHeap.removeRootObject;
        XCTAssertGreaterThanOrEqual(value.intValue, minHeapLast);
        minHeapLast = value.unsignedIntValue;

        XCTAssertTrue(minHeap.checkHeapProperty);
        XCTAssertTrue(maxHeap.checkHeapProperty);
    }

    maxHeapLast = UINT8_MAX;
    minHeapLast = INT8_MIN;

    for (NSNumber *n in [self getRandomNumbers:N]) {
        [maxHeap addObject:n];
        [minHeap addObject:n];
        XCTAssertTrue(maxHeap.checkHeapProperty, @"%@", maxHeap.description);
        XCTAssertTrue(minHeap.checkHeapProperty, @"%@", minHeap.description);
    }

    for (int i = 0; i < N/2+N; i++) {

        NSNumber *value = maxHeap.removeRootObject;
        XCTAssertLessThanOrEqual(value.intValue, maxHeapLast);
        maxHeapLast = value.intValue;
        value = minHeap.removeRootObject;
        XCTAssertGreaterThanOrEqual(value.intValue, minHeapLast);
        minHeapLast = value.intValue;

        XCTAssertTrue(minHeap.checkHeapProperty);
        XCTAssertTrue(maxHeap.checkHeapProperty);
    }
}

- (void)testRemoveElement {
    SYHeap<NSNumber *>* maxHeap = [[SYHeap alloc] initWithHeapType:SYMaxHeap usingComparator:^NSComparisonResult(NSNumber *_Nonnull obj1, NSNumber *  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    for (NSNumber *f in @[@(84), @(22), @(19), @(21), @(3), @(10), @(6), @(5), @(20)]) {
        [maxHeap addObject:f];
    }
    XCTAssertTrue(maxHeap.checkHeapProperty, @"%@", maxHeap.description);
}
@end
