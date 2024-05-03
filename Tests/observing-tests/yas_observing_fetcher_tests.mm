//
//  yas_observing_fetcher_tests.mm
//

#import <XCTest/XCTest.h>
#import <observing/yas_observing_umbrella.hpp>

using namespace yas;
using namespace yas::observing;

@interface yas_observing_fetcher_tests : XCTestCase

@end

@implementation yas_observing_fetcher_tests

- (void)test_fetched_value {
    std::optional<int> value = std::nullopt;

    auto const fetcher = observing::fetcher<int>::make_shared([&value] { return value; });

    XCTAssertFalse(fetcher->fetched_value().has_value());

    value = 1;

    auto const fetched = fetcher->fetched_value();

    XCTAssertTrue(fetched.has_value());
    XCTAssertEqual(fetched.value(), 1);
}

- (void)test_observe {
    std::vector<int> called1;
    std::vector<int> called2;

    std::optional<int> value = std::nullopt;

    auto const fetcher = observing::fetcher<int>::make_shared([&value] { return value; });

    auto canceller1 = fetcher->observe([&called1](int const &value) { called1.emplace_back(value); }).sync();

    XCTAssertEqual(called1.size(), 0);

    value = 1;

    auto canceller2 = fetcher->observe([&called2](int const &value) { called2.emplace_back(value); }).sync();

    XCTAssertEqual(called1.size(), 0);
    XCTAssertEqual(called2.size(), 1);
    XCTAssertEqual(called2.at(0), 1);

    fetcher->push();

    XCTAssertEqual(called1.size(), 1);
    XCTAssertEqual(called1.at(0), 1);
    XCTAssertEqual(called2.size(), 2);
    XCTAssertEqual(called2.at(1), 1);

    fetcher->push(2);

    XCTAssertEqual(called1.size(), 2);
    XCTAssertEqual(called1.at(1), 2);
    XCTAssertEqual(called2.size(), 3);
    XCTAssertEqual(called2.at(2), 2);
}

- (void)test_observe_with_order {
    std::optional<int> value = 10;
    auto const fetcher = observing::fetcher<int>::make_shared([&value] { return value; });

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

    fetcher
        ->observe(static_cast<int>(called_order::second),
                  [&called](int const &value) {
                      called.emplace_back(called_element{.order = called_order::second, .value = value});
                  })
        .sync()
        ->add_to(pool);

    XCTAssertEqual(called.size(), 1);
    XCTAssertEqual(called.at(0), (called_element{.order = called_order::second, .value = 10}));

    fetcher
        ->observe(static_cast<int>(called_order::first),
                  [&called](int const &value) {
                      called.emplace_back(called_element{.order = called_order::first, .value = value});
                  })
        .sync()
        ->add_to(pool);

    XCTAssertEqual(called.size(), 2);
    XCTAssertEqual(called.at(1), (called_element{.order = called_order::first, .value = 10}));

    fetcher->push(11);

    XCTAssertEqual(called.size(), 4);
    XCTAssertEqual(called.at(2), (called_element{.order = called_order::first, .value = 11}));
    XCTAssertEqual(called.at(3), (called_element{.order = called_order::second, .value = 11}));

    pool.cancel();
}

- (void)test_push_no_observing {
    auto const fetcher = observing::fetcher<int>::make_shared([] { return 1; });

    fetcher->push(2);
}

@end
