//
//  yas_ptr_enumerator_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_fast_each.h"
#import <array>

using namespace yas;

@interface yas_ptr_enumerator_tests : XCTestCase

@end

@implementation yas_ptr_enumerator_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_create {
    std::array<int64_t, 4> array{0, 1, 2, 3};

    auto enumerator = ptr_enumerator<int64_t>{array.data(), array.size()};

    XCTAssertTrue(enumerator.index_ptr());
    XCTAssertEqual(*enumerator.index_ptr(), 0);
    XCTAssertTrue(*enumerator.ptr_ptr() == array.data());
    XCTAssertEqual(enumerator.length, 4);
}

- (void)test_create_with_vector {
    std::vector<int64_t> vec{0, 1, 2};

    auto enumerator = ptr_enumerator<int64_t>{vec};

    XCTAssertEqual(*enumerator.ptr_ptr(), vec.data());
    XCTAssertEqual(enumerator.length, 3);
}

- (void)test_read {
    std::array<int64_t, 4> array{0, 1, 2, 3};

    auto enumerator = ptr_enumerator<int64_t>{array.data(), array.size()};
    auto const *const *ptr_ptr = enumerator.ptr_ptr();
    auto const *idx_ptr = enumerator.index_ptr();

    while (*ptr_ptr) {
        XCTAssertEqual(**ptr_ptr, *idx_ptr);

        ++enumerator;
    }

    XCTAssertEqual(*idx_ptr, 4);
}

- (void)test_write {
    std::array<int64_t, 4> array{-1, -1, -1, -1};

    auto enumerator = ptr_enumerator<int64_t>{array.data(), array.size()};
    auto *const *ptr_ptr = enumerator.ptr_ptr();
    auto const *idx_ptr = enumerator.index_ptr();

    while (*ptr_ptr) {
        **ptr_ptr = *idx_ptr;

        ++enumerator;
    }

    XCTAssertEqual(array[0], 0);
    XCTAssertEqual(array[1], 1);
    XCTAssertEqual(array[2], 2);
    XCTAssertEqual(array[3], 3);
}

- (void)test_stop {
    std::array<int64_t, 4> array;

    auto enumerator = ptr_enumerator<int64_t>{array.data(), array.size()};
    auto *const *ptr_ptr = enumerator.ptr_ptr();
    auto const *idx_ptr = enumerator.index_ptr();

    auto count = 0;

    while (*ptr_ptr) {
        ++enumerator;
        ++count;

        if (*idx_ptr == 1) {
            enumerator.stop();
        }
    }

    XCTAssertEqual(count, 1);
    XCTAssertFalse(*enumerator.ptr_ptr());
    XCTAssertEqual(*enumerator.index_ptr(), 4);
}

- (void)test_reset {
    std::array<int64_t, 4> array;

    auto enumerator = ptr_enumerator<int64_t>{array.data(), array.size()};
    auto *const *ptr_ptr = enumerator.ptr_ptr();

    while (*ptr_ptr) {
        ++enumerator;
    }

    enumerator.reset();

    XCTAssertTrue(*enumerator.ptr_ptr() == array.data());
    XCTAssertEqual(*enumerator.index_ptr(), 0);
}

- (void)test_set_index {
    std::array<int64_t, 4> array;

    auto enumerator = ptr_enumerator<int64_t>{array.data(), array.size()};

    XCTAssertNoThrow(enumerator.set_index(2));

    XCTAssertEqual(*enumerator.index_ptr(), 2);

    XCTAssertThrows(enumerator.set_index(4));
}

- (void)test_get_value {
    std::array<int64_t, 2> array{100, -100};

    auto enumerator = ptr_enumerator<int64_t>{array.data(), array.size()};

    XCTAssertEqual(enumerator.value(), 100);

    enumerator.move();

    XCTAssertEqual(enumerator.value(), -100);
}

- (void)test_const_get_value {
    std::array<int64_t, 2> array{100, -100};

    auto enumerator = ptr_enumerator<int64_t>{array.data(), array.size()};
    auto const &const_enumerator = enumerator;

    XCTAssertEqual(const_enumerator.value(), 100);

    enumerator.move();

    XCTAssertEqual(const_enumerator.value(), -100);
}

- (void)test_set_value_copy {
    std::array<int64_t, 2> array{0, 0};

    auto enumerator = ptr_enumerator<int64_t>{array.data(), array.size()};

    int64_t value = 123;

    enumerator.set_value(value);
    enumerator.move();

    value = 456;

    enumerator.set_value(value);

    XCTAssertEqual(array[0], 123);
    XCTAssertEqual(array[1], 456);
}

