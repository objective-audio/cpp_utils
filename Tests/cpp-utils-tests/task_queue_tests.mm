//
//  task_queue_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp-utils/task_queue.h>
#import <future>
#import <thread>

using namespace std::chrono_literals;
using namespace yas;

@interface task_queue_tests : XCTestCase

@end

@implementation task_queue_tests

- (void)test_call_one_task {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    auto const queue = task_queue<int>::make_shared();
    auto task = yas::task<int>::make_shared([exe_ex](auto const &) { [exe_ex fulfill]; });
    queue->push_back(task);

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)test_call_many_task {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    std::atomic<int> count;
    count = 0;

    auto const queue = task_queue<int>::make_shared();

    auto task_1 = task<int>::make_shared([self, &count, exe_ex](task<int> const &op) {
        XCTAssertEqual(count.load(), 0);
        ++count;
    });
    auto task_2 = task<int>::make_shared([self, &count, exe_ex](task<int> const &op) {
        XCTAssertEqual(count.load(), 1);
        ++count;
    });
    auto task_3 = task<int>::make_shared([self, &count, exe_ex](task<int> const &op) {
        XCTAssertEqual(count.load(), 2);
        ++count;
        [exe_ex fulfill];
    });

    queue->push_back(task_1);
    queue->push_back(task_2);
    queue->push_back(task_3);

    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    XCTAssertEqual(count.load(), 3);
}

- (void)test_suspend {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    auto const queue = task_queue<int>::make_shared();

    queue->suspend();

    bool called = false;

    auto task = yas::task<int>::make_shared([&called, exe_ex](auto const &) {
        called = true;
        [exe_ex fulfill];
    });

    queue->push_back(task);

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(called);

    queue->resume();

    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    XCTAssertTrue(called);
}

- (void)test_is_suspended {
    auto const queue = task_queue<int>::make_shared();

    queue->suspend();

    XCTAssertTrue(queue->is_suspended());

    queue->resume();

    XCTAssertFalse(queue->is_suspended());
}

- (void)test_insert_to_top {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    std::atomic<int> count;
    count = 0;

    auto const queue = task_queue<int>::make_shared();

    queue->suspend();

    auto task_1 = task<int>::make_shared([self, &count, exe_ex](task<int> const &op) {
        XCTAssertEqual(count.load(), 0);
        ++count;
    });
    auto task_2 = task<int>::make_shared([self, &count, exe_ex](task<int> const &op) {
        XCTAssertEqual(count.load(), 1);
        ++count;
    });
    auto task_3 = task<int>::make_shared([self, &count, exe_ex](task<int> const &op) {
        XCTAssertEqual(count.load(), 2);
        ++count;
        [exe_ex fulfill];
    });

    queue->push_back(task_3);
    queue->push_front(task_2);
    queue->push_front(task_1);

    queue->resume();

    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    XCTAssertEqual(count.load(), 3);
}

- (void)test_task_cancel {
    auto const queue = task_queue<int>::make_shared();

    queue->suspend();

    bool called = false;

    auto task = yas::task<int>::make_shared([&called](auto const &) { called = true; });

    queue->push_back(task);

    task->cancel();

    queue->resume();

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(called);
}

- (void)test_cancel_task_from_queue {
    auto const queue = task_queue<int>::make_shared();

    queue->suspend();

    bool called = false;

    auto task = yas::task<int>::make_shared([&called](auto const &) { called = true; });

    queue->push_back(task);

    queue->cancel(task);

    queue->resume();

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(called);
}

- (void)test_cancel_current_task {
    auto const queue = task_queue<int>::make_shared();

    queue->suspend();

    std::promise<void> start_promise;
    std::promise<void> wait_promise;
    std::promise<bool> end_promise;

    auto start_future = start_promise.get_future();
    auto wait_future = wait_promise.get_future();
    auto end_future = end_promise.get_future();

    auto task = yas::task<int>::make_shared([self, &start_promise, &wait_future, &end_promise](auto const &task) {
        start_promise.set_value();
        wait_future.get();
        end_promise.set_value(task.is_canceled());
    });

    queue->push_back(task);
    queue->resume();

    start_future.get();

    queue->cancel(task);

    wait_promise.set_value();

    XCTAssertTrue(end_future.get());
}

