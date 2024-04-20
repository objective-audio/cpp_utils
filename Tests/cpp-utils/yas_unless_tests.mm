//
//  yas_unless_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp-utils/yas_unless.h>

@interface yas_unless_tests : XCTestCase

@end

@implementation yas_unless_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_unless_from_false {
    auto rev_flag = yas::unless(false);

    XCTAssertTrue(rev_flag);
    XCTAssertFalse(rev_flag.value);
}

- (void)test_unless_from_true {
    auto rev_flag = yas::unless(true);

    XCTAssertFalse(rev_flag);
    XCTAssertTrue(rev_flag.value);
}

- (void)test_unless_shared_null_ptr {
    std::shared_ptr<std::string> str_ptr;

    auto rev_null_ptr = yas::unless(std::move(str_ptr));
    XCTAssertTrue(rev_null_ptr);
    XCTAssertFalse(rev_null_ptr.value);
    XCTAssertEqual(rev_null_ptr.value, nullptr);
}

- (void)test_unless_shared_str_ptr {
    auto rev_str_ptr = yas::unless(std::make_shared<std::string>("test_str"));
    XCTAssertFalse(rev_str_ptr);
    XCTAssertTrue(rev_str_ptr.value);
    XCTAssertEqual(*rev_str_ptr.value, "test_str");
}

- (void)test_unless_shared_str_ptr_move {
    auto rev_str_ptr = yas::unless(std::make_shared<std::string>("test_str"));
    auto moved_str = std::move(rev_str_ptr.value);

    XCTAssertTrue(rev_str_ptr);
    XCTAssertFalse(rev_str_ptr.value);
    XCTAssertEqual(rev_str_ptr.value, nullptr);
}

@end
