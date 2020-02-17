//
//  SYRunLoopTimer+Private.h
//  SYTimer
//
//  Created by ws on 2020/2/16.
//  Copyright © 2020 Tino. All rights reserved.
//



#import <SYTimer/SYRunLoop.h>
#import <SYTimer/SYSeconds.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYRunLoopTimerBase (Private)
- (void)_startOneShot:(Seconds)interval;
- (void)_startRepeating:(Seconds)repeatInterval;
- (void)_startInterval:(Seconds)nextFireInterval repeat:(Seconds)repeatInterval;
- (Seconds)_secondsUntilFire;
- (void)invalidate;
- (void)fired;
@end

NS_ASSUME_NONNULL_END
