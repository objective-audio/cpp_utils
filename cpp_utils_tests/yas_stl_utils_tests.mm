//
//  yas_stl_utils_tests.m
//

#import <XCTest/XCTest.h>
#import <cpp_utils/yas_stl_utils.h>
#import <set>
#import <unordered_map>

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
    std::map<uint8_t, uint8_t> map;

    auto key = yas::min_empty_key(map);
    XCTAssertTrue(key);
    XCTAssertEqual(*key, 0);

    map.insert(std::make_pair(0, 0));

    key = yas::min_empty_key(map);
    XCTAssertTrue(key);
    XCTAssertEqual(*key, 1);
}

- (void)test_min_empty_key_insert_gappy {
    std::map<uint8_t, uint8_t> map;

    map.insert(std::make_pair(1, 1));

    auto key = yas::min_empty_key(map);
    XCTAssertTrue(key);
    XCTAssertEqual(*key, 0);
}

- (void)test_min_empty_key_filled {
    std::map<uint8_t, uint8_t> map;

    for (uint16_t i = 0; i < std::numeric_limits<uint8_t>::max(); ++i) {
        map.insert(std::make_pair(i, i));
    }

    auto key = yas::min_empty_key(map);
    XCTAssertFalse(key);
}

- (void)test_filter_vector {
    std::vector<int> vec{1, 4, 5, 3, 2};
    auto filtered_vec = yas::filter(vec, [](auto const &val) { return (val % 2) != 0; });

    XCTAssertEqual(filtered_vec.size(), 3);
    XCTAssertEqual(filtered_vec[0], 1);
    XCTAssertEqual(filtered_vec[1], 5);
    XCTAssertEqual(filtered_vec[2], 3);
}

- (void)test_filter_map {
    std::map<int, int> map{{0, 12}, {1, 11}, {2, 10}, {3, 9}, {4, 8}};
    auto filtered_map = yas::filter(map, [](auto const &pair) { return (pair.second % 2) != 0; });

    XCTAssertEqual(filtered_map.size(), 2);

    XCTAssertEqual(filtered_map.at(1), 11);
    XCTAssertEqual(filtered_map.at(3), 9);

    XCTAssertThrows(filtered_map.at(0));
    XCTAssertThrows(filtered_map.at(2));
    XCTAssertThrows(filtered_map.at(4));
}

- (void)test_first_vector {
    std::vector<int> vec{1, 2, 3, 4, 5};
    auto const first_value = yas::first(vec, [](auto const &val) { return val > 3; });

    XCTAssertEqual(first_value, 4);
}

- (void)test_first_vector_not_found {
    std::vector<int> vec{1, 2, 3, 4, 5};
    auto const first_value = yas::first(vec, [](auto const &val) { return val > 5; });

    XCTAssertFalse(first_value.has_value());
}

- (void)test_first_map {
    std::map<int, int> map{{0, 12}, {1, 11}, {2, 10}, {3, 9}, {4, 8}};
    auto const first_value = yas::first(map, [](auto const &pair) { return pair.second <= 10; });

    XCTAssertTrue(first_value.has_value());
    XCTAssertEqual(first_value->first, 2);
    XCTAssertEqual(first_value->second, 10);
}

- (void)test_first_map_not_found {
    std::map<int, int> map{{0, 12}, {1, 11}, {2, 10}, {3, 9}, {4, 8}};
    auto const first_value = yas::first(map, [](auto const &pair) { return pair.second < 8; });

    XCTAssertFalse(first_value.has_value());
}

- (void)test_erase_at {
    std::vector<int> vec{4, 1, 6, 7};

    yas::erase_at(vec, 2);

    XCTAssertEqual(vec.size(), 3);
    XCTAssertEqual(vec.at(0), 4);
    XCTAssertEqual(vec.at(1), 1);
    XCTAssertEqual(vec.at(2), 7);
}

- (void)test_erase_if_set {
    std::unordered_set<int> set{0, 1, 2, 3, 4};
    yas::erase_if(set, [](auto const &val) { return (val % 2) != 0; });

    XCTAssertEqual(set.size(), 3);

    XCTAssertTrue(set.count(0));
    XCTAssertFalse(set.count(1));
    XCTAssertTrue(set.count(2));
    XCTAssertFalse(set.count(3));
    XCTAssertTrue(set.count(4));
}

- (void)test_erase_if_vector {
    std::vector<int> vec{2, 5, 1, 0, 10};

    yas::erase_if(vec, [](auto const &val) { return val < 5; });

    XCTAssertEqual(vec.size(), 2);

    XCTAssertEqual(vec.at(0), 5);
    XCTAssertEqual(vec.at(1), 10);
}

- (void)test_erase_if_exists {
    std::unordered_map<int, std::string> map{{1, "1"}, {2, "2"}, {3, "3"}};
    yas::erase_if_exists(map, 2);

    XCTAssertEqual(map.size(), 2);
    XCTAssertEqual(map.count(1), 1);
    XCTAssertEqual(map.count(2), 0);
    XCTAssertEqual(map.count(3), 1);
}

