//
//  yas_operation_tests.m
//

#import <XCTest/XCTest.h>
#import <future>
#include <thread>
#import "yas_operation.h"

using namespace std::chrono_literals;

@interface yas_operation_tests : XCTestCase

@end

@implementation yas_operation_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_call_one_operation {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    yas::operation_queue queue;
    yas::operation operation([exe_ex](const yas::operation &ope) { [exe_ex fulfill]; });
    queue.push_back(operation);

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)test_call_many_operation {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    std::atomic<int> count;
    count = 0;

    yas::operation_queue queue;

    yas::operation operation_1([self, &count, exe_ex](const yas::operation &op) {
        XCTAssertEqual(count.load(), 0);
        ++count;
    });
    yas::operation operation_2([self, &count, exe_ex](const yas::operation &op) {
        XCTAssertEqual(count.load(), 1);
        ++count;
    });
    yas::operation operation_3([self, &count, exe_ex](const yas::operation &op) {
        XCTAssertEqual(count.load(), 2);
        ++count;
        [exe_ex fulfill];
    });

    queue.push_back(operation_1);
    queue.push_back(operation_2);
    queue.push_back(operation_3);

    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    XCTAssertEqual(count.load(), 3);
}

- (void)test_suspend {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    yas::operation_queue queue;

    queue.suspend();

    bool called = false;

    yas::operation operation([&called, exe_ex](const yas::operation &ope) {
        called = true;
        [exe_ex fulfill];
    });

    queue.push_back(operation);

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(called);

    queue.resume();

    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    XCTAssertTrue(called);
}

- (void)test_insert_to_top {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    std::atomic<int> count;
    count = 0;

    yas::operation_queue queue;

    queue.suspend();

    yas::operation operation_1([self, &count, exe_ex](const yas::operation &op) {
        XCTAssertEqual(count.load(), 0);
        ++count;
    });
    yas::operation operation_2([self, &count, exe_ex](const yas::operation &op) {
        XCTAssertEqual(count.load(), 1);
        ++count;
    });
    yas::operation operation_3([self, &count, exe_ex](const yas::operation &op) {
        XCTAssertEqual(count.load(), 2);
        ++count;
        [exe_ex fulfill];
    });

    queue.push_back(operation_3);
    queue.push_front(operation_2);
    queue.push_front(operation_1);

    queue.resume();

    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    XCTAssertEqual(count.load(), 3);
}

- (void)test_operation_cancel {
    yas::operation_queue queue;

    queue.suspend();

    bool called = false;

    yas::operation operation([&called](const yas::operation &op) { called = true; });

    queue.push_back(operation);

    operation.cancel();

    queue.resume();

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(called);
}

- (void)test_cancel_operation_from_queue {
    yas::operation_queue queue;

    queue.suspend();

    bool called = false;

    yas::operation operation([&called](const yas::operation &op) { called = true; });

    queue.push_back(operation);

    queue.cancel(operation);

    queue.resume();

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(called);
}

- (void)test_cancel_current_operation {
    yas::operation_queue queue;

    queue.suspend();

    std::promise<void> start_promise;
    std::promise<void> wait_promise;
    std::promise<bool> end_promise;

    auto start_future = start_promise.get_future();
    auto wait_future = wait_promise.get_future();
    auto end_future = end_promise.get_future();

    yas::operation operation([self, &start_promise, &wait_future, &end_promise](const yas::operation &op) {
        start_promise.set_value();
        wait_future.get();
        end_promise.set_value(op.is_canceled());
    });

    queue.push_back(operation);
    queue.resume();

    start_future.get();

    queue.cancel(operation);

    wait_promise.set_value();

    XCTAssertTrue(end_future.get());
}

- (void)test_null_created {
    yas::operation_queue queue{nullptr};
    yas::operation operation{nullptr};

    XCTAssertFalse(queue);
    XCTAssertFalse(operation);
}

- (void)test_priority {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    std::atomic<int> count;
    count = 0;

    yas::operation_queue queue{3};

    queue.suspend();

    yas::operation operation_1a(
        [self, &count](const yas::operation &op) {
            XCTAssertEqual(count.load(), 0);
            ++count;
        },
        {.priority = 0});
    yas::operation operation_1b(
        [self, &count](const yas::operation &op) {
            XCTAssertEqual(count.load(), 1);
            ++count;
        },
        {.priority = 0});
    yas::operation operation_2a(
        [self, &count](const yas::operation &op) {
            XCTAssertEqual(count.load(), 2);
            ++count;
        },
        {.priority = 1});
    yas::operation operation_2b(
        [self, &count](const yas::operation &op) {
            XCTAssertEqual(count.load(), 3);
            ++count;
        },
        {.priority = 1});
    yas::operation operation_3a(
        [self, &count](const yas::operation &op) {
            XCTAssertEqual(count.load(), 4);
            ++count;
        },
        {.priority = 2});
    yas::operation operation_3b(
        [self, &count, exe_ex](const yas::operation &op) {
            XCTAssertEqual(count.load(), 5);
            ++count;
            [exe_ex fulfill];
        },
        {.priority = 2});

    queue.push_back(operation_3a);
    queue.push_back(operation_2a);
    queue.push_back(operation_1a);
    queue.push_back(operation_3b);
    queue.push_back(operation_2b);
    queue.push_back(operation_1b);

    queue.resume();

    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    XCTAssertEqual(count.load(), 6);
}

- (void)test_wait {
    yas::operation_queue queue;

    queue.suspend();

    bool called = false;

    yas::operation operation([&called](const yas::operation &op) {
        std::this_thread::sleep_for(100ms);

        called = true;
    });

    queue.push_back(operation);

    queue.resume();

    queue.wait_until_all_operations_are_finished();

    XCTAssertTrue(called);
}

- (void)test_wait_failed {
    yas::operation_queue queue;

    queue.suspend();

    yas::operation operation([](const yas::operation &op) {});

    queue.push_back(operation);

    XCTAssertThrows(queue.wait_until_all_operations_are_finished());
}

@end
