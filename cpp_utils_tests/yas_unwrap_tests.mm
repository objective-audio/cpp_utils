//
//  yas_unwrap_tests.mm
//

#import <XCTest/XCTest.h>
#include <cpp_utils/yas_unwrap.h>
#include <string>

using namespace yas;

@interface yas_unwrap_tests : XCTestCase

@end

@implementation yas_unwrap_tests

- (void)test_has_values {
    std::optional<int> constexpr int_value{1};
    std::optional<std::string> const str_value{"2"};
    std::optional<int> null_int_value{std::nullopt};
    std::optional<std::string> null_str_value{std::nullopt};

    XCTAssertTrue(yas::has_values(int_value));
    XCTAssertTrue(yas::has_values(str_value));
    XCTAssertTrue(yas::has_values(int_value, str_value));
    XCTAssertTrue(yas::has_values(str_value, int_value));

    XCTAssertFalse(yas::has_values(int_value, str_value, null_int_value));
    XCTAssertFalse(yas::has_values(int_value, null_int_value, str_value));
    XCTAssertFalse(yas::has_values(null_int_value, int_value, str_value));
    XCTAssertFalse(yas::has_values(int_value, null_int_value));
    XCTAssertFalse(yas::has_values(str_value, null_int_value));
    XCTAssertFalse(yas::has_values(null_int_value, int_value));
    XCTAssertFalse(yas::has_values(null_int_value));
    XCTAssertFalse(yas::has_values(null_int_value, null_str_value));
}

- (void)test_unwrap {
    std::optional<int> constexpr int_value{1};
    std::optional<std::string> const str_value{"2"};

    {
        auto const unwrapped = yas::unwrap(int_value);
        auto const &[unwrapped_int_value] = unwrapped;
        XCTAssertEqual(unwrapped_int_value, 1);
    }

    {
        auto const unwrapped = yas::unwrap(int_value, str_value);
        auto const &[unwrapped_int_value, unwrapped_str_value] = unwrapped;
        XCTAssertEqual(unwrapped_int_value, 1);
        XCTAssertEqual(unwrapped_str_value, "2");
    }
}

@end
