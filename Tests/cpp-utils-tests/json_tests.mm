//
//  json_tests.mm
//

#import <XCTest/XCTest.h>
#include <cpp-utils/json.h>

using namespace yas;

@interface json_tests : XCTestCase

@end

@implementation json_tests

- (void)setUp {
}

- (void)tearDown {
}

- (void)test_to_json_string_from_vector {
    json_value const integer_value{int64_t{1}};
    json_value const string_value{"test_value"};
    json_value const vector_value{json_vector{integer_value, string_value}};

    auto const json_string = to_json_string(vector_value);

    XCTAssertEqual(json_string, "[1,\"test_value\"]");
}

- (void)test_to_json_string_from_map {
    json_value const integer_value{int64_t{1}};
    json_value const string_value{"test_value"};
    json_value const map_value{json_map{{"integer", integer_value}, {"string", string_value}}};

    auto const json_string = to_json_string(map_value);

    XCTAssertEqual(json_string, "{\"integer\":1,\"string\":\"test_value\"}");
}

- (void)test_to_json_value_from_array {
    auto const json_value = to_json_value("[1,\"test_value\"]");

    XCTAssertTrue(json_value.vector.has_value());
    auto const &vector_value = json_value.vector.value();
    XCTAssertEqual(vector_value.at(0).integer.value(), 1);
    XCTAssertEqual(vector_value.at(1).string.value(), "test_value");
}

- (void)test_to_json_value_from_dictionary {
    auto const json_value = to_json_value("{\"integer\":1,\"string\":\"test_value\"}");

    XCTAssertTrue(json_value.map.has_value());
    auto const &map_value = json_value.map.value();
    XCTAssertEqual(map_value.at("integer").integer.value(), 1);
    XCTAssertEqual(map_value.at("string").string.value(), "test_value");
}

@end
