//
//  observing_syncable_tests.mm
//

#import <XCTest/XCTest.h>
#import <observing/umbrella.hpp>
#import <vector>

using namespace yas;
using namespace yas::observing;

@interface syncable_tests : XCTestCase

@end

@implementation syncable_tests

- (void)test_sync {
    std::vector<bool> handler_called;
    std::vector<uintptr_t> canceller_called;
    uintptr_t canceller_id = 0;

    observing::syncable syncable{[&handler_called, &canceller_called, &canceller_id](bool const sync) {
        handler_called.emplace_back(sync);
        auto canceller = canceller::make_shared(
            [&canceller_called](uintptr_t const identifier) { canceller_called.emplace_back(identifier); });
        canceller_id = canceller->identifier();
        return canceller;
    }};

    XCTAssertEqual(handler_called.size(), 0);
    XCTAssertEqual(canceller_called.size(), 0);

    auto canceller1 = syncable.sync();

    XCTAssertEqual(handler_called.size(), 1);
    XCTAssertTrue(handler_called.at(0));
    XCTAssertTrue(canceller1);

    canceller1->cancel();

    XCTAssertEqual(canceller_called.size(), 1);
    XCTAssertNotEqual(canceller_id, 0);
    XCTAssertEqual(canceller_called.at(0), canceller_id);

    auto canceller2 = syncable.sync();

    XCTAssertEqual(handler_called.size(), 1);
    XCTAssertTrue(canceller2);

    canceller2->cancel();

    XCTAssertEqual(canceller_called.size(), 1);
}

- (void)test_end {
    std::vector<bool> handler_called;
    std::vector<uintptr_t> canceller_called;
    uintptr_t canceller_id = 0;

    observing::syncable syncable{[&handler_called, &canceller_called, &canceller_id](bool const sync) {
        handler_called.emplace_back(sync);
        auto canceller = canceller::make_shared(
            [&canceller_called](uintptr_t const identifier) { canceller_called.emplace_back(identifier); });
        canceller_id = canceller->identifier();
        return canceller;
    }};

    XCTAssertEqual(handler_called.size(), 0);
    XCTAssertEqual(canceller_called.size(), 0);

    auto canceller1 = syncable.end();

    XCTAssertEqual(handler_called.size(), 1);
    XCTAssertFalse(handler_called.at(0));
    XCTAssertTrue(canceller1);

    canceller1->cancel();

    XCTAssertEqual(canceller_called.size(), 1);
    XCTAssertNotEqual(canceller_id, 0);
    XCTAssertEqual(canceller_called.at(0), canceller_id);

    auto canceller2 = syncable.end();

    XCTAssertEqual(handler_called.size(), 1);
    XCTAssertTrue(canceller2);

    canceller2->cancel();

    XCTAssertEqual(canceller_called.size(), 1);
}

