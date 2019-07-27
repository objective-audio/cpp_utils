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
struct test_cancel_id : task_cancel_id {
   private:
    struct equaler {};
    std::shared_ptr<equaler> _equaler;

    test_cancel_id() : _equaler(std::make_shared<equaler>()) {
    }

    virtual bool is_equal(std::shared_ptr<task_cancel_id> const &rhs) const override {
        if (auto casted_rhs = std::dynamic_pointer_cast<test_cancel_id>(rhs)) {
            return this->_equaler == casted_rhs->_equaler;
        } else {
            return false;
        }
    }

   public:
    static std::shared_ptr<test_cancel_id> make_shared() {
        return std::shared_ptr<test_cancel_id>(new test_cancel_id());
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
    auto task = make_task([exe_ex](yas::task const &) { [exe_ex fulfill]; });
    queue.push_back(*task);

    [self waitForExpectationsWithTimeout:1.0 handler:nil];
}

- (void)test_call_many_task {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    std::atomic<int> count;
    count = 0;

    task_queue queue;

    auto task_1 = make_task([self, &count, exe_ex](task const &op) {
        XCTAssertEqual(count.load(), 0);
        ++count;
    });
    auto task_2 = make_task([self, &count, exe_ex](task const &op) {
        XCTAssertEqual(count.load(), 1);
        ++count;
    });
    auto task_3 = make_task([self, &count, exe_ex](task const &op) {
        XCTAssertEqual(count.load(), 2);
        ++count;
        [exe_ex fulfill];
    });

    queue.push_back(*task_1);
    queue.push_back(*task_2);
    queue.push_back(*task_3);

    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    XCTAssertEqual(count.load(), 3);
}

- (void)test_suspend {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    task_queue queue;

    queue.suspend();

    bool called = false;

    auto task = make_task([&called, exe_ex](yas::task const &) {
        called = true;
        [exe_ex fulfill];
    });

    queue.push_back(*task);

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

    auto task_1 = make_task([self, &count, exe_ex](task const &op) {
        XCTAssertEqual(count.load(), 0);
        ++count;
    });
    auto task_2 = make_task([self, &count, exe_ex](task const &op) {
        XCTAssertEqual(count.load(), 1);
        ++count;
    });
    auto task_3 = make_task([self, &count, exe_ex](task const &op) {
        XCTAssertEqual(count.load(), 2);
        ++count;
        [exe_ex fulfill];
    });

    queue.push_back(*task_3);
    queue.push_front(*task_2);
    queue.push_front(*task_1);

    queue.resume();

    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    XCTAssertEqual(count.load(), 3);
}

- (void)test_task_cancel {
    task_queue queue;

    queue.suspend();

    bool called = false;

    auto task = make_task([&called](yas::task const &) { called = true; });

    queue.push_back(*task);

    task->cancel();

    queue.resume();

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(called);
}

- (void)test_cancel_task_from_queue {
    task_queue queue;

    queue.suspend();

    bool called = false;

    auto task = make_task([&called](yas::task const &) { called = true; });

    queue.push_back(*task);

    queue.cancel(*task);

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

    auto task = make_task([self, &start_promise, &wait_future, &end_promise](yas::task const &task) {
        start_promise.set_value();
        wait_future.get();
        end_promise.set_value(task.is_canceled());
    });

    queue.push_back(*task);
    queue.resume();

    start_future.get();

    queue.cancel(*task);

    wait_promise.set_value();

    XCTAssertTrue(end_future.get());
}

- (void)test_cancel_for_id {
    task_queue queue;

    queue.suspend();

    bool called = false;

    auto identifier = test_cancel_id::make_shared();
    auto task = make_task([&called](yas::task const &) { called = true; }, {.cancel_id = identifier});

    queue.push_back(*task);

    queue.cancel_for_id(identifier);

    queue.resume();

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(called);
}

- (void)test_cancel_with_cancellation {
    task_queue queue;

    queue.suspend();

    bool called = false;

    auto identifier = test_cancel_id::make_shared();
    auto task = make_task([&called](yas::task const &) { called = true; }, {.cancel_id = identifier});

    queue.push_back(*task);

    queue.cancel([&identifier](auto const &task_cancel_id) { return identifier == task_cancel_id; });

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

    auto identifier = test_cancel_id::make_shared();
    auto task = make_task(
        [self, &start_promise, &wait_future, &end_promise](yas::task const &task) {
            start_promise.set_value();
            wait_future.get();
            end_promise.set_value(task.is_canceled());
        },
        {.cancel_id = identifier});

    queue.push_back(*task);
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

    auto identifier = test_cancel_id::make_shared();
    auto task = make_task(
        [self, &start_promise, &wait_future, &end_promise](yas::task const &task) {
            start_promise.set_value();
            wait_future.get();
            end_promise.set_value(task.is_canceled());
        },
        {.cancel_id = identifier});

    queue.push_back(*task);
    queue.resume();

    start_future.get();

    queue.cancel([&identifier](auto const &task_cancel_id) { return identifier == task_cancel_id; });

    wait_promise.set_value();

    XCTAssertTrue(end_future.get());
}

- (void)test_priority {
    XCTestExpectation *exe_ex = [self expectationWithDescription:@"call execution"];

    std::atomic<int> count;
    count = 0;

    task_queue queue{3};

    queue.suspend();

    auto task_1a = make_task(
        [self, &count](yas::task const &task) {
            XCTAssertEqual(count.load(), 0);
            ++count;
        },
        {.priority = 0});
    auto task_1b = make_task(
        [self, &count](yas::task const &task) {
            XCTAssertEqual(count.load(), 1);
            ++count;
        },
        {.priority = 0});
    auto task_2a = make_task(
        [self, &count](yas::task const &task) {
            XCTAssertEqual(count.load(), 2);
            ++count;
        },
        {.priority = 1});
    auto task_2b = make_task(
        [self, &count](yas::task const &task) {
            XCTAssertEqual(count.load(), 3);
            ++count;
        },
        {.priority = 1});
    auto task_3a = make_task(
        [self, &count](yas::task const &task) {
            XCTAssertEqual(count.load(), 4);
            ++count;
        },
        {.priority = 2});
    auto task_3b = make_task(
        [self, &count, exe_ex](yas::task const &task) {
            XCTAssertEqual(count.load(), 5);
            ++count;
            [exe_ex fulfill];
        },
        {.priority = 2});

    queue.push_back(*task_3a);
    queue.push_back(*task_2a);
    queue.push_back(*task_1a);
    queue.push_back(*task_3b);
    queue.push_back(*task_2b);
    queue.push_back(*task_1b);

    queue.resume();

    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    XCTAssertEqual(count.load(), 6);
}

- (void)test_wait {
    task_queue queue;

    queue.suspend();

    bool called = false;

    auto task = make_task([&called](yas::task const &) {
        std::this_thread::sleep_for(100ms);

        called = true;
    });

    queue.push_back(*task);

    queue.resume();

    queue.wait_until_all_tasks_are_finished();

    XCTAssertTrue(called);
}

- (void)test_wait_failed {
    task_queue queue;

    queue.suspend();

    auto task = make_task([](yas::task const &) {});

    queue.push_back(*task);

    XCTAssertThrows(queue.wait_until_all_tasks_are_finished());
}

- (void)test_cancel_by_push_cancel_id {
    task_queue queue;

    auto cancel_id_a = test_cancel_id::make_shared();
    auto cancel_id_b = test_cancel_id::make_shared();

    bool called_a_1 = false;
    bool called_a_2 = false;
    bool called_b = false;
    bool called_n_1 = false;
    bool called_n_2 = false;

    auto task_a_1 = make_task([&called_a_1](auto const &task) { called_a_1 = true; }, {.push_cancel_id = cancel_id_a});
    auto task_a_2 = make_task([&called_a_2](auto const &task) { called_a_2 = true; }, {.push_cancel_id = cancel_id_a});
    auto task_b = make_task([&called_b](auto const &task) { called_b = true; }, {.push_cancel_id = cancel_id_b});
    auto task_n_1 = make_task([&called_n_1](auto const &task) { called_n_1 = true; });
    auto task_n_2 = make_task([&called_n_2](auto const &task) { called_n_2 = true; });

    queue.suspend();

    queue.push_back(*task_a_1);
    queue.push_back(*task_b);
    queue.push_back(*task_n_1);
    queue.push_back(*task_a_2);
    queue.push_back(*task_n_2);

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

    auto cancel_id = test_cancel_id::make_shared();

    bool called_1 = false;
    bool called_2 = false;

    auto task_1 =
        make_task([&called_1](auto const &task) { called_1 = true; }, {.priority = 0, .push_cancel_id = cancel_id});
    auto task_2 =
        make_task([&called_2](auto const &task) { called_2 = true; }, {.priority = 1, .push_cancel_id = cancel_id});

    queue.suspend();

    queue.push_back(*task_1);
    queue.push_back(*task_2);

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

    auto task = make_task([&future](auto const &) { future.get(); });
    queue.push_back(*task);

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

    auto task = make_task([&promise](auto const &) { promise.set_value(); });
    queue.push_back(*task);

    XCTAssertTrue(queue.is_operating());

    queue.resume();

    future.get();

    [NSThread sleepForTimeInterval:0.1];

    XCTAssertFalse(queue.is_operating());
}

@end
