//
//  SYTimerTests.m
//  SYTimerTests
//
//  Created by ws on 2020/2/7.
//  Copyright © 2020 Tino. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <SYTimer/SYTimerBase.h>

@interface SYTimerTests : XCTestCase
{
    SYTimer *_otherRunLoopTimer;
    SYTimer *_timer;
    SYTimer *_timer1;
    SYTimer *_timer2;

}
@end

@implementation SYTimerTests
static int num = 0;

static NSThread *TestTimerThread;
- (void)_runLoopThread
{
    [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    
    while (YES) {
        @autoreleasepool {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
}

- (void)setUp {
    TestTimerThread = [[NSThread alloc] initWithTarget:self selector:@selector(_runLoopThread) object:nil];
    [TestTimerThread setName:@"TestTimerThread"];
    [TestTimerThread setQualityOfService:[[NSThread mainThread] qualityOfService]];
    [TestTimerThread start];
}


- (NSString *)timeInterval:(SYTimer *)timer {
    return [NSString stringWithFormat:@"%@--%s---nextFireInterval: %f-----repeatInterval:%f", timer, __FUNCTION__, timer.nextFireInterval, timer.repeatInterval];
}

- (void)testRunLoopTimer {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Timer test"];
    [self performSelector:@selector(otherRnuLoopTimers:) onThread:TestTimerThread withObject:expectation waitUntilDone:NO];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)otherRnuLoopTimersPaused {
    _otherRunLoopTimer.paused = YES;
}
- (void)otherRnuLoopTimersNoPaused {
    _otherRunLoopTimer.paused = NO;
}
- (void)otherRnuLoopTimers:(XCTestExpectation *)expectation {
    
    _otherRunLoopTimer = [[SYTimer alloc] initWithRunLoop:[SYRunLoop current] runLoopMode:kCFRunLoopCommonModes block:^(SYTimer * timer) {
        num ++;
        NSLog(@"otherRunLoopTimer---%@", [self timeInterval:timer]);
        if (num > 15) {
            [expectation fulfill];
        }
    }];
    
    [_otherRunLoopTimer startRepeating:.5];
    [self performSelector:@selector(otherRnuLoopTimersPaused) withObject:nil afterDelay:3];
    [self performSelector:@selector(otherRnuLoopTimersNoPaused) withObject:nil afterDelay:4];
}

- (void)timer1Run {
    NSLog(@"timer1---%@", [self timeInterval:_timer1]);
}
- (void)testMainRunLoopTimers {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Timer test"];
    

    _timer = [[SYTimer alloc] initWithRunLoop:[SYRunLoop current] runLoopMode:kCFRunLoopCommonModes block:^(SYTimer * _Nonnull timer) {
        num ++;
        NSLog(@"timer---%@", [self timeInterval:timer]);

        if (num > 30) {
            [expectation fulfill];
        }
    }];
    [_timer startRepeating:.5];
    _timer1 = [[SYTimer alloc] initWithTarget:self selector:@selector(timer1Run) runLoop:[SYRunLoop current] runLoopMode:kCFRunLoopDefaultMode];
    [_timer1 startRepeating:.5];

    _timer2 = [[SYTimer alloc] initWithRunLoop:[SYRunLoop current] runLoopMode:kCFRunLoopCommonModes block:^(SYTimer * _Nonnull timer) {
        num ++;
        NSLog(@"timer2---%@", [self timeInterval:timer]);
    }];
    [_timer2 startRepeating:.5];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_timer1 augmentFireInterval:.2];

        [self->_timer1 augmentRepeatInterval:0.1];
        
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_timer2 augmentFireInterval:1.0];

        [self->_timer2 augmentRepeatInterval:0.3];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->_timer augmentFireInterval:.5];

        [self->_timer augmentRepeatInterval:0.2];
        
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_timer2.paused = YES;
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_timer2.paused = NO;
    });
    [self waitForExpectationsWithTimeout:20 handler:nil];

}

@end