- (void)test_merge {
    std::vector<bool> handler_called1;
    std::vector<uintptr_t> canceller_called1;
    uintptr_t canceller_id_1 = 0;

    observing::syncable syncable1{[&handler_called1, &canceller_called1, &canceller_id_1](bool const sync) {
        handler_called1.emplace_back(sync);
        auto canceller = canceller::make_shared(
            [&canceller_called1](uintptr_t const identifier) { canceller_called1.emplace_back(identifier); });
        canceller_id_1 = canceller->identifier();
        return canceller;
    }};

    std::vector<bool> handler_called2;
    std::vector<uintptr_t> canceller_called2;
    uintptr_t canceller_id_2 = 0;

    observing::syncable syncable2{[&handler_called2, &canceller_called2, &canceller_id_2](bool const sync) {
        handler_called2.emplace_back(sync);
        auto canceller = canceller::make_shared(
            [&canceller_called2](uintptr_t const identifier) { canceller_called2.emplace_back(identifier); });
        canceller_id_2 = canceller->identifier();
        return canceller;
    }};

    std::size_t handler_called3 = 0;
    std::vector<uintptr_t> canceller_called3;
    uintptr_t canceller_id_3 = 0;

    observing::endable endable{[&handler_called3, &canceller_called3, &canceller_id_3] {
        handler_called3++;
        auto canceller = canceller::make_shared(
            [&canceller_called3](uintptr_t const identifier) { canceller_called3.emplace_back(identifier); });
        canceller_id_3 = canceller->identifier();
        return canceller;
    }};

    syncable1.merge(std::move(syncable2));

    auto empty_canceller1 = syncable2.end();
    XCTAssertTrue(empty_canceller1);

    empty_canceller1->cancel();

    XCTAssertEqual(handler_called2.size(), 0);
    XCTAssertEqual(canceller_called2.size(), 0);

    syncable1.merge(std::move(endable));

    auto empty_canceller2 = endable.end();
    XCTAssertTrue(empty_canceller2);

    empty_canceller2->cancel();

    XCTAssertEqual(handler_called3, 0);
    XCTAssertEqual(canceller_called3.size(), 0);

    auto canceller1 = syncable1.sync();

    XCTAssertTrue(canceller1);
    XCTAssertEqual(handler_called1.size(), 1);
    XCTAssertTrue(handler_called1.at(0));
    XCTAssertEqual(handler_called2.size(), 1);
    XCTAssertTrue(handler_called2.at(0));
    XCTAssertEqual(handler_called3, 1);

    canceller1->cancel();

    XCTAssertEqual(canceller_called1.size(), 1);
    XCTAssertNotEqual(canceller_id_1, 0);
    XCTAssertEqual(canceller_called1.at(0), canceller_id_1);
    XCTAssertEqual(canceller_called2.size(), 1);
    XCTAssertNotEqual(canceller_id_2, 0);
    XCTAssertEqual(canceller_called2.at(0), canceller_id_2);
    XCTAssertEqual(canceller_called3.size(), 1);
    XCTAssertNotEqual(canceller_id_3, 0);
    XCTAssertEqual(canceller_called3.at(0), canceller_id_3);
}

- (void)test_to_endable {
    std::vector<bool> handler_called1;
    std::vector<uintptr_t> canceller_called1;
    uintptr_t canceller_id_1 = 0;

    observing::syncable syncable{[&handler_called1, &canceller_called1, &canceller_id_1](bool const sync) {
        handler_called1.emplace_back(sync);
        auto canceller = canceller::make_shared(
            [&canceller_called1](uintptr_t const identifier) { canceller_called1.emplace_back(identifier); });
        canceller_id_1 = canceller->identifier();
        return canceller;
    }};

    std::size_t handler_called2 = 0;
    std::vector<uintptr_t> canceller_called2;
    uintptr_t canceller_id_2 = 0;

    observing::endable endable{[&handler_called2, &canceller_called2, &canceller_id_2] {
        handler_called2++;
        auto canceller = canceller::make_shared(
            [&canceller_called2](uintptr_t const identifier) { canceller_called2.emplace_back(identifier); });
        canceller_id_2 = canceller->identifier();
        return canceller;
    }};

    syncable.merge(std::move(endable));

    auto dst_endable = syncable.to_endable();

    auto empty_canceller = syncable.sync();
    XCTAssertTrue(empty_canceller);
    XCTAssertEqual(handler_called1.size(), 0);
    XCTAssertEqual(handler_called2, 0);

    auto canceller = dst_endable.end();

    XCTAssertTrue(canceller);

    XCTAssertEqual(handler_called1.size(), 1);
    XCTAssertFalse(handler_called1.at(0));
    XCTAssertEqual(handler_called2, 1);

    canceller->cancel();

    XCTAssertEqual(canceller_called1.size(), 1);
    XCTAssertNotEqual(canceller_id_1, 0);
    XCTAssertEqual(canceller_called1.at(0), canceller_id_1);
    XCTAssertEqual(canceller_called2.size(), 1);
    XCTAssertNotEqual(canceller_id_2, 0);
    XCTAssertEqual(canceller_called2.at(0), canceller_id_2);
}

- (void)test_create_empty {
    observing::syncable syncable;

    auto canceller = syncable.sync();

    XCTAssertTrue(canceller);

    canceller->cancel();
}

- (void)test_create_null {
    observing::syncable syncable{nullptr};

    auto canceller = syncable.sync();

    XCTAssertTrue(canceller);

    canceller->cancel();
}

- (void)test_empty_canceller {
    observing::syncable syncable;

    auto canceller = syncable.sync();

    canceller->cancel();
}

@end
