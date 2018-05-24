//
//  yas_flow_utils_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_flow_utils.h"

using namespace yas;

@interface yas_flow_utils_tests : XCTestCase

@end

@implementation yas_flow_utils_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_add {
    auto handler = flow::add(1);

    XCTAssertEqual(handler(1), 2);
    XCTAssertEqual(handler(2), 3);
}

- (void)test_add_diff_type {
    auto handler = flow::add<float>(int(1));

    XCTAssertEqual(handler(1.5f), 2.5f);
}

- (void)test_add_pair {
    auto handler = flow::add<int>();

    XCTAssertEqual(handler(std::make_pair(1, 2)), 3);
}

- (void)test_multiply {
    auto handler = flow::multiply(2);

    XCTAssertEqual(handler(1), 2);
    XCTAssertEqual(handler(2), 4);
}

- (void)test_multiply_diff_type {
    auto handler = flow::multiply<float>(int(2));

    XCTAssertEqual(handler(2.5f), 5.0f);
}

- (void)test_multiply_pair {
    auto handler = flow::multiply<int>();

    XCTAssertEqual(handler(std::make_pair(2, 3)), 6);
}

- (void)test_min {
    XCTAssertEqual(flow::min<int>()(std::make_pair(1, 2)), 1);
    XCTAssertEqual(flow::min<int>()(std::make_pair(2, 1)), 1);
    XCTAssertEqual(flow::min(1)(2), 1);
    XCTAssertEqual(flow::min(2)(1), 1);
}

- (void)test_max {
    XCTAssertEqual(flow::max<int>()(std::make_pair(1, 2)), 2);
    XCTAssertEqual(flow::max<int>()(std::make_pair(2, 1)), 2);
    XCTAssertEqual(flow::max(1)(2), 2);
    XCTAssertEqual(flow::max(2)(1), 2);
}

@end
