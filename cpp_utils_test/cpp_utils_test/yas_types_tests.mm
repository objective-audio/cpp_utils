//
//  yas_types_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_types.h"

using namespace yas;

@interface yas_types_tests : XCTestCase

@end

@implementation yas_types_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_is_equal_optional_values {
    std::experimental::optional<int> value_1_a{1};
    std::experimental::optional<int> value_1_b{1};
    std::experimental::optional<int> value_2{2};
    std::experimental::optional<int> value_null_a{nullopt};
    std::experimental::optional<int> value_null_b{nullopt};

    XCTAssertTrue(value_1_a == value_1_b);
    XCTAssertFalse(value_1_a == value_2);
    XCTAssertFalse(value_1_a == value_null_a);
    XCTAssertTrue(value_null_a == value_null_b);
}

@end
