//
//  SYTimerBase+Private.h
//  SYTimer
//
//  Created by ws on 2020/2/14.
//  Copyright © 2020 Tino. All rights reserved.
//


#import <SYTimer/SYTimerBase.h>
#import <SYTimer/SYSeconds.h>
#import <SYTimer/SYMonotonicTime.h>
NS_ASSUME_NONNULL_BEGIN

@interface SYTimerBase (Private)
- (Seconds)_nextFireInterval;

- (Seconds)_repeatInterval;

- (Seconds)_nextUnalignedFireInterval;

- (void)_augmentFireInterval:(Seconds)delta;
- (void)_augmentRepeatInterval:(Seconds)delta;

- (void)_startOneShot:(Seconds)interval;
- (void)_startRepeating:(Seconds)interval;

- (void)_start:(Seconds)nextFireInterval repeatInterval:(Seconds)repeatInterval;

- (void)setNextFireTime:(MonotonicTime)newTime;
- (MonotonicTime)nextFireTime;
- (BOOL)canAccessThreadLocalDataForThread:(NSThread *)t;
- (void)fired;
@end

NS_ASSUME_NONNULL_END
