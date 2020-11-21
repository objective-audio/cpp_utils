//
//  yas_to_integer_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/cpp_utils.h>

using namespace yas;

@interface yas_to_integer_tests : XCTestCase

@end

@implementation yas_to_integer_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_to_int8_from_string {
    XCTAssertEqual(to_integer<int8_t>("0"), 0);
    XCTAssertEqual(to_integer<int8_t>("1"), 1);
    XCTAssertEqual(to_integer<int8_t>("127"), std::numeric_limits<int8_t>::max());
    XCTAssertEqual(to_integer<int8_t>("128"), 0);
    XCTAssertEqual(to_integer<int8_t>("-128"), std::numeric_limits<int8_t>::min());
    XCTAssertEqual(to_integer<int8_t>("-129"), 0);
    XCTAssertEqual(to_integer<int8_t>(""), 0);
    XCTAssertEqual(to_integer<int8_t>("abc"), 0);

    XCTAssertTrue(typeid(to_integer<int8_t>("1")) == typeid(int8_t));
}

- (void)test_to_uint8_from_string {
    XCTAssertEqual(to_integer<uint8_t>("0"), 0);
    XCTAssertEqual(to_integer<uint8_t>("1"), 1);
    XCTAssertEqual(to_integer<uint8_t>("255"), std::numeric_limits<uint8_t>::max());
    XCTAssertEqual(to_integer<uint8_t>("256"), 0);
    XCTAssertEqual(to_integer<uint8_t>("-1"), 0);
    XCTAssertEqual(to_integer<uint8_t>(""), 0);
    XCTAssertEqual(to_integer<uint8_t>("abc"), 0);

    XCTAssertTrue(typeid(to_integer<uint8_t>("1")) == typeid(uint8_t));
}

- (void)test_to_int16_from_string {
    XCTAssertEqual(to_integer<int16_t>("0"), 0);
    XCTAssertEqual(to_integer<int16_t>("1"), 1);
    XCTAssertEqual(to_integer<int16_t>("32767"), std::numeric_limits<int16_t>::max());
    XCTAssertEqual(to_integer<int16_t>("32768"), 0);
    XCTAssertEqual(to_integer<int16_t>("-32768"), std::numeric_limits<int16_t>::min());
    XCTAssertEqual(to_integer<int16_t>("-32769"), 0);
    XCTAssertEqual(to_integer<int16_t>(""), 0);
    XCTAssertEqual(to_integer<int16_t>("abc"), 0);

    XCTAssertTrue(typeid(to_integer<int16_t>("1")) == typeid(int16_t));
}

- (void)test_to_uint16_from_string {
    XCTAssertEqual(to_integer<uint16_t>("0"), 0);
    XCTAssertEqual(to_integer<uint16_t>("1"), 1);
    XCTAssertEqual(to_integer<uint16_t>("65535"), std::numeric_limits<uint16_t>::max());
    XCTAssertEqual(to_integer<uint16_t>("65536"), 0);
    XCTAssertEqual(to_integer<uint16_t>("-1"), 0);
    XCTAssertEqual(to_integer<uint16_t>(""), 0);
    XCTAssertEqual(to_integer<uint16_t>("abc"), 0);

    XCTAssertTrue(typeid(to_integer<uint16_t>("1")) == typeid(uint16_t));
}

- (void)test_to_int32_from_string {
    XCTAssertEqual(to_integer<int32_t>("0"), 0);
    XCTAssertEqual(to_integer<int32_t>("1"), 1);
    XCTAssertEqual(to_integer<int32_t>("2147483647"), std::numeric_limits<int32_t>::max());
    XCTAssertEqual(to_integer<int32_t>("2147483648"), 0);
    XCTAssertEqual(to_integer<int32_t>("-2147483648"), std::numeric_limits<int32_t>::min());
    XCTAssertEqual(to_integer<int32_t>("-2147483649"), 0);
    XCTAssertEqual(to_integer<int32_t>(""), 0);
    XCTAssertEqual(to_integer<int32_t>("abc"), 0);

    XCTAssertTrue(typeid(to_integer<int32_t>("1")) == typeid(int32_t));
}

- (void)test_to_uint32_from_string {
    XCTAssertEqual(to_integer<uint32_t>("0"), 0);
    XCTAssertEqual(to_integer<uint32_t>("1"), 1);
    XCTAssertEqual(to_integer<uint32_t>("4294967295"), std::numeric_limits<uint32_t>::max());
    XCTAssertEqual(to_integer<uint32_t>("4294967296"), 0);
    XCTAssertEqual(to_integer<uint32_t>("-1"), 0);
    XCTAssertEqual(to_integer<uint32_t>(""), 0);
    XCTAssertEqual(to_integer<uint32_t>("abc"), 0);

    XCTAssertTrue(typeid(to_integer<uint32_t>("1")) == typeid(uint32_t));
}

- (void)test_to_int64_from_string {
    XCTAssertEqual(to_integer<int64_t>("0"), 0);
    XCTAssertEqual(to_integer<int64_t>("1"), 1);
    XCTAssertEqual(to_integer<int64_t>("9223372036854775807"), std::numeric_limits<int64_t>::max());
    XCTAssertEqual(to_integer<int64_t>("9223372036854775808"), 0);
    XCTAssertEqual(to_integer<int64_t>("-9223372036854775808"), std::numeric_limits<int64_t>::min());
    XCTAssertEqual(to_integer<int64_t>("-9223372036854775809"), 0);
    XCTAssertEqual(to_integer<int64_t>(""), 0);
    XCTAssertEqual(to_integer<int64_t>("abc"), 0);

    XCTAssertTrue(typeid(to_integer<int64_t>("1")) == typeid(int64_t));
}

- (void)test_to_uint64_from_string {
    XCTAssertEqual(to_integer<uint64_t>("0"), 0);
    XCTAssertEqual(to_integer<uint64_t>("1"), 1);
    XCTAssertEqual(to_integer<uint64_t>("18446744073709551615"), std::numeric_limits<uint64_t>::max());
    XCTAssertEqual(to_integer<uint64_t>("18446744073709551616"), 0);
    XCTAssertEqual(to_integer<uint64_t>(""), 0);
    XCTAssertEqual(to_integer<uint64_t>("abc"), 0);

    XCTAssertTrue(typeid(to_integer<uint64_t>("1")) == typeid(uint64_t));
}

@end
