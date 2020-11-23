//
//  yas_playing_background_queue_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/cpp_utils.h>

using namespace yas;

namespace yas::playing_test {
struct counter {
    int value = 0;

    int pull() {
        int prev = this->value;
        this->value += 1;
        return prev;
    }
};
}

@interface yas_playing_background_queue_tests : XCTestCase

@end

@implementation yas_playing_background_queue_tests

- (void)test_all_unprocessed {
    NSMutableArray<XCTestExpectation *> *expectations = [[NSMutableArray alloc] init];

    for (int i = 0; i < 6; ++i) {
        [expectations addObject:[self expectationWithDescription:@""]];
    }

    auto const queue = background_queue::make_shared();

    queue->add_task(1, [&expectations, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [expectations[1] fulfill];
        } else if (count == 1) {
            [expectations[4] fulfill];
        }
        return background_queue::task_result::unprocessed;
    });

    queue->add_task(2, [&expectations, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [expectations[2] fulfill];
        } else if (count == 1) {
            [expectations[5] fulfill];
        }
        return background_queue::task_result::unprocessed;
    });

    queue->add_task(0, [&expectations, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [expectations[0] fulfill];
        } else if (count == 1) {
            [expectations[3] fulfill];
        }
        return background_queue::task_result::unprocessed;
    });

    queue->start();

    [self waitForExpectations:expectations timeout:10.0 enforceOrder:YES];
}

- (void)test_processed {
    NSMutableArray<XCTestExpectation *> *expectations = [[NSMutableArray alloc] init];

    for (int i = 0; i < 8; ++i) {
        [expectations addObject:[self expectationWithDescription:@""]];
    }

    auto const queue = background_queue::make_shared();

    queue->add_task(0, [&expectations, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [expectations[0] fulfill];
            return background_queue::task_result::processed;
        } else if (count == 1) {
            [expectations[1] fulfill];
            return background_queue::task_result::processed;
        } else if (count == 2) {
            [expectations[2] fulfill];
        } else if (count == 3) {
            [expectations[5] fulfill];
        }
        return background_queue::task_result::unprocessed;
    });

    queue->add_task(1, [&expectations, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [expectations[3] fulfill];
        } else if (count == 1) {
            [expectations[6] fulfill];
        }
        return background_queue::task_result::unprocessed;
    });

    queue->add_task(2, [&expectations, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [expectations[4] fulfill];
            return background_queue::task_result::processed;
        } else if (count == 1) {
            [expectations[7] fulfill];
        }
        return background_queue::task_result::unprocessed;
    });

    queue->start();

    [self waitForExpectations:expectations timeout:10.0 enforceOrder:YES];
}

- (void)test_completed {
    NSMutableArray<XCTestExpectation *> *expectations = [[NSMutableArray alloc] init];

    for (int i = 0; i < 5; ++i) {
        [expectations addObject:[self expectationWithDescription:@""]];
    }

    auto const queue = background_queue::make_shared();

    queue->add_task(0, [&expectations, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [expectations[0] fulfill];
        } else if (count == 1) {
            [expectations[3] fulfill];
        }
        return background_queue::task_result::unprocessed;
    });

    queue->add_task(1, [&expectations, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [expectations[1] fulfill];
            return background_queue::task_result::completed;
        } else {
            XCTFail();
            return background_queue::task_result::unprocessed;
        }
    });

    queue->add_task(2, [&expectations, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [expectations[2] fulfill];
        } else if (count == 1) {
            [expectations[4] fulfill];
        }
        return background_queue::task_result::unprocessed;
    });

    queue->start();

    [self waitForExpectations:expectations timeout:10.0 enforceOrder:YES];
}

@end
