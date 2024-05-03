//
//  yas_observing_notifier_tests.mm
//

#import <XCTest/XCTest.h>
#import <observing/yas_observing_umbrella.hpp>

using namespace yas;
using namespace yas::observing;

@interface yas_observing_notifier_tests : XCTestCase

@end

@implementation yas_observing_notifier_tests

- (void)test_notify {
    auto const notifier = observing::notifier<int>::make_shared();

    std::vector<int> called1;
    std::vector<int> called2;

    auto const canceller1 = notifier->observe([&called1](int const &value) { called1.emplace_back(value); }).end();
    auto const canceller2 = notifier->observe([&called2](int const &value) { called2.emplace_back(value); }).end();

    XCTAssertEqual(called1.size(), 0);
    XCTAssertEqual(called2.size(), 0);

    notifier->notify(1);

    XCTAssertEqual(called1.size(), 1);
    XCTAssertEqual(called1.at(0), 1);
    XCTAssertEqual(called2.size(), 1);
    XCTAssertEqual(called2.at(0), 1);

    canceller1->cancel();

    notifier->notify(2);

    XCTAssertEqual(called1.size(), 1);
    XCTAssertEqual(called2.size(), 2);
    XCTAssertEqual(called2.at(1), 2);
}

- (void)test_observe_with_order {
    auto const notifier = observing::notifier<int>::make_shared();

    enum class called_order : std::size_t {
        first,
        second,
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

    notifier
        ->observe(static_cast<int>(called_order::second),
                  [&called](int const &value) {
                      called.emplace_back(called_element{.order = called_order::second, .value = value});
                  })
        .end()
        ->add_to(pool);

    notifier
        ->observe(static_cast<int>(called_order::first),
                  [&called](int const &value) {
                      called.emplace_back(called_element{.order = called_order::first, .value = value});
                  })
        .end()
        ->add_to(pool);

    notifier->notify(20);

    XCTAssertEqual(called.size(), 2);
    XCTAssertEqual(called.at(0), (called_element{.order = called_order::first, .value = 20}));
    XCTAssertEqual(called.at(1), (called_element{.order = called_order::second, .value = 20}));

    pool.cancel();
}

- (void)test_notify_null {
    auto const notifier = observing::notifier<std::nullptr_t>::make_shared();

    std::size_t called;

    auto const canceller = notifier->observe([&called](auto const &) { called += 1; }).end();

    XCTAssertEqual(called, 0);

    notifier->notify(nullptr);

    XCTAssertEqual(called, 1);

    notifier->notify();

    XCTAssertEqual(called, 2);
}

- (void)test_notify_no_observing {
    auto const notifier = observing::notifier<std::nullptr_t>::make_shared();

    notifier->notify(nullptr);
}

@end