- (void)test_cancel_with_cancellation {
    auto const queue = task_queue<int>::make_shared();

    queue->suspend();

    bool called = false;

    auto task = yas::task<int>::make_shared([&called](auto const &) { called = true; }, {.canceller = 100});

    queue->push_back(task);

    queue->cancel([](auto const &task_canceller) { return task_canceller == 100; });

    queue->resume();

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(called);
}

- (void)test_cancel_with_cancellation_current_task {
    auto const queue = task_queue<int>::make_shared();

    queue->suspend();

    std::promise<void> start_promise;
    std::promise<void> wait_promise;
    std::promise<bool> end_promise;

    auto start_future = start_promise.get_future();
    auto wait_future = wait_promise.get_future();
    auto end_future = end_promise.get_future();

    auto task = yas::task<int>::make_shared(
        [self, &start_promise, &wait_future, &end_promise](auto const &task) {
            start_promise.set_value();
            wait_future.get();
            end_promise.set_value(task.is_canceled());
        },
        {.canceller = 200});

    queue->push_back(task);
    queue->resume();

    start_future.get();

    queue->cancel([](auto const &canceller) { return canceller == 200; });

    wait_promise.set_value();

    XCTAssertTrue(end_future.get());
}

- (void)test_priority {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    std::atomic<int> count;
    count = 0;

    auto queue = task_queue<int>::make_shared(3);

    queue->suspend();

    auto task_1a = task<int>::make_shared(
        [self, &count](auto const &task) {
            XCTAssertEqual(count.load(), 0);
            ++count;
        },
        {.priority = 0});
    auto task_1b = task<int>::make_shared(
        [self, &count](auto const &task) {
            XCTAssertEqual(count.load(), 1);
            ++count;
        },
        {.priority = 0});
    auto task_2a = task<int>::make_shared(
        [self, &count](auto const &task) {
            XCTAssertEqual(count.load(), 2);
            ++count;
        },
        {.priority = 1});
    auto task_2b = task<int>::make_shared(
        [self, &count](auto const &task) {
            XCTAssertEqual(count.load(), 3);
            ++count;
        },
        {.priority = 1});
    auto task_3a = task<int>::make_shared(
        [self, &count](auto const &task) {
            XCTAssertEqual(count.load(), 4);
            ++count;
        },
        {.priority = 2});
    auto task_3b = task<int>::make_shared(
        [self, &count, exe_ex](auto const &task) {
            XCTAssertEqual(count.load(), 5);
            ++count;
            [exe_ex fulfill];
        },
        {.priority = 2});

    queue->push_back(task_3a);
    queue->push_back(task_2a);
    queue->push_back(task_1a);
    queue->push_back(task_3b);
    queue->push_back(task_2b);
    queue->push_back(task_1b);

    queue->resume();

    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    XCTAssertEqual(count.load(), 6);
}

- (void)test_wait {
    auto const queue = task_queue<int>::make_shared();

    queue->suspend();

    bool called = false;

    auto task = yas::task<int>::make_shared([&called](auto const &) {
        std::this_thread::sleep_for(100ms);

        called = true;
    });

    queue->push_back(task);

    queue->resume();

    queue->wait_until_all_tasks_are_finished();

    XCTAssertTrue(called);
}

- (void)test_wait_failed {
    auto const queue = task_queue<int>::make_shared();

    queue->suspend();

    auto task = yas::task<int>::make_shared([](auto const &) {});

    queue->push_back(task);

    XCTAssertThrows(queue->wait_until_all_tasks_are_finished());
}

- (void)test_is_operating_by_current_task {
    auto const queue = task_queue<int>::make_shared(1);

    XCTAssertFalse(queue->is_operating());

    std::promise<void> promise;
    auto future = promise.get_future();

    auto task = yas::task<int>::make_shared([&future](auto const &) { future.get(); });
    queue->push_back(task);

    XCTAssertTrue(queue->is_operating());

    promise.set_value();

    queue->wait_until_all_tasks_are_finished();

    XCTAssertFalse(queue->is_operating());
}

- (void)test_is_operating_by_tasks {
    auto const queue = task_queue<int>::make_shared(1);

    queue->suspend();

    XCTAssertFalse(queue->is_operating());

    std::promise<void> promise;
    auto future = promise.get_future();

    auto task = yas::task<int>::make_shared([&promise](auto const &) { promise.set_value(); });
    queue->push_back(task);

    XCTAssertTrue(queue->is_operating());

    queue->resume();

    future.get();

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(queue->is_operating());
}

@end
