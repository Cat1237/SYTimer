//
//  SYRunLoop.h
//  SYTimer
//
//  Created by ws on 2019/1/23.
//  Copyright © 2019 ws. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYRunLoop : NSObject

+ (instancetype)current;
+ (instancetype)main;
+ (BOOL)isMain;

/// This block will executed when CFRunLoopSource was got signal.
- (void)dispatch:(void(^)(void))function;
+ (void)run;

/// stop runLoop
- (void)stop;

/// Signal CFRunLoopSource and wake up runLoop.
- (void)wakeUp;
- (void)runForDuration:(NSTimeInterval)duration;
- (CFRunLoopRef)getCFRunLoop;
@end
@interface SYRunLoopTimerBase : NSObject
- (void)startOneShot:(NSTimeInterval)interval;
- (void)startRepeating:(NSTimeInterval)repeatInterval;
- (void)startInterval:(NSTimeInterval)nextFireInterval repeat:(NSTimeInterval)repeatInterval;
- (void)stop;
- (BOOL)isActive;
- (NSTimeInterval)secondsUntilFire;
- (void)restartTimer;
@end

@interface SYRunLoopTimer : SYRunLoopTimerBase
- (instancetype)initWithTarget:(id)target selector:(SEL)selector;
- (instancetype)initWithTarget:(id)target selector:(SEL)selector runLoop:(SYRunLoop *)runLoop runLoopMode: (CFRunLoopMode)runLoopMode;

@end

