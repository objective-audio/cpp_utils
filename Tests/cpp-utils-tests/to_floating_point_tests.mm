//
//  to_floating_point_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp-utils/to_floating_point.h>
#include <typeinfo>

using namespace yas;

@interface to_floating_point_tests : XCTestCase

@end

@implementation to_floating_point_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_to_float_from_string {
    XCTAssertEqual(to_float("0.0"), 0.0f);
    XCTAssertEqual(to_float("1.0"), 1.0f);
    XCTAssertEqual(to_float(""), 0.0f);
    XCTAssertEqual(to_float("abc"), 0.0f);

    XCTAssertTrue(typeid(to_float("1.0")) == typeid(float));
}

- (void)test_to_double_from_string {
    XCTAssertEqual(to_double("0.0"), 0.0);
    XCTAssertEqual(to_double("1.0"), 1.0);
    XCTAssertEqual(to_double(""), 0.0);
    XCTAssertEqual(to_double("abc"), 0.0);

    XCTAssertTrue(typeid(to_double("1.0")) == typeid(double));
}

@end
