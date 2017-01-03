//
//  yas_fast_each_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_fast_each.h"

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

- (void)test_create_with_end {
    auto each = fast_each<int16_t>{4};

    XCTAssertEqual(each._index, 0);
    XCTAssertEqual(each._next, 0);
    XCTAssertEqual(each._end, 4);
}

- (void)test_create_with_range {
    auto each = fast_each<int16_t>{1, 3};

    XCTAssertEqual(each._index, 1);
    XCTAssertEqual(each._next, 1);
    XCTAssertEqual(each._end, 3);
}

- (void)test_next {
    auto each = fast_each<int16_t>{5, 7};
    
    XCTAssertTrue(yas_fast_each_next(each));
    
    XCTAssertEqual(yas_fast_each_index(each), 5);
    
    XCTAssertTrue(yas_fast_each_next(each));
    
    XCTAssertEqual(yas_fast_each_index(each), 6);
    
    XCTAssertFalse(yas_fast_each_next(each));
}

- (void)test_stop {
    auto each = fast_each<int16_t>{10};

    auto count = 0;

    while (yas_fast_each_next(each)) {
        if (yas_fast_each_index(each) == 5) {
            yas_fast_each_stop(each)
        }

        ++count;
    }

    XCTAssertEqual(count, 6);
}

@end
