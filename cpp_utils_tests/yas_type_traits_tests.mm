//
//  yas_type_traits_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/yas_type_traits.h>

using namespace yas;

namespace yas::test {
template <typename T, enable_if_vector_t<T, std::nullptr_t> = nullptr>
bool is_vector(T const &) {
    return true;
}

template <typename T, disable_if_vector_t<T, std::nullptr_t> = nullptr>
bool is_vector(T const &) {
    return false;
}

template <typename T, enable_if_array_t<T, std::nullptr_t> = nullptr>
bool is_array(T const &) {
    return true;
}

template <typename T, disable_if_array_t<T, std::nullptr_t> = nullptr>
bool is_array(T const &) {
    return false;
}

template <typename T, enable_if_pair_t<T, std::nullptr_t> = nullptr>
bool is_pair(T const &) {
    return true;
}

template <typename T, disable_if_pair_t<T, std::nullptr_t> = nullptr>
bool is_pair(T const &) {
    return false;
}

template <typename T, enable_if_tuple_t<T, std::nullptr_t> = nullptr>
bool is_tuple(T const &) {
    return true;
}

template <typename T, disable_if_tuple_t<T, std::nullptr_t> = nullptr>
bool is_tuple(T const &) {
    return false;
}
}

@interface yas_type_traits_tests : XCTestCase

@end

@implementation yas_type_traits_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_is_vector {
    XCTAssertTrue(test::is_vector(std::vector<int>()));
    XCTAssertFalse(test::is_vector(int(0)));
}

- (void)test_is_array {
    XCTAssertTrue(test::is_array(std::array<int, 1>()));
    XCTAssertFalse(test::is_array(int(0)));
}

- (void)test_is_pair {
    XCTAssertTrue(test::is_pair(std::make_pair(1, 2)));
    XCTAssertFalse(test::is_pair(int(0)));
}

- (void)test_is_tuple {
    XCTAssertTrue(test::is_tuple(std::make_tuple(1, 2, 3)));
    XCTAssertFalse(test::is_tuple(int(0)));
}

@end
