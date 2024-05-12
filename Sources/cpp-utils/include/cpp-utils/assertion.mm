//
//  assertion.cpp
//

#include "assertion.h"

#import <Foundation/Foundation.h>

using namespace yas;

void yas::assertion_failure_if_not_test() {
    static bool const is_test = NSClassFromString(@"XCTestCase") != nil;

    if (is_test) {
        return;
    }

    assert(0);
}
