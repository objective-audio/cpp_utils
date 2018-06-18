//
//  yas_flow_notifier_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_flow.h"

using namespace yas;

@interface yas_flow_notifier_tests : XCTestCase

@end

@implementation yas_flow_notifier_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_notifier_begin {
    int received = -1;

    flow::notifier<int> notifier;

    auto flow = notifier.begin_flow().perform([&received](int const &value) { received = value; }).end();

    XCTAssertEqual(received, -1);

    notifier.send_value(2);

    XCTAssertEqual(received, 2);
}

- (void)test_notifier_many_begin {
    int received1 = -1;
    int received2 = -1;

    flow::notifier<int> notifier;

    auto flow1 = notifier.begin_flow().perform([&received1](int const &value) { received1 = value; }).end();
    auto flow2 = notifier.begin_flow().perform([&received2](int const &value) { received2 = value; }).end();

    notifier.send_value(3);

    XCTAssertEqual(received1, 3);
    XCTAssertEqual(received2, 3);
}

- (void)test_notifier_receiver {
    int received = -1;

    flow::notifier<int> notifier1;
    flow::notifier<int> notifier2;

    auto flow1 = notifier1.begin_flow().receive(notifier2.receiver()).end();
    auto flow2 = notifier2.begin_flow().perform([&received](int const &value) { received = value; }).end();

    notifier1.send_value(4);

    XCTAssertEqual(received, 4);
}

- (void)test_notifier_block_recursive_call {
    int received = -1;

    flow::notifier<int> notifier;

    flow::receiver<int> receiver{[&notifier, &received](int const &value) {
        received = value;
        notifier.send_value(value + 1);
    }};

    auto flow = notifier.begin_flow().receive(receiver).end();

    notifier.send_value(1);

    XCTAssertEqual(received, 1);
}

@end
