//
//  SYBase.h
//  SYTimer
//
//  Created by ws on 2020/2/17.
//  Copyright © 2020 Tino. All rights reserved.
//

#import <Foundation/NSException.h>

#if !defined(UNLIKELY)
#define UNLIKELY(x) __builtin_expect(!!(x), 0)
#endif

#define SYTimerAssert(condition, desc, ...) NSAssert(condition, desc, ##__VA_ARGS__)

#define SYTimerAssertTrue(condition) SYTimerAssert((condition), @"Expected %s to be true.", #condition)
