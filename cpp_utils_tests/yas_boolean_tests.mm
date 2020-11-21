//
//  yas_boolean_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/cpp_utils.h>
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

- (void)test_copy_constructor_with_bool {
    bool true_flag = true;
    boolean flag{true_flag};

    XCTAssertTrue(flag);
}

- (void)test_move_constructor_with_bool {
    bool true_flag = true;
    boolean flag{std::move(true_flag)};

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

- (void)test_greater {
    boolean true_flag1 = true;
    boolean true_flag2 = true;
    boolean false_flag1 = false;
    boolean false_flag2 = false;

    XCTAssertFalse(true_flag1 > true_flag1);
    XCTAssertFalse(true_flag1 > true_flag2);
    XCTAssertFalse(false_flag1 > false_flag1);
    XCTAssertFalse(false_flag1 > false_flag2);

    XCTAssertTrue(true_flag1 > false_flag1);
    XCTAssertFalse(false_flag1 > true_flag1);
}

- (void)test_greater_equal {
    boolean true_flag1 = true;
    boolean true_flag2 = true;
    boolean false_flag1 = false;
    boolean false_flag2 = false;

    XCTAssertTrue(true_flag1 >= true_flag1);
    XCTAssertTrue(true_flag1 >= true_flag2);
    XCTAssertTrue(false_flag1 >= false_flag1);
    XCTAssertTrue(false_flag1 >= false_flag2);

    XCTAssertTrue(true_flag1 >= false_flag1);
    XCTAssertFalse(false_flag1 >= true_flag1);
}

- (void)test_less {
    boolean true_flag1 = true;
    boolean true_flag2 = true;
    boolean false_flag1 = false;
    boolean false_flag2 = false;

    XCTAssertFalse(true_flag1 < true_flag1);
    XCTAssertFalse(true_flag1 < true_flag2);
    XCTAssertFalse(false_flag1 < false_flag1);
    XCTAssertFalse(false_flag1 < false_flag2);

    XCTAssertFalse(true_flag1 < false_flag1);
    XCTAssertTrue(false_flag1 < true_flag1);
}

- (void)test_less_equal {
    boolean true_flag1 = true;
    boolean true_flag2 = true;
    boolean false_flag1 = false;
    boolean false_flag2 = false;

    XCTAssertTrue(true_flag1 <= true_flag1);
    XCTAssertTrue(true_flag1 <= true_flag2);
    XCTAssertTrue(false_flag1 <= false_flag1);
    XCTAssertTrue(false_flag1 <= false_flag2);

    XCTAssertFalse(true_flag1 <= false_flag1);
    XCTAssertTrue(false_flag1 <= true_flag1);
}

- (void)test_raw {
    boolean true_flag = true;
    boolean false_flag = false;

    XCTAssertTrue(true_flag.raw());
    XCTAssertFalse(false_flag.raw());
}

- (void)test_to_string {
    boolean true_flag = true;
    boolean false_flag = false;

    XCTAssertEqual(to_string(true_flag), "true");
    XCTAssertEqual(to_string(false_flag), "false");
}

@end
