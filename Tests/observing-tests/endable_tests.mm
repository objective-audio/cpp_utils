//
//  observing_endable_tests.mm
//

#import <XCTest/XCTest.h>
#import <observing/umbrella.hpp>
#import <vector>

using namespace yas;
using namespace yas::observing;

@interface endable_tests : XCTestCase

@end

@implementation endable_tests

- (void)test_end {
    std::size_t handler_called = 0;
    std::vector<uintptr_t> canceller_called;

    uintptr_t canceller_id = 0;

    observing::endable endable{[&handler_called, &canceller_called, &canceller_id] {
        handler_called++;
        auto canceller = canceller::make_shared(
            [&canceller_called](uintptr_t const identifier) { canceller_called.emplace_back(identifier); });
        canceller_id = canceller->identifier();
        return canceller;
    }};

    XCTAssertEqual(handler_called, 0);
    XCTAssertEqual(canceller_called.size(), 0);

    auto canceller1 = endable.end();

    XCTAssertEqual(handler_called, 1);
    XCTAssertTrue(canceller1);

    canceller1->cancel();

    XCTAssertEqual(canceller_called.size(), 1);
    XCTAssertNotEqual(canceller_id, 0);
    XCTAssertEqual(canceller_called.at(0), canceller_id);

    auto canceller2 = endable.end();

    XCTAssertEqual(handler_called, 1);
    XCTAssertTrue(canceller2);

    canceller2->cancel();

    XCTAssertEqual(canceller_called.size(), 1);
}

- (void)test_create_empty {
    observing::endable endable;

    auto canceller = endable.end();

    XCTAssertTrue(canceller);

    canceller->cancel();
}

- (void)test_create_null {
    observing::endable endable{nullptr};

    auto canceller = endable.end();

    XCTAssertTrue(canceller);

    canceller->cancel();
}

- (void)test_merge {
    std::size_t handler_called_1 = 0;
    std::vector<uintptr_t> canceller_called_1;
    uintptr_t canceller_id_1 = 0;

    observing::endable endable1{[&handler_called_1, &canceller_called_1, &canceller_id_1] {
        handler_called_1++;
        auto canceller = canceller::make_shared(
            [&canceller_called_1](uintptr_t const identifier) { canceller_called_1.emplace_back(identifier); });
        canceller_id_1 = canceller->identifier();
        return canceller;
    }};

    std::size_t handler_called_2 = 0;
    std::vector<uintptr_t> canceller_called_2;
    uintptr_t canceller_id_2 = 0;

    observing::endable endable2{[&handler_called_2, &canceller_called_2, &canceller_id_2] {
        handler_called_2++;
        auto canceller = canceller::make_shared(
            [&canceller_called_2](uintptr_t const identifier) { canceller_called_2.emplace_back(identifier); });
        canceller_id_2 = canceller->identifier();
        return canceller;
    }};

    endable1.merge(std::move(endable2));

    auto empty_canceller = endable2.end();
    XCTAssertTrue(empty_canceller);

    empty_canceller->cancel();

    XCTAssertEqual(handler_called_2, 0);
    XCTAssertEqual(canceller_called_2.size(), 0);

    auto canceller1 = endable1.end();

    XCTAssertEqual(handler_called_1, 1);
    XCTAssertEqual(handler_called_2, 1);
    XCTAssertTrue(canceller1);

    canceller1->cancel();

    XCTAssertEqual(canceller_called_1.size(), 1);
    XCTAssertNotEqual(canceller_id_1, 0);
    XCTAssertEqual(canceller_called_1.at(0), canceller_id_1);
    XCTAssertEqual(canceller_called_2.size(), 1);
    XCTAssertNotEqual(canceller_id_2, 0);
    XCTAssertEqual(canceller_called_2.at(0), canceller_id_2);
}

@end
