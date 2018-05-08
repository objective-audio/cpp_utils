//
//  yas_fast_each_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_fast_each.h"
#import <array>
#import <vector>

using namespace yas;

@interface yas_fast_each_tests : XCTestCase

@end

@implementation yas_fast_each_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark -

- (void)test_create_fast_each_index_with_end {
    auto each = fast_each<int16_t>{4};

    XCTAssertEqual(each._index, 0);
    XCTAssertEqual(each._next, 0);
    XCTAssertEqual(each._end, 4);
}

- (void)test_create_fast_each_index_with_range {
    auto each = fast_each<int16_t>{1, 3};

    XCTAssertEqual(each._index, 1);
    XCTAssertEqual(each._next, 1);
    XCTAssertEqual(each._end, 3);
}

- (void)test_make_fast_each_index_with_end {
    int32_t end = 3;
    auto each = make_fast_each(end);

    XCTAssertEqual(each._index, 0);
    XCTAssertEqual(each._next, 0);
    XCTAssertEqual(each._end, 3);
}

- (void)test_make_fast_each_index_with_range {
    int32_t start = 1;
    int32_t end = 3;
    auto each = make_fast_each(start, end);

    XCTAssertEqual(each._index, 1);
    XCTAssertEqual(each._next, 1);
    XCTAssertEqual(each._end, 3);
}

- (void)test_fast_each_index_next {
    auto each = fast_each<int16_t>{5, 7};

    XCTAssertTrue(yas_each_next(each));

    XCTAssertEqual(yas_each_index(each), 5);

    XCTAssertTrue(yas_each_next(each));

    XCTAssertEqual(yas_each_index(each), 6);

    XCTAssertFalse(yas_each_next(each));
}

- (void)test_fast_each_index_stop {
    auto each = fast_each<int16_t>{10};

    auto count = 0;

    while (yas_each_next(each)) {
        if (yas_each_index(each) == 5) {
            yas_each_stop(each);
        }

        ++count;
    }

    XCTAssertEqual(count, 6);
}

- (void)test_fast_each_index_reset {
    auto each = fast_each<int16_t>{2};

    XCTAssertTrue(yas_each_next(each));
    XCTAssertTrue(yas_each_next(each));
    XCTAssertFalse(yas_each_next(each));

    each.reset(3);

    XCTAssertEqual(yas_each_index(each), 0);
    XCTAssertTrue(yas_each_next(each));
    XCTAssertTrue(yas_each_next(each));
    XCTAssertTrue(yas_each_next(each));
    XCTAssertFalse(yas_each_next(each));
}

- (void)test_fast_each_index_reset_with_range {
    auto each = fast_each<int16_t>{1, 3};

    XCTAssertEqual(yas_each_index(each), 1);
    XCTAssertTrue(yas_each_next(each));
    XCTAssertEqual(yas_each_index(each), 1);
    XCTAssertTrue(yas_each_next(each));
    XCTAssertEqual(yas_each_index(each), 2);
    XCTAssertFalse(yas_each_next(each));

    each.reset(10, 12);

    XCTAssertEqual(yas_each_index(each), 10);
    XCTAssertTrue(yas_each_next(each));
    XCTAssertEqual(yas_each_index(each), 10);
    XCTAssertTrue(yas_each_next(each));
    XCTAssertEqual(yas_each_index(each), 11);
    XCTAssertFalse(yas_each_next(each));
}

#pragma mark -

- (void)test_create_fast_each_pointer {
    std::array<int16_t, 2> array{0, 1};
    auto each = fast_each<int16_t *>{array.data(), array.size()};

    XCTAssertEqual(each._ptr, array.data());
    XCTAssertEqual(each._index, 0);
    XCTAssertEqual(each._end, 2);
    XCTAssertEqual(each._next, 0);
}

- (void)test_create_fast_each_nullptr {
    fast_each<int8_t *> each{};

    XCTAssertFalse(each._ptr);
    XCTAssertEqual(each._index, 0);
    XCTAssertEqual(each._end, 0);
    XCTAssertEqual(each._next, 0);
}

- (void)test_make_fast_each_pointer {
    std::array<int16_t, 2> array{0, 1};
    auto each = make_fast_each_ptr(array.data(), array.size());

    XCTAssertEqual(each._ptr, array.data());
    XCTAssertEqual(each._index, 0);
    XCTAssertEqual(each._end, 2);
}

- (void)test_fast_each_pointer_next {
    std::array<int16_t, 3> array{5, 6, 7};
    auto each = make_fast_each_ptr(array.data(), array.size());

    XCTAssertTrue(yas_each_next(each));

    XCTAssertEqual(yas_each_index(each), 0);
    XCTAssertEqual(yas_each_value(each), 5);
    XCTAssertEqual(&yas_each_value(each), &array[0]);

    XCTAssertTrue(yas_each_next(each));

    XCTAssertEqual(yas_each_index(each), 1);
    XCTAssertEqual(yas_each_value(each), 6);
    XCTAssertEqual(&yas_each_value(each), &array[1]);

    XCTAssertTrue(yas_each_next(each));

    XCTAssertEqual(yas_each_index(each), 2);
    XCTAssertEqual(yas_each_value(each), 7);
    XCTAssertEqual(&yas_each_value(each), &array[2]);

    XCTAssertFalse(yas_each_next(each));
}

- (void)test_fast_each_pointer_stop {
    std::array<int16_t, 3> array{0, 1, 2};
    auto each = make_fast_each_ptr(array.data(), array.size());

    auto count = 0;
    auto last_value = -1;

    while (yas_each_next(each)) {
        if (yas_each_index(each) == 1) {
            yas_each_stop(each);
        }

        last_value = yas_each_value(each);

        ++count;
    }

    XCTAssertEqual(count, 2);
    XCTAssertEqual(last_value, 1);
}

- (void)test_fast_each_pointer_write {
    std::vector<int8_t> vec;
    vec.resize(4, 0);

    auto each = make_fast_each_ptr(vec.data(), vec.size());

    while (yas_each_next(each)) {
        yas_each_value(each) = yas_each_index(each);
    }

    XCTAssertEqual(vec[0], 0);
    XCTAssertEqual(vec[1], 1);
    XCTAssertEqual(vec[2], 2);
    XCTAssertEqual(vec[3], 3);
}

- (void)test_fast_each_ptr {
    std::vector<int8_t> vec{1, 2};

    auto each = make_fast_each_ptr(vec.data(), vec.size());

    yas_each_next(each);
    XCTAssertEqual(yas_each_ptr(each)[0], 1);
    XCTAssertEqual(yas_each_ptr(each)[1], 2);
}

- (void)test_fast_each_ptr_reset {
    std::vector<int8_t> vec{1, 2, 3};

    auto each = make_fast_each_ptr(vec.data(), vec.size());

    XCTAssertTrue(yas_each_next(each));
    XCTAssertEqual(yas_each_value(each), 1);
    XCTAssertTrue(yas_each_next(each));
    XCTAssertEqual(yas_each_value(each), 2);
    XCTAssertTrue(yas_each_next(each));
    XCTAssertEqual(yas_each_value(each), 3);
    XCTAssertFalse(yas_each_next(each));

    std::vector<int8_t> vec2{5, 6};

    each.reset(vec2.data(), vec2.size());

    XCTAssertTrue(yas_each_next(each));
    XCTAssertEqual(yas_each_value(each), 5);
    XCTAssertTrue(yas_each_next(each));
    XCTAssertEqual(yas_each_value(each), 6);
    XCTAssertFalse(yas_each_next(each));
}

@end
