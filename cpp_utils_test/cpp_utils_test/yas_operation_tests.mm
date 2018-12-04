//
//  yas_operation_tests.m
//

#import <XCTest/XCTest.h>
#import <future>
#include <thread>
#import "yas_operation.h"

using namespace std::chrono_literals;
using namespace yas;

namespace yas {
struct test_cancel_id : base {
    struct impl : base::impl {};
    test_cancel_id() : base(std::make_shared<impl>()) {
    }
};
}

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

    operation_queue queue;
    operation op([exe_ex](operation const &) { [exe_ex fulfill]; });
    queue.push_back(op);

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)test_call_many_operation {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    std::atomic<int> count;
    count = 0;

    operation_queue queue;

    operation operation_1([self, &count, exe_ex](operation const &op) {
        XCTAssertEqual(count.load(), 0);
        ++count;
    });
    operation operation_2([self, &count, exe_ex](operation const &op) {
        XCTAssertEqual(count.load(), 1);
        ++count;
    });
    operation operation_3([self, &count, exe_ex](operation const &op) {
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

    operation_queue queue;

    queue.suspend();

    bool called = false;

    operation op([&called, exe_ex](operation const &) {
        called = true;
        [exe_ex fulfill];
    });

    queue.push_back(op);

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(called);

    queue.resume();

    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    XCTAssertTrue(called);
}

- (void)test_is_suspended {
    operation_queue queue;

    queue.suspend();

    XCTAssertTrue(queue.is_suspended());

    queue.resume();

    XCTAssertFalse(queue.is_suspended());
}

- (void)test_insert_to_top {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    std::atomic<int> count;
    count = 0;

    operation_queue queue;

    queue.suspend();

    operation operation_1([self, &count, exe_ex](operation const &op) {
        XCTAssertEqual(count.load(), 0);
        ++count;
    });
    operation operation_2([self, &count, exe_ex](operation const &op) {
        XCTAssertEqual(count.load(), 1);
        ++count;
    });
    operation operation_3([self, &count, exe_ex](operation const &op) {
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
    operation_queue queue;

    queue.suspend();

    bool called = false;

    operation op([&called](operation const &) { called = true; });

    queue.push_back(op);

    op.cancel();

    queue.resume();

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(called);
}

- (void)test_cancel_operation_from_queue {
    operation_queue queue;

    queue.suspend();

    bool called = false;

    operation op([&called](operation const &) { called = true; });

    queue.push_back(op);

    queue.cancel(op);

    queue.resume();

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(called);
}

- (void)test_cancel_current_operation {
    operation_queue queue;

    queue.suspend();

    std::promise<void> start_promise;
    std::promise<void> wait_promise;
    std::promise<bool> end_promise;

    auto start_future = start_promise.get_future();
    auto wait_future = wait_promise.get_future();
    auto end_future = end_promise.get_future();

    operation op([self, &start_promise, &wait_future, &end_promise](operation const &op) {
        start_promise.set_value();
        wait_future.get();
        end_promise.set_value(op.is_canceled());
    });

    queue.push_back(op);
    queue.resume();

    start_future.get();

    queue.cancel(op);

    wait_promise.set_value();

    XCTAssertTrue(end_future.get());
}

- (void)test_cancel_for_id {
    operation_queue queue;

    queue.suspend();

    bool called = false;

    test_cancel_id identifier;
    operation op([&called](operation const &) { called = true; }, {.identifier = identifier});

    queue.push_back(op);

    queue.cancel_for_id(identifier);

    queue.resume();

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(called);
}

- (void)test_cancel_for_id_current_operation {
    operation_queue queue;

    queue.suspend();

    std::promise<void> start_promise;
    std::promise<void> wait_promise;
    std::promise<bool> end_promise;

    auto start_future = start_promise.get_future();
    auto wait_future = wait_promise.get_future();
    auto end_future = end_promise.get_future();

    test_cancel_id identifier;
    operation op(
        [self, &start_promise, &wait_future, &end_promise](operation const &op) {
            start_promise.set_value();
            wait_future.get();
            end_promise.set_value(op.is_canceled());
        },
        {.identifier = identifier});

    queue.push_back(op);
    queue.resume();

    start_future.get();

    queue.cancel_for_id(identifier);

    wait_promise.set_value();

    XCTAssertTrue(end_future.get());
}

- (void)test_null_created {
    operation_queue queue{nullptr};
    operation operation{nullptr};

    XCTAssertFalse(queue);
    XCTAssertFalse(operation);
}

- (void)test_priority {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    std::atomic<int> count;
    count = 0;

    operation_queue queue{3};

    queue.suspend();

    operation operation_1a(
        [self, &count](operation const &op) {
            XCTAssertEqual(count.load(), 0);
            ++count;
        },
        {.priority = 0});
    operation operation_1b(
        [self, &count](operation const &op) {
            XCTAssertEqual(count.load(), 1);
            ++count;
        },
        {.priority = 0});
    operation operation_2a(
        [self, &count](operation const &op) {
            XCTAssertEqual(count.load(), 2);
            ++count;
        },
        {.priority = 1});
    operation operation_2b(
        [self, &count](operation const &op) {
            XCTAssertEqual(count.load(), 3);
            ++count;
        },
        {.priority = 1});
    operation operation_3a(
        [self, &count](operation const &op) {
            XCTAssertEqual(count.load(), 4);
            ++count;
        },
        {.priority = 2});
    operation operation_3b(
        [self, &count, exe_ex](operation const &op) {
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
    operation_queue queue;

    queue.suspend();

    bool called = false;

    operation op([&called](operation const &) {
        std::this_thread::sleep_for(100ms);

        called = true;
    });

    queue.push_back(op);

    queue.resume();

    queue.wait_until_all_operations_are_finished();

    XCTAssertTrue(called);
}

- (void)test_wait_failed {
    operation_queue queue;

    queue.suspend();

    operation op([](operation const &) {});

    queue.push_back(op);

    XCTAssertThrows(queue.wait_until_all_operations_are_finished());
}

- (void)test_cancel_by_push_cancel_id {
    operation_queue queue;

    base cancel_id_a{nullptr};
    base cancel_id_b{nullptr};
    cancel_id_a.set_impl_ptr(std::make_shared<base::impl>());
    cancel_id_b.set_impl_ptr(std::make_shared<base::impl>());

    bool called_a_1 = false;
    bool called_a_2 = false;
    bool called_b = false;
    bool called_n_1 = false;
    bool called_n_2 = false;

    operation op_a_1{[&called_a_1](auto const &op) { called_a_1 = true; }, {.push_cancel_id = cancel_id_a}};
    operation op_a_2{[&called_a_2](auto const &op) { called_a_2 = true; }, {.push_cancel_id = cancel_id_a}};
    operation op_b{[&called_b](auto const &op) { called_b = true; }, {.push_cancel_id = cancel_id_b}};
    operation op_n_1{[&called_n_1](auto const &op) { called_n_1 = true; }};
    operation op_n_2{[&called_n_2](auto const &op) { called_n_2 = true; }};

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
    operation_queue queue{2};

    base cancel_id{nullptr};
    cancel_id.set_impl_ptr(std::make_shared<base::impl>());

    bool called_1 = false;
    bool called_2 = false;

    operation op_1{[&called_1](auto const &op) { called_1 = true; }, {.priority = 0, .push_cancel_id = cancel_id}};
    operation op_2{[&called_2](auto const &op) { called_2 = true; }, {.priority = 1, .push_cancel_id = cancel_id}};

    queue.suspend();

    queue.push_back(std::move(op_1));
    queue.push_back(std::move(op_2));

    queue.resume();

    queue.wait_until_all_operations_are_finished();

    XCTAssertFalse(called_1);
    XCTAssertTrue(called_2);
}

- (void)test_is_operating_by_current_operation {
    operation_queue queue{1};

    XCTAssertFalse(queue.is_operating());

    std::promise<void> promise;
    auto future = promise.get_future();

    operation op{[&future](auto const &op) { future.get(); }};
    queue.push_back(std::move(op));

    XCTAssertTrue(queue.is_operating());

    promise.set_value();

    queue.wait_until_all_operations_are_finished();

    XCTAssertFalse(queue.is_operating());
}

- (void)test_is_operating_by_operations {
    operation_queue queue{1};

    queue.suspend();

    XCTAssertFalse(queue.is_operating());

    std::promise<void> promise;
    auto future = promise.get_future();

    operation op{[&promise](auto const &op) { promise.set_value(); }};
    queue.push_back(std::move(op));

    XCTAssertTrue(queue.is_operating());

    queue.resume();

    future.get();

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(queue.is_operating());
}

@end
