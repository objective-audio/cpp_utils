//
//  yas_json_utils_tests.mm
//

#import <XCTest/XCTest.h>
#include <cpp_utils/yas_json_utils.h>

using namespace yas;

@interface yas_json_utils_tests : XCTestCase

@end

@implementation yas_json_utils_tests

- (void)setUp {
}

- (void)tearDown {
}

- (void)test_to_json_value_from_array {
    NSNumber *intNumber1 = @(1);
    NSNumber *intNumber2 = @(2);
    NSNumber *doubleNumber = @(0.5);
    NSString *string = @"test_string";
    NSArray *array = @[intNumber1, @[doubleNumber, string], @{@"integer2": intNumber2}];

    auto const root = json_utils::to_json_value(array);

    XCTAssertTrue(root.vector.has_value());
    auto const &root_vector = root.vector.value();
    XCTAssertEqual(root_vector.size(), 3);
    XCTAssertEqual(root_vector.at(0).integer.value(), 1);
    XCTAssertTrue(root_vector.at(1).vector.has_value());
    XCTAssertTrue(root_vector.at(2).map.has_value());

    auto const &child_vector = root_vector.at(1).vector.value();
    XCTAssertEqual(child_vector.size(), 2);
    XCTAssertEqual(child_vector.at(0).real.value(), 0.5);
    XCTAssertEqual(child_vector.at(1).string.value(), "test_string");

    auto const &map = root_vector.at(2).map.value();
    XCTAssertEqual(map.size(), 1);
    XCTAssertTrue(map.contains("integer2"));
    XCTAssertEqual(map.at("integer2").integer.value(), 2);
}

- (void)test_to_json_object_from_vector {
    json_value const integer_value1{int64_t(1)};
    json_value const integer_value2{int64_t(2)};
    json_value const double_value{0.5};
    json_value const string_value{"test_string"};
    json_value const vector_value{
        std::vector<json_value>{integer_value1, json_value{std::vector<json_value>{double_value, string_value}},
                                json_value{std::map<std::string, json_value>{{"integer2", integer_value2}}}}};

    id const root = json_utils::to_json_object(vector_value);

    XCTAssertNotNil(root);
    XCTAssertTrue([root isKindOfClass:[NSArray class]]);
    NSArray *const root_array = root;
    XCTAssertEqual(root_array.count, 3);
    XCTAssertEqualObjects(root_array[0], @(1));
    XCTAssertTrue([root_array[1] isKindOfClass:[NSArray class]]);
    XCTAssertTrue([root_array[2] isKindOfClass:[NSDictionary class]]);

    NSArray *child_array = root_array[1];
    XCTAssertEqual(child_array.count, 2);
    XCTAssertEqualObjects(child_array[0], @(0.5));
    XCTAssertEqualObjects(child_array[1], @"test_string");

    NSDictionary<NSString *, id> *child_dictionary = root_array[2];
    XCTAssertEqual(child_dictionary.count, 1);
    XCTAssertEqualObjects(child_dictionary[@"integer2"], @(2));
}

- (void)test_to_json_value_from_dictionary {
    NSNumber *intNumber1 = @(1);
    NSNumber *intNumber2 = @(2);
    NSNumber *doubleNumber = @(0.5);
    NSString *string = @"test_string";
    NSDictionary *dictionary =
        @{@"integer1": intNumber1, @"array": @[doubleNumber, string], @"dictionary": @{@"integer2": intNumber2}};

    auto const root = json_utils::to_json_value(dictionary);

    XCTAssertTrue(root.map.has_value());
    auto const &root_map = root.map.value();
    XCTAssertEqual(root_map.size(), 3);
    XCTAssertEqual(root_map.at("integer1").integer.value(), 1);
    XCTAssertTrue(root_map.at("array").vector.has_value());
    XCTAssertTrue(root_map.at("dictionary").map.has_value());

    auto const &vector = root_map.at("array").vector.value();
    XCTAssertEqual(vector.size(), 2);
    XCTAssertEqual(vector.at(0).real.value(), 0.5);
    XCTAssertEqual(vector.at(1).string.value(), "test_string");

    auto const &child_map = root_map.at("dictionary").map.value();
    XCTAssertEqual(child_map.size(), 1);
    XCTAssertEqual(child_map.at("integer2").integer.value(), 2);
}

- (void)test_to_json_object_from_map {
    json_value const integer_value1{int64_t(1)};
    json_value const integer_value2{int64_t(2)};
    json_value const double_value{0.5};
    json_value const string_value{"test_string"};
    json_value const map_value{std::map<std::string, json_value>{
        {"integer1", integer_value1},
        {"vector", json_value{std::vector<json_value>{double_value, string_value}}},
        {"map", json_value{std::map<std::string, json_value>{{"integer2", integer_value2}}}}}};

    id const root = json_utils::to_json_object(map_value);

    XCTAssertNotNil(root);
    XCTAssertTrue([root isKindOfClass:[NSDictionary class]]);
    NSDictionary<NSString *, id> *root_dictionary = root;
    XCTAssertEqual(root_dictionary.count, 3);
    XCTAssertEqualObjects(root_dictionary[@"integer1"], @(1));
    XCTAssertTrue([root_dictionary[@"vector"] isKindOfClass:[NSArray class]]);
    XCTAssertTrue([root_dictionary[@"map"] isKindOfClass:[NSDictionary class]]);

    NSArray *child_array = root_dictionary[@"vector"];
    XCTAssertEqual(child_array.count, 2);
    XCTAssertEqualObjects(child_array[0], @(0.5));
    XCTAssertEqualObjects(child_array[1], @"test_string");

    NSDictionary<NSString *, id> *child_dictionary = root_dictionary[@"map"];
    XCTAssertEqual(child_dictionary.count, 1);
    XCTAssertEqualObjects(child_dictionary[@"integer2"], @(2));
}

@end
