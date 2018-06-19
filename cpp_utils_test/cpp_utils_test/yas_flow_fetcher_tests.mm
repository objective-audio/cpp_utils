//
//  yas_flow_fetcher_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_flow.h"

using namespace yas;

@interface yas_flow_fetcher_tests : XCTestCase

@end

@implementation yas_flow_fetcher_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_sync {
    int sending = 1;

    flow::fetcher<int> fetcher{[&sending] { return sending; }};

    int notified = -1;

    auto flow = fetcher.begin_flow().perform([&notified](int const &value) { notified = value; }).sync();

    XCTAssertEqual(notified, 1);

    sending = 2;

    fetcher.fetch();

    XCTAssertEqual(notified, 2);
}

- (void)test_receive {
    flow::notifier<std::nullptr_t> sender;

    int sending = 1;

    flow::fetcher<int> fetcher{[&sending] { return sending; }};

    int notified = -1;

    auto flow = fetcher.begin_flow().perform([&notified](int const &value) { notified = value; }).sync();

    XCTAssertEqual(notified, 1);

    sending = 2;

    auto receive_flow = sender.begin_flow().receive(fetcher.receiver()).end();

    sender.notify(nullptr);

    XCTAssertEqual(notified, 2);
}

@end
