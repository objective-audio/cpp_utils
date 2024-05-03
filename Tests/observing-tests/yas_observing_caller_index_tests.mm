//
//  yas_observing_caller_index_tests.mm
//

#import <XCTest/XCTest.h>
#import <observing/yas_observing_caller_index.hpp>

using namespace yas;

@interface yas_observing_caller_index_tests : XCTestCase

@end

@implementation yas_observing_caller_index_tests

- (void)test_less_than {
    observing::caller_index const index0_0{.identifier = 0, .order = 0};
    observing::caller_index const index1_0{.identifier = 1, .order = 0};
    observing::caller_index const index0_1{.identifier = 0, .order = 1};
    observing::caller_index const index1_1{.identifier = 1, .order = 1};

    XCTAssertTrue(index0_0 < index1_0);
    XCTAssertTrue(index0_0 < index0_1);
    XCTAssertTrue(index0_0 < index1_1);

    XCTAssertFalse(index1_0 < index0_0);
    XCTAssertTrue(index1_0 < index0_1);
    XCTAssertTrue(index1_0 < index1_1);

    XCTAssertFalse(index0_1 < index0_0);
    XCTAssertFalse(index0_1 < index1_0);
    XCTAssertTrue(index0_1 < index1_1);

    XCTAssertFalse(index1_1 < index0_0);
    XCTAssertFalse(index1_1 < index1_0);
    XCTAssertFalse(index1_1 < index0_1);
}

@end
