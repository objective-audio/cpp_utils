//
//  yas_lock_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_base.h"
#import "yas_tuple_utils.h"

using namespace yas;

@interface yas_tuple_utils_tests : XCTestCase

@end

@implementation yas_tuple_utils_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_is_true_all_values {
    bool bool_true_value = true;
    bool bool_false_value = false;
    int int_true_value = 1;
    int int_false_value = 0;

    XCTAssertTrue(is_true_all_values(std::make_tuple(bool_true_value, int_true_value)));
    XCTAssertFalse(is_true_all_values(std::make_tuple(bool_true_value, int_false_value)));
    XCTAssertFalse(is_true_all_values(std::make_tuple(bool_false_value, int_true_value)));
    XCTAssertFalse(is_true_all_values(std::make_tuple(bool_false_value, int_false_value)));
}

- (void)test_make_tuple_result {
    bool bool_true_value = true;
    bool bool_false_value = false;
    int int_true_value = 1;
    int int_false_value = 0;

    XCTAssertTrue(make_tuple_result(bool_true_value, int_true_value));
    XCTAssertFalse(make_tuple_result(bool_true_value, int_false_value));
    XCTAssertFalse(make_tuple_result(bool_false_value, int_true_value));
    XCTAssertFalse(make_tuple_result(bool_false_value, int_false_value));
}

@end
