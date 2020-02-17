
//
//  SYShareTimer.h
//  SYTimer
//
//  Created by ws 2018/12/6.
//  Copyright © 2018 ws. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SYShareTimer 
- (void)setFiredFunction:(nullable void(^)(void))function;

// The fire interval is in seconds relative to the current monotonic clock time.
- (void)setFireInterval:(NSTimeInterval)seconds;
- (void)stop;
- (void)invalidate;
@end

NS_ASSUME_NONNULL_END
