//
//  yas_boolean_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_boolean.h"
#import <utility>

using namespace yas;

@interface yas_boolean_tests : XCTestCase

@end

@implementation yas_boolean_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_construct {
    boolean flag;

    XCTAssertFalse(flag);
}

- (void)test_copy_constructor {
    boolean true_flag{true};
    
    boolean flag{true_flag};
    
    XCTAssertTrue(flag);
}

- (void)test_move_constructor {
    boolean true_flag{true};
    
    boolean flag{std::move(true_flag)};
    
    XCTAssertTrue(flag);
}

- (void)test_construct_with_false {
    boolean flag{false};

    XCTAssertFalse(flag);
}

- (void)test_construct_with_true {
    boolean flag{true};

    XCTAssertTrue(flag);
}

- (void)test_copy_assign {
    boolean flag{false};
    boolean true_flag{true};
    
    flag = true_flag;
    
    XCTAssertTrue(flag);
}

- (void)test_move_assign {
    boolean flag{false};
    boolean true_flag{true};
    
    flag = std::move(true_flag);
    
    XCTAssertTrue(flag);
}

- (void)test_is_equal {
    boolean true_flag1 = true;
    boolean true_flag2 = true;
    boolean false_flag1 = false;
    boolean false_flag2 = false;

    XCTAssertTrue(true_flag1 == true_flag1);
    XCTAssertTrue(true_flag1 == true_flag2);
    XCTAssertTrue(false_flag1 == false_flag1);
    XCTAssertTrue(false_flag1 == false_flag2);

    XCTAssertFalse(true_flag1 == false_flag1);
    XCTAssertFalse(false_flag1 == true_flag1);
}

- (void)test_is_not_equal {
    boolean true_flag1 = true;
    boolean true_flag2 = true;
    boolean false_flag1 = false;
    boolean false_flag2 = false;
    
    XCTAssertFalse(true_flag1 != true_flag1);
    XCTAssertFalse(true_flag1 != true_flag2);
    XCTAssertFalse(false_flag1 != false_flag1);
    XCTAssertFalse(false_flag1 != false_flag2);
    
    XCTAssertTrue(true_flag1 != false_flag1);
    XCTAssertTrue(false_flag1 != true_flag1);
}

@end