- (void)test_for_each {
    int count = 0;
    int sum = 0;

    std::vector<int> vec{3, 6, 9};

    yas::for_each(vec, [&count, &sum](auto &it) {
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

- (void)test_move_back_insert {
    std::vector<std::string> vec_a{"a", "b"};
    std::vector<std::string> vec_b{"c", "d"};

    yas::move_back_insert(vec_a, std::move(vec_b));

    XCTAssertEqual(vec_a.size(), 4);
    XCTAssertEqual(vec_a.at(0), "a");
    XCTAssertEqual(vec_a.at(1), "b");
    XCTAssertEqual(vec_a.at(2), "c");
    XCTAssertEqual(vec_a.at(3), "d");

    XCTAssertEqual(vec_b.size(), 0);
}

- (void)test_move_insert_map {
    std::unordered_map<std::string, int> map_a{{"a", 1}, {"b", 2}};
    std::unordered_map<std::string, int> map_b{{"c", 3}, {"d", 4}};

    yas::move_insert(map_a, std::move(map_b));

    XCTAssertEqual(map_a.size(), 4);
    XCTAssertEqual(map_a.count("a"), 1);
    XCTAssertEqual(map_a.count("b"), 1);
    XCTAssertEqual(map_a.count("c"), 1);
    XCTAssertEqual(map_a.count("d"), 1);
    XCTAssertEqual(map_a.at("a"), 1);
    XCTAssertEqual(map_a.at("b"), 2);
    XCTAssertEqual(map_a.at("c"), 3);
    XCTAssertEqual(map_a.at("d"), 4);

    XCTAssertEqual(map_b.size(), 0);
}

- (void)test_pull {
    std::unordered_map<std::string, int> map{{"a", 1}, {"b", 2}, {"c", 3}};

    auto b_value = yas::pull(map, std::string("b"));

    XCTAssertEqual(b_value, 2);
    XCTAssertEqual(map.size(), 2);
    XCTAssertEqual(map.count("b"), 0);
}

- (void)test_move_from_map {
    std::unordered_map<std::string, int> map{{"a", 1}, {"b", 2}, {"c", 3}};
    std::unordered_map<std::string, int> map2;

    yas::move_insert(map2, map, "b");

    XCTAssertEqual(map.size(), 2);
    XCTAssertEqual(map2.size(), 1);

    XCTAssertEqual(map.count("b"), 0);
    XCTAssertEqual(map2.count("b"), 1);

    XCTAssertEqual(map2.at("b"), 2);
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

- (void)test_replaced_double {
    auto source = "src_text_src_text";
    auto destination = yas::replaced(source, "src", "dst");
    XCTAssertEqual(destination, "dst_text_dst_text");
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

- (void)test_replaced_move {
    std::string source = "a_text_a_text_a";
    std::string target = "a";
    std::string replacement = "b";
    std::string destination = yas::replaced(std::move(source), target, replacement);
    XCTAssertEqual(destination, "b_text_b_text_b");
    XCTAssertEqual(source.size(), 0);
}

- (void)test_joined {
    std::vector<std::string> components{"abc", "def", "ghi"};
    auto joined = yas::joined(components, "-");

    XCTAssertEqual(joined, "abc-def-ghi");
}

- (void)test_joined_integer_set {
    std::set<int> components{1, 2, 3};
    auto joined = yas::joined(components, "-", [](int const &val) { return std::to_string(val); });

    XCTAssertEqual(joined.size(), 5);
    XCTAssertEqual(joined.at(0), '1');
    XCTAssertEqual(joined.at(1), '-');
    XCTAssertEqual(joined.at(2), '2');
    XCTAssertEqual(joined.at(3), '-');
    XCTAssertEqual(joined.at(4), '3');
}

- (void)test_to_vector {
    std::vector<int> vector{0, 1, 2};
    auto mapped = yas::to_vector<int>(std::move(vector), [](int const &obj) { return obj + 1; });

    XCTAssertEqual(mapped.size(), 3);
    XCTAssertEqual(mapped.at(0), 1);
    XCTAssertEqual(mapped.at(1), 2);
    XCTAssertEqual(mapped.at(2), 3);
}

- (void)test_to_vector_different_return_t {
    std::vector<int> vector{0, 1, 2};
    auto mapped =
        yas::to_vector<std::string>(std::move(vector), [](int const &obj) { return std::to_string(obj + 1); });

    XCTAssertEqual(mapped.size(), 3);
    XCTAssertEqual(mapped.at(0), "1");
    XCTAssertEqual(mapped.at(1), "2");
    XCTAssertEqual(mapped.at(2), "3");
}

- (void)test_replace {
    std::unordered_map<int, std::string> map{{1, "1"}, {2, "2"}, {3, "3"}};
    std::string value{"two"};

    yas::replace(map, 2, std::move(value));

    XCTAssertEqual(map.size(), 3);
    XCTAssertEqual(map.count(2), 1);
    XCTAssertEqual(map.at(2), "two");

    XCTAssertEqual(map.count(1), 1);
    XCTAssertEqual(map.at(1), "1");
    XCTAssertEqual(map.count(3), 1);
    XCTAssertEqual(map.at(3), "3");

    XCTAssertEqual(value.size(), 0);
}

- (void)test_to_map {
    std::vector<std::string> vec{"a", "b", "c"};

    std::size_t idx = 0;
    auto map = yas::to_map<std::size_t>(std::move(vec), [&idx](auto &value) { return idx++; });

    XCTAssertEqual(map.size(), 3);
    XCTAssertEqual(map.at(0), "a");
    XCTAssertEqual(map.at(1), "b");
    XCTAssertEqual(map.at(2), "c");
}

- (void)test_to_weak {
    auto shared = std::make_shared<int>(99);
    std::weak_ptr<int> weak = yas::to_weak(shared);

    auto shared_from_weak = weak.lock();
    XCTAssertTrue(shared_from_weak);
    XCTAssertEqual(*shared_from_weak, 99);

    XCTAssertFalse(weak.expired());

    shared_from_weak.reset();

    XCTAssertFalse(weak.expired());

    shared.reset();

    XCTAssertTrue(weak.expired());
}

- (void)test_to_weak_rvalue {
    struct test_class {
        int value = 98;
    };

    auto shared = std::make_shared<test_class>();
    auto weak = yas::to_weak(shared);
    auto shared_from_weak = weak.lock();

    XCTAssertTrue(shared_from_weak);
    XCTAssertEqual(shared_from_weak->value, 98);
}

- (void)test_index {
    std::vector<int> vector{3, 25, 1, 0, -1};

    auto index_of_1 = yas::index(vector, 1);
    XCTAssertTrue(index_of_1);
    XCTAssertEqual(*index_of_1, 2);

    auto index_of_2 = yas::index(vector, 2);
    XCTAssertFalse(index_of_2);
}

- (void)test_to_unordered_set_from_vector {
    std::vector<int> vector{2, 4, 6};

    auto set = yas::to_unordered_set(std::move(vector));

    XCTAssertEqual(set.size(), 3);

    yas::erase_if(set, [](auto const &val) { return val == 2; });

    XCTAssertEqual(set.size(), 2);

    yas::erase_if(set, [](auto const &val) { return val == 4; });

    XCTAssertEqual(set.size(), 1);

    yas::erase_if(set, [](auto const &val) { return val == 6; });

    XCTAssertEqual(set.size(), 0);
}

- (void)test_contains {
    std::vector<std::string> vec{"a"};

    XCTAssertTrue(yas::contains(vec, std::string("a")));
    XCTAssertFalse(yas::contains(vec, std::string("")));
    XCTAssertFalse(yas::contains(vec, std::string("b")));
}

- (void)test_split {
    std::string text = "a,b,cd,efg";

    std::vector<std::string> splited = yas::split(text, ',');

    XCTAssertEqual(splited.size(), 4);
    XCTAssertEqual(splited.at(0), "a");
    XCTAssertEqual(splited.at(1), "b");
    XCTAssertEqual(splited.at(2), "cd");
    XCTAssertEqual(splited.at(3), "efg");
}

- (void)test_split_2 {
    std::string text = ",1,";

    std::vector<std::string> splited = yas::split(text, ',');

    XCTAssertEqual(splited.size(), 2);
    XCTAssertEqual(splited.at(0), "");
    XCTAssertEqual(splited.at(1), "1");
}

- (void)test_array_to_tuple {
    std::array<int, 3> array{1, 2, 3};

    auto tuple = yas::to_tuple<int, 3>(array);

    XCTAssertEqual(std::get<0>(tuple), 1);
    XCTAssertEqual(std::get<1>(tuple), 2);
    XCTAssertEqual(std::get<2>(tuple), 3);
}

- (void)test_vector_to_tuple {
    std::vector<int> vector{1, 2, 3};

    auto tuple = yas::to_tuple<int, 3>(vector);

    XCTAssertEqual(std::get<0>(tuple), 1);
    XCTAssertEqual(std::get<1>(tuple), 2);
    XCTAssertEqual(std::get<2>(tuple), 3);
}

- (void)test_lock_values {
    auto value1 = std::make_shared<int>(1);
    auto value2 = std::make_shared<int>(2);
    auto value3 = std::make_shared<int>(3);

    std::map<int, std::weak_ptr<int>> map{{1, value1}, {2, value2}, {3, value3}};

    value2.reset();

    auto locked = yas::lock_values(map);

    XCTAssertEqual(locked.size(), 2);
    XCTAssertEqual(*locked.at(1), 1);
    XCTAssertEqual(*locked.at(3), 3);
}

@end
