//
//  yas_worker_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/yas_worker.h>

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

@interface yas_worker_tests : XCTestCase

@end

@implementation yas_worker_tests

- (void)test_all_unprocessed {
    NSMutableArray<XCTestExpectation *> *expectations = [[NSMutableArray alloc] init];

    for (int i = 0; i < 6; ++i) {
        [expectations addObject:[self expectationWithDescription:@""]];
    }

    auto const worker = worker::make_shared();

    worker->add_task(1, [&expectations, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [expectations[1] fulfill];
        } else if (count == 1) {
            [expectations[4] fulfill];
        }
        return worker::task_result::unprocessed;
    });

    worker->add_task(2, [&expectations, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [expectations[2] fulfill];
        } else if (count == 1) {
            [expectations[5] fulfill];
        }
        return worker::task_result::unprocessed;
    });

    worker->add_task(0, [&expectations, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [expectations[0] fulfill];
        } else if (count == 1) {
            [expectations[3] fulfill];
        }
        return worker::task_result::unprocessed;
    });

    worker->start();

    [self waitForExpectations:expectations timeout:10.0 enforceOrder:YES];
}

- (void)test_processed {
    NSMutableArray<XCTestExpectation *> *expectations = [[NSMutableArray alloc] init];

    for (int i = 0; i < 8; ++i) {
        [expectations addObject:[self expectationWithDescription:@""]];
    }

    auto const worker = worker::make_shared();

    worker->add_task(0, [&expectations, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [expectations[0] fulfill];
            return worker::task_result::processed;
        } else if (count == 1) {
            [expectations[1] fulfill];
            return worker::task_result::processed;
        } else if (count == 2) {
            [expectations[2] fulfill];
        } else if (count == 3) {
            [expectations[5] fulfill];
        }
        return worker::task_result::unprocessed;
    });

    worker->add_task(1, [&expectations, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [expectations[3] fulfill];
        } else if (count == 1) {
            [expectations[6] fulfill];
        }
        return worker::task_result::unprocessed;
    });

    worker->add_task(2, [&expectations, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [expectations[4] fulfill];
            return worker::task_result::processed;
        } else if (count == 1) {
            [expectations[7] fulfill];
        }
        return worker::task_result::unprocessed;
    });

    worker->start();

    [self waitForExpectations:expectations timeout:10.0 enforceOrder:YES];
}

- (void)test_completed {
    NSMutableArray<XCTestExpectation *> *expectations = [[NSMutableArray alloc] init];

    for (int i = 0; i < 5; ++i) {
        [expectations addObject:[self expectationWithDescription:@""]];
    }

    auto const worker = worker::make_shared();

    worker->add_task(0, [&expectations, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [expectations[0] fulfill];
        } else if (count == 1) {
            [expectations[3] fulfill];
        }
        return worker::task_result::unprocessed;
    });

    worker->add_task(1, [&expectations, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [expectations[1] fulfill];
            return worker::task_result::completed;
        } else {
            XCTFail();
            return worker::task_result::unprocessed;
        }
    });

    worker->add_task(2, [&expectations, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [expectations[2] fulfill];
        } else if (count == 1) {
            [expectations[4] fulfill];
        }
        return worker::task_result::unprocessed;
    });

    worker->start();

    [self waitForExpectations:expectations timeout:10.0 enforceOrder:YES];
}

- (void)test_stub_all_unprocessed {
    NSMutableArray<XCTestExpectation *> *exps0 = [[NSMutableArray alloc] init];
    NSMutableArray<XCTestExpectation *> *exps1 = [[NSMutableArray alloc] init];

    for (int i = 0; i < 3; ++i) {
        [exps0 addObject:[self expectationWithDescription:@""]];
        [exps1 addObject:[self expectationWithDescription:@""]];
    }

    auto const worker = worker_stub::make_shared();

    worker->add_task(1, [&exps0, &exps1, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [exps0[1] fulfill];
        } else if (count == 1) {
            [exps1[1] fulfill];
        }
        return worker::task_result::unprocessed;
    });

    worker->add_task(2, [&exps0, &exps1, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [exps0[2] fulfill];
        } else if (count == 1) {
            [exps1[2] fulfill];
        }
        return worker::task_result::unprocessed;
    });

    worker->add_task(0, [&exps0, &exps1, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [exps0[0] fulfill];
        } else if (count == 1) {
            [exps1[0] fulfill];
        }
        return worker::task_result::unprocessed;
    });

    worker->start();

    worker->process();

    [self waitForExpectations:exps0 timeout:10.0 enforceOrder:YES];

    worker->process();

    [self waitForExpectations:exps1 timeout:10.0 enforceOrder:YES];

    XCTAssertEqual(worker->resource_tasks().size(), 3);
}

