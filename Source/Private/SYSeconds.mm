//
//  SYSecondss.m
//  SYTimer
//
//  Created by ws on 2019/1/8.
//  Copyright © 2019 ws. All rights reserved.
//

#import <SYTimer/SYSeconds.h>
#import <mutex>
#include <chrono>             // std::chrono::seconds
namespace SY
{

void sleep(Seconds value)
{
    // It's very challenging to find portable ways of sleeping for less than a second. On UNIX, you want to
    // use usleep() but it's hard to #include it in a portable way (you'd think it's in unistd.h, but then
    // you'd be wrong on some OSX SDKs). Also, usleep() won't save you on Windows. Hence, bottoming out in
    // lock code, which already solves the sleeping problem, is probably for the best.
    
    std::mutex fakeLock;
    std::condition_variable fakeCondition;
    std::unique_lock<std::mutex> fakeLocker(fakeLock);
    auto now = std::chrono::system_clock::now();
    fakeCondition.wait_until(fakeLocker, now + std::chrono::seconds(static_cast<long long>(value.seconds())));
}
}
