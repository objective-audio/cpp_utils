//
//  types_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp-utils/umbrella.hpp>
#import <optional>

using namespace yas;

@interface types_tests : XCTestCase

@end

@implementation types_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_is_equal_optional_values {
    std::optional<int> value_1_a{1};
    std::optional<int> value_1_b{1};
    std::optional<int> value_2{2};
    std::optional<int> value_null_a{std::nullopt};
    std::optional<int> value_null_b{std::nullopt};

    XCTAssertTrue(value_1_a == value_1_b);
    XCTAssertFalse(value_1_a == value_2);
    XCTAssertFalse(value_1_a == value_null_a);
    XCTAssertTrue(value_null_a == value_null_b);
}

@end
