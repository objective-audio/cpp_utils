//
//  yas_caller_tests.mm
//

#import <XCTest/XCTest.h>
#import <observing/yas_observing_umbrella.hpp>

using namespace yas;
using namespace yas::observing;

@interface yas_observing_caller_tests : XCTestCase

@end

@implementation yas_observing_caller_tests

- (void)test_call {
    auto caller = observing::caller<int>::make_shared();

    std::vector<int> called1;
    std::vector<int> called2;

    auto canceller1 = caller->add([&called1](int const &value) { called1.emplace_back(value); });
    auto canceller2 = caller->add([&called2](int const &value) { called2.emplace_back(value); });

    XCTAssertEqual(called1.size(), 0);
    XCTAssertEqual(called2.size(), 0);

    caller->call(1);

    XCTAssertEqual(called1.size(), 1);
    XCTAssertEqual(called1.at(0), 1);
    XCTAssertEqual(called2.size(), 1);
    XCTAssertEqual(called2.at(0), 1);

    canceller1->cancel();

    caller->call(2);

    XCTAssertEqual(called1.size(), 1);
    XCTAssertEqual(called2.size(), 2);
    XCTAssertEqual(called2.at(1), 2);
}

- (void)test_call_with_order {
    auto caller = observing::caller<int>::make_shared();

    enum class called_order : std::size_t {
        first,
        second,
        third,
    };

    struct called_element {
        called_order order;
        int value;

        bool operator==(called_element const &rhs) const {
            return this->order == rhs.order && this->value == rhs.value;
        }
    };

    std::vector<called_element> called;
    observing::canceller_pool pool;

    caller
        ->add(static_cast<int>(called_order::third),
              [&called](int const &value) {
                  called.emplace_back(called_element{.order = called_order::third, .value = value});
              })
        ->add_to(pool);
    caller
        ->add(static_cast<int>(called_order::second),
              [&called](int const &value) {
                  called.emplace_back(called_element{.order = called_order::second, .value = value});
              })
        ->add_to(pool);
    caller
        ->add(static_cast<int>(called_order::first),
              [&called](int const &value) {
                  called.emplace_back(called_element{.order = called_order::first, .value = value});
              })
        ->add_to(pool);

    XCTAssertEqual(called.size(), 0);

    caller->call(1);

    XCTAssertEqual(called.size(), 3);

    XCTAssertEqual(called.at(0), (called_element{.order = called_order::first, .value = 1}));
    XCTAssertEqual(called.at(1), (called_element{.order = called_order::second, .value = 1}));
    XCTAssertEqual(called.at(2), (called_element{.order = called_order::third, .value = 1}));

    pool.cancel();
}

- (void)test_ignore {
    auto caller = observing::caller<int>::make_shared();

    std::vector<int> called;

    auto canceller = caller->add([&called](int const &value) { called.emplace_back(value); });

    XCTAssertEqual(called.size(), 0);

    caller->call(3);

    XCTAssertEqual(called.size(), 1);
    XCTAssertEqual(called.at(0), 3);

    canceller->ignore();

    caller->call(4);

    XCTAssertEqual(called.size(), 2);
    XCTAssertEqual(called.at(1), 4);
}

- (void)test_destruct_caller {
    std::vector<int> called;

    canceller_ptr canceller = nullptr;

    {
        auto caller = observing::caller<int>::make_shared();

        canceller = caller->add([&called](int const &value) { called.emplace_back(value); });

        caller->call(5);

        XCTAssertEqual(called.size(), 1);
        XCTAssertEqual(called.at(0), 5);
    }

    XCTAssertEqual(called.size(), 1);
}

- (void)test_destruct_canceller {
    auto caller = observing::caller<int>::make_shared();

    std::vector<int> called1;

    {
        auto canceller1 = caller->add([&called1](int const &value) { called1.emplace_back(value); });

        XCTAssertEqual(called1.size(), 0);

        caller->call(6);

        XCTAssertEqual(called1.size(), 1);
        XCTAssertEqual(called1.at(0), 6);
    }

    caller->call(7);

    XCTAssertEqual(called1.size(), 1);
}

- (void)test_ignore_recursive_call {
    auto caller = observing::caller<int>::make_shared();

    int called_count = 0;

    auto canceller = caller->add([&caller, &called_count](int const &value) {
        ++called_count;
        caller->call(value);
    });

    caller->call(0);

    XCTAssertEqual(called_count, 1);
}

- (void)test_destruct_on_calling {
    struct caller_holder {
        observing::caller_ptr<int> caller = observing::caller<int>::make_shared();
    };

    auto holder = std::make_shared<caller_holder>();

    auto canceller = holder->caller->add([&holder](int const &value) { holder->caller = nullptr; });

    // callしている間にcallerを破棄してもクラッシュしない
    holder->caller->call(0);

    canceller->cancel();
}

@end
