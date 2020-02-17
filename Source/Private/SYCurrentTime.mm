//
//  SYCurrentTime.cpp
//  SYTimer
//
//  Created by ws on 2019/1/8.
//  Copyright © 2019 ws. All rights reserved.
//

#import <SYMonotonicTime.h>
#import <SYWallTime.h>
#include <time.h>
#include <mach/mach.h>
#include <mach/mach_time.h>
#include <mutex>
#include <sys/time.h>
namespace SY {
static inline double currentTime()
{
    struct timeval now;
    gettimeofday(&now, 0);
    return now.tv_sec + now.tv_usec / 1000000.0;
}
WallTime WallTime::now()
{
    return fromRawSeconds(currentTime());
}
MonotonicTime MonotonicTime::now()
{
    // Based on listing #2 from Apple QA 1398, but modified to be thread-safe.
    static mach_timebase_info_data_t timebaseInfo;
    static std::once_flag initializeTimerOnceFlag;
    std::call_once(initializeTimerOnceFlag, [] {
        kern_return_t kr = mach_timebase_info(&timebaseInfo);
        assert(kr == KERN_SUCCESS);
        assert(timebaseInfo.denom);
    });
    
    return fromRawSeconds((mach_absolute_time() * timebaseInfo.numer) / (1.0e9 * timebaseInfo.denom));

}
}


