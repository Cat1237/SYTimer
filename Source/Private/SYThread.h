//
//  SYThread.h
//  SkyLark
//
//  Created by ws on 2020/2/7.
//  Copyright © 2020 Tino. All rights reserved.
//

#import <pthread.h>

static inline __attribute__((warn_unused_result)) BOOL SYIsMainThread()
{
    return 0 != pthread_main_np();
}
