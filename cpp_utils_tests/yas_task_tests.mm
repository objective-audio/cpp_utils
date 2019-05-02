//
//  yas_task_tests.m
//

#import <XCTest/XCTest.h>
#import <cpp_utils/yas_task.h>
#import <future>
#include <thread>

using namespace std::chrono_literals;
using namespace yas;

namespace yas {
struct test_cancel_id : base {
    struct impl : base::impl {};
    test_cancel_id() : base(std::make_shared<impl>()) {
    }
};
}

@interface yas_task_tests : XCTestCase

@end

@implementation yas_task_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_call_one_task {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    task_queue queue;
    task op([exe_ex](task const &) { [exe_ex fulfill]; });
    queue.push_back(op);

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)test_call_many_task {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    std::atomic<int> count;
    count = 0;

    task_queue queue;

    task task_1([self, &count, exe_ex](task const &op) {
        XCTAssertEqual(count.load(), 0);
        ++count;
    });
    task task_2([self, &count, exe_ex](task const &op) {
        XCTAssertEqual(count.load(), 1);
        ++count;
    });
    task task_3([self, &count, exe_ex](task const &op) {
        XCTAssertEqual(count.load(), 2);
        ++count;
        [exe_ex fulfill];
    });

    queue.push_back(task_1);
    queue.push_back(task_2);
    queue.push_back(task_3);

    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    XCTAssertEqual(count.load(), 3);
}

