//
//  observing_value_holder_tests.mm
//

#import <XCTest/XCTest.h>
#import <observing/umbrella.hpp>

using namespace yas;
using namespace yas::observing;

@interface value_holder_tests : XCTestCase

@end

@implementation value_holder_tests

- (void)test_make_by_copy {
    int const value = 10;

    auto const holder = value::holder<int>::make_shared(value);

    XCTAssertEqual(holder->value(), 10);
}

- (void)test_make_by_move {
    int value = 20;

    auto const holder = value::holder<int>::make_shared(std::move(value));

    XCTAssertEqual(holder->value(), 20);
}

- (void)test_value {
    auto const holder = value::holder<int>::make_shared(0);

    XCTAssertEqual(holder->value(), 0);

    holder->set_value(1);

    XCTAssertEqual(holder->value(), 1);

    int const value = 2;

    holder->set_value(value);

    XCTAssertEqual(holder->value(), 2);
}

- (void)test_observe_with_sync {
    auto const holder = value::holder<int>::make_shared(100);

    std::vector<int> called;

    auto canceller = holder->observe([&called](int const &value) { called.emplace_back(value); }).sync();

    XCTAssertEqual(called.size(), 1);
    XCTAssertEqual(called.at(0), 100);

    holder->set_value(101);

    XCTAssertEqual(called.size(), 2);
    XCTAssertEqual(called.at(1), 101);

    holder->set_value(101);

    XCTAssertEqual(called.size(), 2);

    canceller->cancel();
    holder->set_value(102);

    XCTAssertEqual(called.size(), 2);
}

- (void)test_observe_without_sync {
    auto const holder = value::holder<int>::make_shared(200);

    std::vector<int> called;

    auto canceller = holder->observe([&called](int const &value) { called.emplace_back(value); }).end();

    XCTAssertEqual(called.size(), 0);

    holder->set_value(201);

    XCTAssertEqual(called.size(), 1);
    XCTAssertEqual(called.at(0), 201);
}

- (void)test_observe_with_order {
    auto const holder = value::holder<int>::make_shared(300);

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

    holder
        ->observe(static_cast<int>(called_order::second),
                  [&called](int const &value) {
                      called.emplace_back(called_element{.order = called_order::second, .value = value});
                  })
        .sync()
        ->add_to(pool);

    XCTAssertEqual(called.size(), 1);
    XCTAssertEqual(called.at(0), (called_element{.order = called_order::second, .value = 300}));

    holder
        ->observe(static_cast<int>(called_order::first),
                  [&called](int const &value) {
                      called.emplace_back(called_element{.order = called_order::first, .value = value});
                  })
        .sync()
        ->add_to(pool);

    XCTAssertEqual(called.size(), 2);
    XCTAssertEqual(called.at(1), (called_element{.order = called_order::first, .value = 300}));

    holder->set_value(301);

    XCTAssertEqual(called.size(), 4);
    XCTAssertEqual(called.at(2), (called_element{.order = called_order::first, .value = 301}));
    XCTAssertEqual(called.at(3), (called_element{.order = called_order::second, .value = 301}));

    pool.cancel();
}

@end
