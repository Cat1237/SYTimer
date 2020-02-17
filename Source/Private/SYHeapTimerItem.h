//
//  SYHeapTimerItem.h
//  SYTimer
//
//  Created by ws on 2020/2/9.
//  Copyright © 2020 ws. All rights reserved.
//

#import <SYTimer/SYHeapItem.h>
#import <SYTimer/SYMonotonicTime.h>

NS_ASSUME_NONNULL_BEGIN
@class SYTimerBase;
@interface SYHeapTimerItem : SYHeapItem

@property (nonatomic, assign) MonotonicTime time;
@property (nonatomic, assign) NSUInteger insertionOrder;
- (instancetype)initWithTimer:(SYTimerBase *)timer time:(MonotonicTime)time insertionOrder:(NSUInteger)insertionOrder;
@end

NS_ASSUME_NONNULL_END