- (void)test_suspend {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    task_queue queue;

    queue.suspend();

    bool called = false;

    task op([&called, exe_ex](task const &) {
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
    task_queue queue;

    queue.suspend();

    XCTAssertTrue(queue.is_suspended());

    queue.resume();

    XCTAssertFalse(queue.is_suspended());
}

- (void)test_insert_to_top {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    std::atomic<int> count;
    count = 0;

    task_queue queue;

    queue.suspend();

    task task_1([self, &count, exe_ex](task const &op) {
        XCTAssertEqual(count.load(), 0);
        ++count;
    });
    task task_2([self, &count, exe_ex](task const &op) {
        XCTAssertEqual(count.load(), 1);
        ++count;
    });
    task task_3([self, &count, exe_ex](task const &op) {
        XCTAssertEqual(count.load(), 2);
        ++count;
        [exe_ex fulfill];
    });

    queue.push_back(task_3);
    queue.push_front(task_2);
    queue.push_front(task_1);

    queue.resume();

    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    XCTAssertEqual(count.load(), 3);
}

- (void)test_task_cancel {
    task_queue queue;

    queue.suspend();

    bool called = false;

    task op([&called](task const &) { called = true; });

    queue.push_back(op);

    op.cancel();

    queue.resume();

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(called);
}

- (void)test_cancel_task_from_queue {
    task_queue queue;

    queue.suspend();

    bool called = false;

    task op([&called](task const &) { called = true; });

    queue.push_back(op);

    queue.cancel(op);

    queue.resume();

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(called);
}

- (void)test_cancel_current_task {
    task_queue queue;

    queue.suspend();

    std::promise<void> start_promise;
    std::promise<void> wait_promise;
    std::promise<bool> end_promise;

    auto start_future = start_promise.get_future();
    auto wait_future = wait_promise.get_future();
    auto end_future = end_promise.get_future();

    task op([self, &start_promise, &wait_future, &end_promise](task const &op) {
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
    task_queue queue;

    queue.suspend();

    bool called = false;

    test_cancel_id identifier;
    task op([&called](task const &) { called = true; }, {.cancel_id = identifier});

    queue.push_back(op);

    queue.cancel_for_id(identifier);

    queue.resume();

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(called);
}

- (void)test_cancel_with_cancellation {
    task_queue queue;

    queue.suspend();

    bool called = false;

    test_cancel_id identifier;
    task op([&called](task const &) { called = true; }, {.cancel_id = identifier});

    queue.push_back(op);

    queue.cancel([&identifier](base const &op_cancel_id) { return identifier == op_cancel_id; });

    queue.resume();

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(called);
}

- (void)test_cancel_for_id_current_task {
    task_queue queue;

    queue.suspend();

    std::promise<void> start_promise;
    std::promise<void> wait_promise;
    std::promise<bool> end_promise;

    auto start_future = start_promise.get_future();
    auto wait_future = wait_promise.get_future();
    auto end_future = end_promise.get_future();

    test_cancel_id identifier;
    task op(
        [self, &start_promise, &wait_future, &end_promise](task const &op) {
            start_promise.set_value();
            wait_future.get();
            end_promise.set_value(op.is_canceled());
        },
        {.cancel_id = identifier});

    queue.push_back(op);
    queue.resume();

    start_future.get();

    queue.cancel_for_id(identifier);

    wait_promise.set_value();

    XCTAssertTrue(end_future.get());
}

- (void)test_cancel_with_cancellation_current_task {
    task_queue queue;

    queue.suspend();

    std::promise<void> start_promise;
    std::promise<void> wait_promise;
    std::promise<bool> end_promise;

    auto start_future = start_promise.get_future();
    auto wait_future = wait_promise.get_future();
    auto end_future = end_promise.get_future();

    test_cancel_id identifier;
    task op(
        [self, &start_promise, &wait_future, &end_promise](task const &op) {
            start_promise.set_value();
            wait_future.get();
            end_promise.set_value(op.is_canceled());
        },
        {.cancel_id = identifier});

    queue.push_back(op);
    queue.resume();

    start_future.get();

    queue.cancel([&identifier](base const &op_cancel_id) { return identifier == op_cancel_id; });

    wait_promise.set_value();

    XCTAssertTrue(end_future.get());
}

- (void)test_null_created {
    task_queue queue{nullptr};
    task task{nullptr};

    XCTAssertFalse(queue);
    XCTAssertFalse(task);
}

- (void)test_priority {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    std::atomic<int> count;
    count = 0;

    task_queue queue{3};

    queue.suspend();

    task task_1a(
        [self, &count](task const &op) {
            XCTAssertEqual(count.load(), 0);
            ++count;
        },
        {.priority = 0});
    task task_1b(
        [self, &count](task const &op) {
            XCTAssertEqual(count.load(), 1);
            ++count;
        },
        {.priority = 0});
    task task_2a(
        [self, &count](task const &op) {
            XCTAssertEqual(count.load(), 2);
            ++count;
        },
        {.priority = 1});
    task task_2b(
        [self, &count](task const &op) {
            XCTAssertEqual(count.load(), 3);
            ++count;
        },
        {.priority = 1});
    task task_3a(
        [self, &count](task const &op) {
            XCTAssertEqual(count.load(), 4);
            ++count;
        },
        {.priority = 2});
    task task_3b(
        [self, &count, exe_ex](task const &op) {
            XCTAssertEqual(count.load(), 5);
            ++count;
            [exe_ex fulfill];
        },
        {.priority = 2});

    queue.push_back(task_3a);
    queue.push_back(task_2a);
    queue.push_back(task_1a);
    queue.push_back(task_3b);
    queue.push_back(task_2b);
    queue.push_back(task_1b);

    queue.resume();

    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    XCTAssertEqual(count.load(), 6);
}

- (void)test_wait {
    task_queue queue;

    queue.suspend();

    bool called = false;

    task op([&called](task const &) {
        std::this_thread::sleep_for(100ms);

        called = true;
    });

    queue.push_back(op);

    queue.resume();

    queue.wait_until_all_tasks_are_finished();

    XCTAssertTrue(called);
}

- (void)test_wait_failed {
    task_queue queue;

    queue.suspend();

    task op([](task const &) {});

    queue.push_back(op);

    XCTAssertThrows(queue.wait_until_all_tasks_are_finished());
}

- (void)test_cancel_by_push_cancel_id {
    task_queue queue;

    base cancel_id_a{nullptr};
    base cancel_id_b{nullptr};
    cancel_id_a.set_impl_ptr(std::make_shared<base::impl>());
    cancel_id_b.set_impl_ptr(std::make_shared<base::impl>());

    bool called_a_1 = false;
    bool called_a_2 = false;
    bool called_b = false;
    bool called_n_1 = false;
    bool called_n_2 = false;

    task op_a_1{[&called_a_1](auto const &op) { called_a_1 = true; }, {.push_cancel_id = cancel_id_a}};
    task op_a_2{[&called_a_2](auto const &op) { called_a_2 = true; }, {.push_cancel_id = cancel_id_a}};
    task op_b{[&called_b](auto const &op) { called_b = true; }, {.push_cancel_id = cancel_id_b}};
    task op_n_1{[&called_n_1](auto const &op) { called_n_1 = true; }};
    task op_n_2{[&called_n_2](auto const &op) { called_n_2 = true; }};

    queue.suspend();

    queue.push_back(std::move(op_a_1));
    queue.push_back(std::move(op_b));
    queue.push_back(std::move(op_n_1));
    queue.push_back(std::move(op_a_2));
    queue.push_back(std::move(op_n_2));

    queue.resume();

    queue.wait_until_all_tasks_are_finished();

    XCTAssertFalse(called_a_1);
    XCTAssertTrue(called_a_2);
    XCTAssertTrue(called_b);
    XCTAssertTrue(called_n_1);
    XCTAssertTrue(called_n_2);
}

- (void)test_cancel_different_priority {
    task_queue queue{2};

    base cancel_id{nullptr};
    cancel_id.set_impl_ptr(std::make_shared<base::impl>());

    bool called_1 = false;
    bool called_2 = false;

    task op_1{[&called_1](auto const &op) { called_1 = true; }, {.priority = 0, .push_cancel_id = cancel_id}};
    task op_2{[&called_2](auto const &op) { called_2 = true; }, {.priority = 1, .push_cancel_id = cancel_id}};

    queue.suspend();

    queue.push_back(std::move(op_1));
    queue.push_back(std::move(op_2));

    queue.resume();

    queue.wait_until_all_tasks_are_finished();

    XCTAssertFalse(called_1);
    XCTAssertTrue(called_2);
}

- (void)test_is_operating_by_current_task {
    task_queue queue{1};

    XCTAssertFalse(queue.is_operating());

    std::promise<void> promise;
    auto future = promise.get_future();

    task op{[&future](auto const &op) { future.get(); }};
    queue.push_back(std::move(op));

    XCTAssertTrue(queue.is_operating());

    promise.set_value();

    queue.wait_until_all_tasks_are_finished();

    XCTAssertFalse(queue.is_operating());
}

- (void)test_is_operating_by_tasks {
    task_queue queue{1};

    queue.suspend();

    XCTAssertFalse(queue.is_operating());

    std::promise<void> promise;
    auto future = promise.get_future();

    task op{[&promise](auto const &op) { promise.set_value(); }};
    queue.push_back(std::move(op));

    XCTAssertTrue(queue.is_operating());

    queue.resume();

    future.get();

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(queue.is_operating());
}

@end
