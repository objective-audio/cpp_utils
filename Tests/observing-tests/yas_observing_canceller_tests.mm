//
//  yas_canceller_tests.mm
//

#import <XCTest/XCTest.h>
#import <observing/yas_observing_umbrella.hpp>
#import <vector>

using namespace yas;
using namespace yas::observing;

@interface yas_observing_canceller_tests : XCTestCase

@end

@implementation yas_observing_canceller_tests

- (void)test_destructor {
    std::vector<uintptr_t> called;

    {
        auto remover = [&called](uintptr_t const identifier) { called.emplace_back(identifier); };

        auto const canceller = canceller::make_shared(std::move(remover));

        XCTAssertEqual(called.size(), 0);
    }

    XCTAssertEqual(called.size(), 1);
}

- (void)test_cancel {
    std::vector<uintptr_t> called;

    {
        auto remover = [&called](uintptr_t const identifier) { called.emplace_back(identifier); };

        auto const canceller = canceller::make_shared(std::move(remover));

        canceller->cancel();

        XCTAssertEqual(called.size(), 1);
    }

    XCTAssertEqual(called.size(), 1);
}

- (void)test_ignore {
    std::vector<uintptr_t> called;

    {
        auto remover = [&called](uintptr_t const identifier) { called.emplace_back(identifier); };

        auto const canceller = canceller::make_shared(std::move(remover));

        canceller->ignore();

        XCTAssertEqual(called.size(), 0);
    }

    XCTAssertEqual(called.size(), 0);
}

- (void)test_set_to {
    std::vector<uintptr_t> called;

    {
        cancellable_ptr canceller = nullptr;
        {
            auto remover = [&called](uintptr_t const identifier) { called.emplace_back(identifier); };

            canceller::make_shared(std::move(remover))->set_to(canceller);

            XCTAssertEqual(called.size(), 0);
        }
        XCTAssertEqual(called.size(), 0);
    }
    XCTAssertEqual(called.size(), 1);
}

- (void)test_has_cancellable {
    auto const canceller = canceller::make_shared([](uintptr_t const identifier) {});

    XCTAssertTrue(canceller->has_cancellable());

    canceller->cancel();

    XCTAssertFalse(canceller->has_cancellable());
}

- (void)test_identifier {
    auto const canceller = canceller::make_shared([](uintptr_t const identifier) {});

    XCTAssertEqual(canceller->identifier(), reinterpret_cast<uintptr_t>(canceller.get()));
}

@end
