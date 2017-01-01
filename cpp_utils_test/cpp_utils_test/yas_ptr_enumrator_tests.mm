//
//  yas_ptr_enumerator_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_ptr_enumerator.h"

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
    int64_t array[4];
    array[0] = 0;
    array[1] = 1;
    array[2] = 2;
    array[3] = 3;

    auto enumerator = ptr_enumerator<int64_t>{array, 4};

    XCTAssertTrue(enumerator.index());
    XCTAssertEqual(*enumerator.index(), 0);
    XCTAssertTrue(*enumerator.ptr() == array);
    XCTAssertEqual(enumerator.length, 4);
}

- (void)test_read {
    int64_t array[4];
    array[0] = 0;
    array[1] = 1;
    array[2] = 2;
    array[3] = 3;

    auto enumerator = ptr_enumerator<int64_t>{array, 4};
    auto const *const *enum_ptr = enumerator.ptr();
    auto const *idx = enumerator.index();

    while (*enum_ptr) {
        XCTAssertEqual(**enum_ptr, *idx);

        ++enumerator;
    }

    XCTAssertEqual(*idx, 4);
}

- (void)test_write {
    int64_t array[4];
    array[0] = -1;
    array[1] = -1;
    array[2] = -1;
    array[3] = -1;

    auto enumerator = ptr_enumerator<int64_t>{array, 4};
    auto *const *enum_ptr = enumerator.ptr();
    auto const *idx = enumerator.index();

    while (*enum_ptr) {
        **enum_ptr = *idx;

        ++enumerator;
    }

    XCTAssertEqual(array[0], 0);
    XCTAssertEqual(array[1], 1);
    XCTAssertEqual(array[2], 2);
    XCTAssertEqual(array[3], 3);
}

- (void)test_stop {
    int64_t array[4];

    auto enumerator = ptr_enumerator<int64_t>{array, 4};
    auto *const *enum_ptr = enumerator.ptr();
    auto const *idx = enumerator.index();

    auto count = 0;

    while (*enum_ptr) {
        ++enumerator;
        ++count;

        if (*idx == 1) {
            enumerator.stop();
        }
    }

    XCTAssertEqual(count, 1);
    XCTAssertFalse(*enumerator.ptr());
    XCTAssertEqual(*enumerator.index(), 4);
}

- (void)test_reset {
    int64_t array[4];

    auto enumerator = ptr_enumerator<int64_t>{array, 4};
    auto *const *enum_ptr = enumerator.ptr();

    while (*enum_ptr) {
        ++enumerator;
    }

    enumerator.reset();

    XCTAssertTrue(*enumerator.ptr() == array);
    XCTAssertEqual(*enumerator.index(), 0);
}

- (void)test_set_index {
    int64_t array[4];

    auto enumerator = ptr_enumerator<int64_t>{array, 4};

    XCTAssertNoThrow(enumerator.set_index(2));

    XCTAssertEqual(*enumerator.index(), 2);

    XCTAssertThrows(enumerator.set_index(4));
}

- (void)test_move_by_macro {
    int64_t array[4];
    array[0] = 0;
    array[1] = 1;
    array[2] = 2;
    array[3] = 3;

    auto enumerator = ptr_enumerator<int64_t>{array, 4};
    auto const *const *enum_ptr = enumerator.ptr();
    auto const *idx = enumerator.index();

    while (*enum_ptr) {
        XCTAssertEqual(**enum_ptr, *idx);

        yas_ptr_enumerator_move(enumerator);
    }

    XCTAssertEqual(*idx, 4);
}

- (void)test_stop_by_macro {
    int64_t array[4];

    auto enumerator = ptr_enumerator<int64_t>{array, 4};
    auto *const *enum_ptr = enumerator.ptr();
    auto const *idx = enumerator.index();

    auto count = 0;

    while (*enum_ptr) {
        yas_ptr_enumerator_move(enumerator);
        ++count;

        if (*idx == 1) {
            yas_ptr_enumerator_stop(enumerator);
        }
    }

    XCTAssertEqual(count, 1);
    XCTAssertFalse(*enumerator.ptr());
    XCTAssertEqual(*enumerator.index(), 4);
}

- (void)test_reset_by_macro {
    int64_t array[4];

    auto enumerator = ptr_enumerator<int64_t>{array, 4};
    auto *const *enum_ptr = enumerator.ptr();

    while (*enum_ptr) {
        yas_ptr_enumerator_move(enumerator);
    }

    yas_ptr_enumerator_reset(enumerator);

    XCTAssertTrue(*enumerator.ptr() == array);
    XCTAssertEqual(*enumerator.index(), 0);
}

@end
