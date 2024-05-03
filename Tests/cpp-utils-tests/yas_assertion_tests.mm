//
//  yas_assertion_tests.mm
//

#import <XCTest/XCTest.h>
#include <cpp-utils/yas_assertion.h>

using namespace yas;

@interface yas_assertion_tests : XCTestCase

@end

@implementation yas_assertion_tests

- (void)setUp {
}

- (void)tearDown {
}

- (void)test_assertion_failure_if_not_test {
    assertion_failure_if_not_test();
}

@end
