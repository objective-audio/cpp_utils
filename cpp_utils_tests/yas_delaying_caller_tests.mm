//
//  yas_delaying_caller_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/cpp_utils.h>

using namespace yas;

@interface yas_delaying_caller_tests : XCTestCase

@end

@implementation yas_delaying_caller_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_call_immediately {
    delaying_caller caller;

    bool called = false;

    XCTAssertFalse(caller.is_suspending());

    caller.request([&called]() { called = true; });

    XCTAssertTrue(called);
}

- (void)test_call_delayed {
    delaying_caller caller;

    bool called_1 = false;
    bool called_2 = false;

    XCTAssertFalse(caller.is_suspending());

    caller.push();

    XCTAssertTrue(caller.is_suspending());

    caller.request([&called_1]() { called_1 = true; });

    XCTAssertFalse(called_1);
    XCTAssertFalse(called_2);

    caller.push();

    XCTAssertTrue(caller.is_suspending());
    XCTAssertFalse(called_1);
    XCTAssertFalse(called_2);

    caller.request([&called_2]() { called_2 = true; });

    XCTAssertTrue(caller.is_suspending());
    XCTAssertFalse(called_1);
    XCTAssertFalse(called_2);

    caller.pop();

    XCTAssertTrue(caller.is_suspending());
    XCTAssertFalse(called_1);
    XCTAssertFalse(called_2);

    caller.pop();

    XCTAssertFalse(caller.is_suspending());
    XCTAssertFalse(called_1);
    XCTAssertTrue(called_2);
}

- (void)test_cancel {
    delaying_caller caller;

    bool called = false;

    caller.push();

    caller.request([&called]() { called = true; });

    caller.cancel();

    caller.pop();

    XCTAssertFalse(called);
}

@end
