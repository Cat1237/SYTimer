//
//  SYTimerGlobalData.h
//  SYTimer
//
//  Created by ws on 2020/2/9.
//  Copyright © 2020 ws. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SYTimer/SYThreadTimers.h>
NS_ASSUME_NONNULL_BEGIN


@class SYThreadTimers;
@interface SYTimerGlobalData : NSObject

@property (nonatomic, strong, class, readonly) SYTimerGlobalData *timerGlobalData;
- (SYThreadTimers *)threadTimersForRunLoopMode:(CFRunLoopMode)mode;
+ (SYItemsHeap)timerGlobalTimerHeapForRunLoopMode:(CFRunLoopMode)mode;
@end



NS_ASSUME_NONNULL_END
