//
//  yas_thread.mm
//

#include "yas_thread.h"
#import <Foundation/Foundation.h>

using namespace yas;

bool thread::is_main() {
    return [NSThread isMainThread];
}

void thread::sleep_for_timeinterval(double const interval) {
    [NSThread sleepForTimeInterval:interval];
}