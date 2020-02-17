//
//  SYTimer.h
//  SYTimer
//
//  Created by ws 2018/12/5.
//  Copyright © 2018 ws. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SYTimer/SYRunLoop.h>
NS_ASSUME_NONNULL_BEGIN

@interface SYTimerBase : NSObject

@property (nonatomic, readonly) NSTimeInterval nextUnalignedFireInterval;
@property (nonatomic, readonly) NSTimeInterval repeatInterval;
@property (nonatomic, readonly) NSTimeInterval nextFireInterval;
@property (nonatomic, readonly) BOOL isActive;

/* When true the object is prevented from firing. Initial state is
 * false. */
@property(getter=isPaused, nonatomic) BOOL paused;

/// Change nextFireTime
- (void)augmentFireInterval:(NSTimeInterval)delta;

/// Change next repeat time
- (void)augmentRepeatInterval:(NSTimeInterval)delta;
- (void)didChangeAlignmentInterval;

/// Just fire one shot.
- (void)startOneShot:(NSTimeInterval)interval;
- (void)startRepeating:(NSTimeInterval)interval;

/// Start timer.
/// - parameter:  nextFireInterval  The time at which the timer should first fire. Timer.Now + nextFireInterval
/// - parameter:  repeats  the timer will repeatedly reschedule itself in repeat interval until invalidated.
- (void)start:(NSTimeInterval)nextFireInterval repeatInterval:(NSTimeInterval)repeatInterval;
- (void)stop;
+ (void)fireTimersInNestedEventLoop;
@end
@interface SYTimer : SYTimerBase

/// Initializes a new SYTimer object using the block as the main body of execution for the timer. This timer will scheduled on main run loop.
/// - parameter:  runLoopMode which runLoopMode it will scheduled
/// - parameter:  block  The execution body of the timer; the timer itself is passed as the parameter to this block when executed to aid in avoiding cyclical references
+ (instancetype)mainRunLoopTimerWithRunLoopMode:(CFRunLoopMode)runLoopMode
                                          block:(void(^)(SYTimer *))block;


/// Creates and returns a new SYTimer object initialized with the specified block object and schedules it on the specified run loop in the specified mode.
/// - parameter:  runLoop which runloop scheduled, when nil it will be current runLoop
/// - parameter:  runLoopMode  which runLoopMode scheduled
/// - parameter:  block  The execution body of the timer; the timer itself is passed as the parameter to this block when executed to aid in avoiding cyclical references

/// _timer = [[SYTimer alloc] initWithRunLoop:[SYRunLoop current] runLoopMode:kCFRunLoopCommonModes block:^(SYTimer * _Nonnull timer) {
///        NSLog(@"%@", timer);
/// }];
/// [_timer startRepeating:.5];

/// when don't need timer, just:
/// [_timer stop];
/// _timer = nil;
- (instancetype)initWithRunLoop:(SYRunLoop * _Nullable)runLoop
                    runLoopMode:(CFRunLoopMode)runLoopMode
                          block:(void(^)(SYTimer *))block;


/* Create a new SYTimer object for the specified run loop in the specified mode. It will
* invoke the method called 'selector' on 'target', the method has the
* signature '(void)selector:(SYTimer *)sender'. */
- (instancetype)initWithTarget:(id)target
                      selector:(SEL)selector
                       runLoop:(SYRunLoop * _Nullable)runLoop
                   runLoopMode:(CFRunLoopMode)runLoopMode;


@end


@interface SYDeferrableOneShotTimer : SYTimerBase

- (instancetype)initWithTarget:(id)target
                      selector:(SEL)selector
                         delay:(NSTimeInterval)delay
                       runLoop:(SYRunLoop * _Nullable)runLoop
                   runLoopMode:(CFRunLoopMode)runLoopMode;

- (instancetype)initWithRunLoop:(SYRunLoop * _Nullable)runLoop
                    runLoopMode:(CFRunLoopMode)runLoopMode
                          delay:(NSTimeInterval)delay
                          block:(void(^)(SYDeferrableOneShotTimer *))block;

- (void)restart;
@end
NS_ASSUME_NONNULL_END
