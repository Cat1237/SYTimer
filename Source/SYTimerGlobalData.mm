//
//  SYTimerGlobalData.m
//  SYTimer
//
//  Created by ws on 2020/2/9.
//  Copyright © 2020 ws. All rights reserved.
//

#import <SYTimer/SYTimerGlobalData.h>
#import <SYTimer/SYThreadTimers.h>
#import <SYTimer/SYThreadSpecificVariable.h>
#import <SYTimer/SYBase.h>
@interface SYTimerGlobalData() {
    SYThreadTimers *_threadTimersDefault;
    SYThreadTimers *_threadTimersCommon;

}

@end
@implementation SYTimerGlobalData
static SYThreadSpecificVariable<SYTimerGlobalData *>* staticData = nil;

+ (SYTimerGlobalData *)timerGlobalData {
    if (UNLIKELY(!staticData)) {
        staticData = [[SYThreadSpecificVariable alloc] initWithValue:^id _Nullable{
            return [SYTimerGlobalData new];
        }];
    }
    return staticData.currentValue;
}

+ (SYItemsHeap)timerGlobalTimerHeapForRunLoopMode:(CFRunLoopMode)mode {
    return [self.timerGlobalData threadTimersForRunLoopMode:mode].timerHeap;
}

- (SYThreadTimers *)threadTimersForRunLoopMode:(CFRunLoopMode)mode {
    if (mode == kCFRunLoopCommonModes) {
        return _threadTimersCommon;
    }
    if (mode == kCFRunLoopDefaultMode) {
        return _threadTimersDefault;
    }
    return _threadTimersCommon;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _threadTimersDefault = [[SYThreadTimers alloc] initWithRunLoopMode:kCFRunLoopDefaultMode];
        _threadTimersCommon = [[SYThreadTimers alloc] initWithRunLoopMode:kCFRunLoopCommonModes];
    }
    return self;
}

@end

