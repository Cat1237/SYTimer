//
//  SYTimerBaseInternal.h
//  SYTimer
//
//  Created by ws on 2020/2/16.
//  Copyright © 2020 Tino. All rights reserved.
//

#import <SYTimer/SYTimerBase.h>
#import <SYTimer/SYMonotonicTime.h>
#import <SYTimer/SYTimerBase+SYHeapItem.h>
#import <atomic>
#import <algorithm>
#import <SYTimer/SYTimerGlobalData.h>


@interface SYTimerBase()
{
    @package
    Seconds _repeatInterval; // 0 if not repeating
    NSThread *_currentThread;
    MonotonicTime _unalignedNextFireTime; // _nextFireTime not considering alignment interval
    SYRunLoopTimer *_runLoopTimer;
    CFRunLoopMode _runLoopMode;
}
@end