- (void)test_stub_processed {
    NSMutableArray<XCTestExpectation *> *exps0 = [[NSMutableArray alloc] init];
    NSMutableArray<XCTestExpectation *> *exps1 = [[NSMutableArray alloc] init];
    NSMutableArray<XCTestExpectation *> *exps2 = [[NSMutableArray alloc] init];
    NSMutableArray<XCTestExpectation *> *exps3 = [[NSMutableArray alloc] init];

    [exps0 addObject:[self expectationWithDescription:@""]];
    [exps1 addObject:[self expectationWithDescription:@""]];
    [exps2 addObject:[self expectationWithDescription:@""]];
    [exps2 addObject:[self expectationWithDescription:@""]];
    [exps2 addObject:[self expectationWithDescription:@""]];
    [exps3 addObject:[self expectationWithDescription:@""]];
    [exps3 addObject:[self expectationWithDescription:@""]];
    [exps3 addObject:[self expectationWithDescription:@""]];

    auto const worker = worker_stub::make_shared();

    worker->add_task(0, [&exps0, &exps1, &exps2, &exps3, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [exps0[0] fulfill];
            return worker::task_result::processed;
        } else if (count == 1) {
            [exps1[0] fulfill];
            return worker::task_result::processed;
        } else if (count == 2) {
            [exps2[0] fulfill];
        } else if (count == 3) {
            [exps3[0] fulfill];
        }
        return worker::task_result::unprocessed;
    });

    worker->add_task(1, [&exps2, &exps3, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [exps2[1] fulfill];
        } else if (count == 1) {
            [exps3[1] fulfill];
        }
        return worker::task_result::unprocessed;
    });

    worker->add_task(2, [&exps2, &exps3, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [exps2[2] fulfill];
            return worker::task_result::processed;
        } else if (count == 1) {
            [exps3[2] fulfill];
        }
        return worker::task_result::unprocessed;
    });

    worker->start();

    worker->process();

    [self waitForExpectations:exps0 timeout:10.0 enforceOrder:YES];

    worker->process();

    [self waitForExpectations:exps1 timeout:10.0 enforceOrder:YES];

    worker->process();

    [self waitForExpectations:exps2 timeout:10.0 enforceOrder:YES];

    worker->process();

    [self waitForExpectations:exps3 timeout:10.0 enforceOrder:YES];

    XCTAssertEqual(worker->resource_tasks().size(), 3);
}

- (void)test_stub_completed {
    NSMutableArray<XCTestExpectation *> *exps0 = [[NSMutableArray alloc] init];
    NSMutableArray<XCTestExpectation *> *exps1 = [[NSMutableArray alloc] init];

    [exps0 addObject:[self expectationWithDescription:@""]];
    [exps0 addObject:[self expectationWithDescription:@""]];
    [exps0 addObject:[self expectationWithDescription:@""]];
    [exps1 addObject:[self expectationWithDescription:@""]];
    [exps1 addObject:[self expectationWithDescription:@""]];

    auto const worker = worker_stub::make_shared();

    worker->add_task(0, [&exps0, &exps1, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [exps0[0] fulfill];
        } else if (count == 1) {
            [exps1[0] fulfill];
        }
        return worker::task_result::unprocessed;
    });

    worker->add_task(1, [&exps0, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [exps0[1] fulfill];
            return worker::task_result::completed;
        } else {
            XCTFail();
            return worker::task_result::unprocessed;
        }
    });

    worker->add_task(2, [&exps0, &exps1, counter = std::make_shared<playing_test::counter>()] {
        int const count = counter->pull();
        if (count == 0) {
            [exps0[2] fulfill];
        } else if (count == 1) {
            [exps1[1] fulfill];
        }
        return worker::task_result::unprocessed;
    });

    worker->start();

    XCTAssertEqual(worker->resource_tasks().size(), 3);

    worker->process();

    [self waitForExpectations:exps0 timeout:10.0 enforceOrder:YES];

    XCTAssertEqual(worker->resource_tasks().size(), 2);

    worker->process();

    [self waitForExpectations:exps1 timeout:10.0 enforceOrder:YES];

    XCTAssertEqual(worker->resource_tasks().size(), 2);
}

@end
