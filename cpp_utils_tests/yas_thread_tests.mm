//
//  yas_thread_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/cpp_utils.h>
#import <future>

using namespace yas;

@interface yas_thread_tests : XCTestCase

@end

@implementation yas_thread_tests

- (void)setUp {
}

- (void)tearDown {
}

- (void)test_is_main {
    XCTAssertTrue(thread::is_main());

    std::promise<bool> promise;
    auto future = promise.get_future();

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL),
                   [&promise] { promise.set_value(thread::is_main()); });

    XCTAssertFalse(future.get());
}

- (void)test_sleep_for_timeinterval {
    CFAbsoluteTime begin = CFAbsoluteTimeGetCurrent();

    thread::sleep_for_timeinterval(0.5);

    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();

    XCTAssertGreaterThan((end - begin), 0.4);
}

- (void)test_perform_on_main {
    auto expectation = [self expectationWithDescription:@""];

    thread::perform_on_main([&expectation] {
        XCTAssertTrue(thread::is_main());
        [expectation fulfill];
    });

    [self waitForExpectations:@[expectation] timeout:10.0];
}

@end
