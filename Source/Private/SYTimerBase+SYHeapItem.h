//
//  SYTimerBase+SYHeapItem.h
//  SYTimer
//
//  Created by ws on 2020/2/14.
//  Copyright © 2020 Tino. All rights reserved.
//


#import <SYTimer/SYTimerBase.h>
#import <SYTimer/SYHeapTimerItem.h>

NS_ASSUME_NONNULL_BEGIN

@interface SYTimerBase (SYHeapItem)<SYHeapItemProtocol>

- (CFRunLoopMode)runLoopMode;
@end

NS_ASSUME_NONNULL_END
