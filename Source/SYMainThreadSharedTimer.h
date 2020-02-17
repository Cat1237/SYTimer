//
//  SYMainThreadSharedTimer.h
//  SYTimer
//
//  Created by ws 2018/12/6.
//  Copyright © 2018 ws. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SYTimer/SYShareTimer.h>
NS_ASSUME_NONNULL_BEGIN

@interface SYMainThreadSharedTimer : NSObject <SYShareTimer>

+ (instancetype)singletonWithRunLoopMode:(CFRunLoopMode)mode;
// need to call this from non-member functions at the moment.
- (void)fired;
@end

NS_ASSUME_NONNULL_END
