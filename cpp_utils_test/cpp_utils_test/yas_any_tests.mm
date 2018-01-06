//
//  yas_any_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_any.h"

using namespace yas;

@interface yas_any_tests : XCTestCase

@end

@implementation yas_any_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_make_any_by_move {
    auto const value = make_any(1.0);
    XCTAssertEqual(value.get<double>(), 1.0);
}

- (void)test_make_any_by_copy {
    double const val = 1.0;
    auto const value = make_any(val);
    XCTAssertEqual(value.get<double>(), val);
}

@end
