//
//  SYThreadTimers.h
//  SYTimer
//
//  Created by ws 2018/12/6.
//  Copyright © 2018 ws. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SYTimer/SYHeapItem.h>
NS_ASSUME_NONNULL_BEGIN

@protocol SYShareTimer;
@interface SYThreadTimers : NSObject
- (instancetype)initWithRunLoopMode:(CFRunLoopMode)mode;
// On a thread different then main, we should set the thread's instance of the SharedTimer.
- (SYItemsHeap)timerHeap;
- (void)setSharedTimer:(id<SYShareTimer>)shareTimer;
- (void)updateSharedTimer;
- (void)fireTimersInNestedEventLoop;

@end



NS_ASSUME_NONNULL_END
