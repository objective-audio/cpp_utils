//
//  index_range_tests.mm
//

#import <XCTest/XCTest.h>
#include <cpp-utils/index_range.h>

using namespace yas;

@interface index_range_tests : XCTestCase

@end

@implementation index_range_tests

- (void)test_equal {
    index_range const index_range_1a{.index = 0, .length = 1};
    index_range const index_range_1b{.index = 0, .length = 1};
    index_range const index_range_2{.index = 1, .length = 1};
    index_range const index_range_3{.index = 0, .length = 2};

    XCTAssertTrue(index_range_1a == index_range_1a);
    XCTAssertTrue(index_range_1a == index_range_1b);
    XCTAssertFalse(index_range_1a == index_range_2);
    XCTAssertFalse(index_range_1a == index_range_3);

    XCTAssertFalse(index_range_1a != index_range_1a);
    XCTAssertFalse(index_range_1a != index_range_1b);
    XCTAssertTrue(index_range_1a != index_range_2);
    XCTAssertTrue(index_range_1a != index_range_3);
}

- (void)test_contains {
    index_range const index_range{.index = 1, .length = 2};

    XCTAssertFalse(index_range.contains(0));
    XCTAssertTrue(index_range.contains(1));
    XCTAssertTrue(index_range.contains(2));
    XCTAssertFalse(index_range.contains(3));
}

- (void)test_next {
    XCTAssertEqual((index_range{.index = 1, .length = 2}).next(), 3);
}

- (void)test_zero {
    XCTAssertEqual(index_range::zero(), (index_range{.index = 0, .length = 0}));
}

@end
