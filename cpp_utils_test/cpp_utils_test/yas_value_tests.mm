//
//  yas_value_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_value.h"

using namespace yas;

@interface yas_value_tests : XCTestCase

@end

@implementation yas_value_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_make_value_by_move {
    auto const value = make_value(1.0);
    XCTAssertEqual(value.get<double>(), 1.0);
}

- (void)test_make_value_by_copy {
    double const val = 1.0;
    auto const value = make_value(val);
    XCTAssertEqual(value.get<double>(), val);
}

@end
