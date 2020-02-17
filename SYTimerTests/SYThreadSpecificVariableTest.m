//
//  SYThreadSpecificVariableTest.m
//  SYTimerTests
//
//  Created by ws on 2020/2/16.
//  Copyright © 2020 Tino. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <SYTimer/SYThreadSpecificVariable.h>
#import <SYTimer/SYRunLoop.h>
@interface SYThreadSpecificVariableTest : XCTestCase
{
    dispatch_queue_t _queue;
}
@end

@implementation SYThreadSpecificVariableTest

- (void)setUp {
    _queue = dispatch_queue_create(0, 0);
}


- (void)testThreadSpecificVariable {
    
    __block SYRunLoop *runLoop;
    dispatch_async(_queue, ^{
        runLoop = [SYRunLoop current];
        dispatch_async(self->_queue, ^{
                XCTAssertEqual(runLoop, [SYRunLoop current]);
        });
    });
    
    dispatch_async(_queue, ^{
        XCTAssertEqual(runLoop, [SYRunLoop current]);
    });
}


@end
