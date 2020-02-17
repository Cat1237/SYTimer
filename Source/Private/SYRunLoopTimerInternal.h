//
//  _SYRunLoopTimer.h
//  SYTimer
//
//  Created by ws on 2020/2/16.
//  Copyright © 2020 Tino. All rights reserved.
//

#import <SYTimer/SYRunLoop.h>
#import <SYTimer/SYSeconds.h>

@interface SYRunLoopTimerBase()
{
    CFRunLoopTimerRef _timer;
    SYRunLoop *_runLoop;
    CFRunLoopMode _runLoopMode;
    Seconds _repeatInterval;
    Seconds _nextFireInterval;
}
@end
