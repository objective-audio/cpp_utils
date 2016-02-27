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

- (void)test_cancel_by_push_cancel_id {
    yas::operation_queue queue;

    yas::base cancel_id_a{nullptr};
    yas::base cancel_id_b{nullptr};
    cancel_id_a.set_impl_ptr(std::make_shared<yas::base::impl>());
    cancel_id_b.set_impl_ptr(std::make_shared<yas::base::impl>());

    bool called_a_1 = false;
    bool called_a_2 = false;
    bool called_b = false;
    bool called_n_1 = false;
    bool called_n_2 = false;

    yas::operation op_a_1{[&called_a_1](auto const &op) { called_a_1 = true; }, {.push_cancel_id = cancel_id_a}};
    yas::operation op_a_2{[&called_a_2](auto const &op) { called_a_2 = true; }, {.push_cancel_id = cancel_id_a}};
    yas::operation op_b{[&called_b](auto const &op) { called_b = true; }, {.push_cancel_id = cancel_id_b}};
    yas::operation op_n_1{[&called_n_1](auto const &op) { called_n_1 = true; }};
    yas::operation op_n_2{[&called_n_2](auto const &op) { called_n_2 = true; }};

    queue.suspend();

    queue.push_back(std::move(op_a_1));
    queue.push_back(std::move(op_b));
    queue.push_back(std::move(op_n_1));
    queue.push_back(std::move(op_a_2));
    queue.push_back(std::move(op_n_2));

    queue.resume();

    queue.wait_until_all_operations_are_finished();

    XCTAssertFalse(called_a_1);
    XCTAssertTrue(called_a_2);
    XCTAssertTrue(called_b);
    XCTAssertTrue(called_n_1);
    XCTAssertTrue(called_n_2);
}

- (void)test_cancel_different_priority {
    yas::operation_queue queue{2};

    yas::base cancel_id{nullptr};
    cancel_id.set_impl_ptr(std::make_shared<yas::base::impl>());

    bool called_1 = false;
    bool called_2 = false;

    yas::operation op_1{[&called_1](auto const &op) { called_1 = true; }, {.priority = 0, .push_cancel_id = cancel_id}};
    yas::operation op_2{[&called_2](auto const &op) { called_2 = true; }, {.priority = 1, .push_cancel_id = cancel_id}};

    queue.suspend();

    queue.push_back(std::move(op_1));
    queue.push_back(std::move(op_2));

    queue.resume();

    queue.wait_until_all_operations_are_finished();

    XCTAssertFalse(called_1);
    XCTAssertTrue(called_2);
}

@end
