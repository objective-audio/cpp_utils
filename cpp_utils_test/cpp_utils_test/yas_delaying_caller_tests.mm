//
//  yas_delaying_caller_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_delaying_caller.h"

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

    caller.request([&called]() { called = true; });

    XCTAssertTrue(called);
}

- (void)test_call_delayed {
    delaying_caller caller;

    bool called_1 = false;
    bool called_2 = false;

    caller.push();

    caller.request([&called_1]() { called_1 = true; });

    XCTAssertFalse(called_1);
    XCTAssertFalse(called_2);

    caller.push();

    XCTAssertFalse(called_1);
    XCTAssertFalse(called_2);

    caller.request([&called_2]() { called_2 = true; });

    XCTAssertFalse(called_1);
    XCTAssertFalse(called_2);

    caller.pop();

    XCTAssertFalse(called_1);
    XCTAssertFalse(called_2);

    caller.pop();

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
