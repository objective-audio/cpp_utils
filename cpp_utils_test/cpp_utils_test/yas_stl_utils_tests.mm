//
//  yas_stl_utils_tests.m
//

#import <XCTest/XCTest.h>
#import <iostream>
#import <set>
#import "yas_stl_utils.h"

@interface yas_stl_utils_tests : XCTestCase

@end

@implementation yas_stl_utils_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_min_empty_key_insert {
    std::map<UInt8, UInt8> map;

    auto key = yas::min_empty_key(map);
    XCTAssertTrue(key);
    XCTAssertEqual(*key, 0);

    map.insert(std::make_pair(0, 0));

    key = yas::min_empty_key(map);
    XCTAssertTrue(key);
    XCTAssertEqual(*key, 1);
}

- (void)test_min_empty_key_insert_gappy {
    std::map<UInt8, UInt8> map;

    map.insert(std::make_pair(1, 1));

    auto key = yas::min_empty_key(map);
    XCTAssertTrue(key);
    XCTAssertEqual(*key, 0);
}

- (void)test_min_empty_key_filled {
    std::map<UInt8, UInt8> map;

    for (UInt16 i = 0; i < std::numeric_limits<UInt8>::max(); ++i) {
        map.insert(std::make_pair(i, i));
    }

    auto key = yas::min_empty_key(map);
    XCTAssertFalse(key);
}

- (void)test_filter_vector {
    std::vector<int> vec{1, 4, 5, 3, 2};
    auto filtered_vec = yas::filter(vec, [](const auto &val) { return (val % 2) != 0; });

    XCTAssertEqual(filtered_vec.size(), 3);
    XCTAssertEqual(filtered_vec[0], 1);
    XCTAssertEqual(filtered_vec[1], 5);
    XCTAssertEqual(filtered_vec[2], 3);
}

- (void)test_filter_map {
    std::map<int, int> map{{0, 12}, {1, 11}, {2, 10}, {3, 9}, {4, 8}};
    auto filtered_map = yas::filter(map, [](const auto &pair) { return (pair.second % 2) != 0; });

    XCTAssertEqual(filtered_map.size(), 2);

    XCTAssertEqual(filtered_map.at(1), 11);
    XCTAssertEqual(filtered_map.at(3), 9);

    XCTAssertThrows(filtered_map.at(0));
    XCTAssertThrows(filtered_map.at(2));
    XCTAssertThrows(filtered_map.at(4));
}

- (void)test_erase_if {
    std::unordered_set<int> set{0, 1, 2, 3, 4};
    yas::erase_if(set, [](const auto &val) { return (val % 2) != 0; });

    XCTAssertEqual(set.size(), 3);

    XCTAssertTrue(set.count(0));
    XCTAssertFalse(set.count(1));
    XCTAssertTrue(set.count(2));
    XCTAssertFalse(set.count(3));
    XCTAssertTrue(set.count(4));
}

- (void)test_enumerate {
    int count = 0;
    int sum = 0;

    std::vector<int> vec{3, 6, 9};

    yas::enumerate(vec, [&count, &sum](auto &it) {
        ++count;
        sum += *it;
        return ++it;
    });

    XCTAssertEqual(count, 3);
    XCTAssertEqual(sum, (3 + 6 + 9));
}

- (void)test_connect_vector {
    std::vector<std::string> vec_a{"a", "b"};
    std::vector<std::string> vec_b{"c", "d"};

    auto vec_c = yas::connect(std::move(vec_a), std::move(vec_b));

    XCTAssertEqual(vec_c.size(), 4);
    XCTAssertEqual(vec_c.at(0), "a");
    XCTAssertEqual(vec_c.at(1), "b");
    XCTAssertEqual(vec_c.at(2), "c");
    XCTAssertEqual(vec_c.at(3), "d");

    XCTAssertEqual(vec_a.size(), 0);
    XCTAssertEqual(vec_b.size(), 0);
}

- (void)test_unordered_set_to_vector {
    std::unordered_set<int> set{1, 3, 5};
    auto vec = yas::to_vector(set);

    XCTAssertEqual(set.size(), 3);
    XCTAssertEqual(vec.size(), 3);

    for (auto const &val : vec) {
        XCTAssertTrue(set.count(val));
        if (set.count(val)) {
            set.erase(val);
        }
    }

    XCTAssertEqual(set.size(), 0);
}

- (void)test_to_lower {
    auto str1 = "aBcDeFgH";
    auto str2 = "abcdefgh";

    XCTAssertTrue(yas::to_lower(str1) == str2);
}

- (void)test_to_lower_move {
    std::string str1 = "aBcDeFgH";
    std::string str2 = "abcdefgh";
    
    XCTAssertTrue(yas::to_lower(std::move(str1)) == str2);
    
    XCTAssertEqual(str1.size(), 0);
}

- (void)test_replaced {
    auto source = "source_text";
    auto destination = yas::replaced(source, "source", "destination");
    XCTAssertEqual(destination, "destination_text");
}

- (void)test_replaced_plural {
    auto source = "a_text_a_text_a";
    auto destination = yas::replaced(source, "a", "b");
    XCTAssertEqual(destination, "b_text_b_text_b");
}

- (void)test_replaced_empty {
    auto source = "";
    auto destination = yas::replaced(source, "a", "b");
    XCTAssertEqual(destination, "");
}

- (void)test_joined {
    std::vector<std::string> components{"abc", "def", "ghi"};
    auto joined = yas::joined(components, "-");

    XCTAssertEqual(joined, "abc-def-ghi");
}

- (void)test_joined_integer_set {
    std::set<int> components{1, 2, 3};
    auto joined = yas::joined(components, "-", [](int const &val) { return std::to_string(val); });

    std::cout << joined << std::endl;

    XCTAssertEqual(joined.size(), 5);
    XCTAssertEqual(joined.at(0), '1');
    XCTAssertEqual(joined.at(1), '-');
    XCTAssertEqual(joined.at(2), '2');
    XCTAssertEqual(joined.at(3), '-');
    XCTAssertEqual(joined.at(4), '3');
}

- (void)test_map {
    std::vector<int> vector{0, 1, 2};
    auto mapped = yas::map<int>(vector, [](int const &obj) { return obj + 1; });

    XCTAssertEqual(mapped.size(), 3);
    XCTAssertEqual(mapped.at(0), 1);
    XCTAssertEqual(mapped.at(1), 2);
    XCTAssertEqual(mapped.at(2), 3);
}

- (void)test_map_different_return_type {
    std::vector<int> vector{0, 1, 2};
    auto mapped = yas::map<std::string>(vector, [](int const &obj) { return std::to_string(obj + 1); });

    XCTAssertEqual(mapped.size(), 3);
    XCTAssertEqual(mapped.at(0), "1");
    XCTAssertEqual(mapped.at(1), "2");
    XCTAssertEqual(mapped.at(2), "3");
}

@end
