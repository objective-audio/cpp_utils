//
//  yas_flow_synchronizer_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_flow.h"

using namespace yas;

@interface yas_flow_synchronizer_tests : XCTestCase

@end

@implementation yas_flow_synchronizer_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_sync {
    int sending = 1;

    flow::synchronizer<int> synchronizer{[&sending] { return sending; }};

    int notified = -1;

    auto flow = synchronizer.begin_flow().perform([&notified](int const &value) { notified = value; }).sync();

    XCTAssertEqual(notified, 1);

    sending = 2;

    synchronizer.sync();

    XCTAssertEqual(notified, 2);
}

- (void)test_receive {
    flow::notifier<std::nullptr_t> sender;

    int sending = 1;

    flow::synchronizer<int> synchronizer{[&sending] { return sending; }};

    int notified = -1;

    auto flow = synchronizer.begin_flow().perform([&notified](int const &value) { notified = value; }).sync();

    XCTAssertEqual(notified, 1);

    sending = 2;

    auto receive_flow = sender.begin_flow().receive(synchronizer.receiver()).end();

    sender.notify(nullptr);

    XCTAssertEqual(notified, 2);
}

@end
