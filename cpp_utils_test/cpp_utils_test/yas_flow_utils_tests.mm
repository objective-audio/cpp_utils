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

- (void)test_multiply {
    auto handler = flow::multiply(2);

    XCTAssertEqual(handler(1), 2);
    XCTAssertEqual(handler(2), 4);
}

@end