- (void)test_set_value_move {
    std::array<int64_t, 2> array{0, 0};

    auto enumerator = ptr_enumerator<int64_t>{array.data(), array.size()};

    enumerator.set_value(789);
    enumerator.move();
    enumerator.set_value(102);

    XCTAssertEqual(array[0], 789);
    XCTAssertEqual(array[1], 102);
}

- (void)test_get_index {
    std::array<int64_t, 2> array{0, 0};

    auto enumerator = ptr_enumerator<int64_t>{array.data(), array.size()};

    XCTAssertEqual(enumerator.index(), 0);

    enumerator.move();

    XCTAssertEqual(enumerator.index(), 1);
}

- (void)test_has_value {
    std::array<int64_t, 2> array{0, 0};

    auto enumerator = ptr_enumerator<int64_t>{array.data(), array.size()};

    XCTAssertTrue(enumerator.has_value());

    enumerator.move();

    XCTAssertTrue(enumerator.has_value());

    enumerator.move();

    XCTAssertFalse(enumerator.has_value());
}

- (void)test_move_by_macro {
    std::array<int64_t, 4> array{0, 1, 2, 3};

    auto enumerator = ptr_enumerator<int64_t>{array.data(), array.size()};
    auto const *const *ptr_ptr = enumerator.ptr_ptr();
    auto const *idx_ptr = enumerator.index_ptr();

    while (*ptr_ptr) {
        XCTAssertEqual(**ptr_ptr, *idx_ptr);

        yas_ptr_enumerator_move(enumerator);
    }

    XCTAssertEqual(*idx_ptr, 4);
}

- (void)test_stop_by_macro {
    std::array<int64_t, 4> array;

    auto enumerator = ptr_enumerator<int64_t>{array.data(), array.size()};
    auto *const *ptr_ptr = enumerator.ptr_ptr();
    auto const *idx_ptr = enumerator.index_ptr();

    auto count = 0;

    while (*ptr_ptr) {
        yas_ptr_enumerator_move(enumerator);
        ++count;

        if (*idx_ptr == 1) {
            yas_ptr_enumerator_stop(enumerator);
        }
    }

    XCTAssertEqual(count, 1);
    XCTAssertFalse(*enumerator.ptr_ptr());
    XCTAssertEqual(*enumerator.index_ptr(), 4);
}

- (void)test_reset_by_macro {
    std::array<int64_t, 4> array;

    auto enumerator = ptr_enumerator<int64_t>{array.data(), array.size()};
    auto *const *ptr_ptr = enumerator.ptr_ptr();

    while (*ptr_ptr) {
        yas_ptr_enumerator_move(enumerator);
    }

    yas_ptr_enumerator_reset(enumerator);

    XCTAssertTrue(*enumerator.ptr_ptr() == array.data());
    XCTAssertEqual(*enumerator.index_ptr(), 0);
}

- (void)test_get_value_by_macro {
    std::array<int64_t, 2> array{100, -100};

    auto enumerator = ptr_enumerator<int64_t>{array.data(), array.size()};

    XCTAssertEqual(yas_ptr_enumerator_value(enumerator), 100);

    yas_ptr_enumerator_move(enumerator);

    XCTAssertEqual(yas_ptr_enumerator_value(enumerator), -100);
}

- (void)test_set_value_by_macro {
    std::array<int64_t, 2> array{0, 0};

    auto enumerator = ptr_enumerator<int64_t>{array.data(), array.size()};

    yas_ptr_enumerator_value(enumerator) = 789;
    yas_ptr_enumerator_move(enumerator);
    yas_ptr_enumerator_value(enumerator) = 102;

    XCTAssertEqual(array[0], 789);
    XCTAssertEqual(array[1], 102);
}

- (void)test_get_index_by_macro {
    std::array<int64_t, 2> array{0, 0};

    auto enumerator = ptr_enumerator<int64_t>{array.data(), array.size()};

    XCTAssertEqual(enumerator.index(), 0);

    enumerator.move();

    XCTAssertEqual(enumerator.index(), 1);
}

- (void)test_has_value_by_macro {
    std::array<int64_t, 2> array{0, 0};

    auto enumerator = ptr_enumerator<int64_t>{array.data(), array.size()};

    XCTAssertTrue(yas_ptr_enumerator_has_value(enumerator));

    enumerator.move();

    XCTAssertTrue(yas_ptr_enumerator_has_value(enumerator));

    enumerator.move();

    XCTAssertFalse(yas_ptr_enumerator_has_value(enumerator));
}

@end
