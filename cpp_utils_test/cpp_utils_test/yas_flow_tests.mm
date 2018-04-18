//
//  yas_flow_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_flow.h"
#import "yas_observing.h"
#import "yas_flow_observing.h"

using namespace yas;

namespace yas::test {
struct receiver : base {
    struct impl : base::impl, flow::receivable<float>::impl {
        std::function<void(float const &)> handler;

        impl(std::function<void(float const &)> &&handler) : handler(std::move(handler)) {
        }

        void receive_value(float const &value) override {
            handler(value);
        }
    };

    receiver(std::function<void(float const &)> handler) : base(std::make_shared<impl>(std::move(handler))) {
    }

    receiver(std::nullptr_t) : base(nullptr) {
    }

    flow::receivable<float> receivable() {
        return flow::receivable<float>{impl_ptr<flow::receivable<float>::impl>()};
    }
};
}

@interface yas_flow_tests : XCTestCase

@end

@implementation yas_flow_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_flow {
    subject<std::string, int> subject;

    std::string received_value = "";

    auto node = begin_flow(subject, std::string("key"))
                    .convert<std::string>([](int const value) { return std::to_string(value); })
                    .perform([&received_value](std::string const &value) { received_value = value; })
                    .end();

    XCTAssertEqual(received_value, "");
    subject.notify("key", 1);
    XCTAssertEqual(received_value, "1");
    subject.notify("key", 2);
    XCTAssertEqual(received_value, "2");
}

- (void)test_wait {
    flow::sender<int> sender;

    auto waitExp = [self expectationWithDescription:@"wait"];

    CFAbsoluteTime begin = 0.0;
    CFAbsoluteTime end = 0.0;
    std::string result = "";

    auto flow = sender.begin_flow()
                    .perform([&begin](int const &value) { begin = CFAbsoluteTimeGetCurrent(); })
                    .wait(0.1)
                    .convert<std::string>([](int const &value) { return std::to_string(value); })
                    .wait(0.1)
                    .perform([waitExp, &end, &result](std::string const &value) {
                        result = value;
                        end = CFAbsoluteTimeGetCurrent();
                        [waitExp fulfill];
                    })
                    .end();

    sender.send_value(10);

    [self waitForExpectations:@[waitExp] timeout:5.0];

    XCTAssertGreaterThan(end - begin, 0.15);
    XCTAssertEqual(result, "10");
}

- (void)test_sync {
    flow::sender<int> sender;
    sender.set_can_send_handler([]() { return true; });
    sender.set_send_handler([]() { return 100; });

    int received = -1;

    auto flow = sender.begin_flow().perform([&received](int const &value) { received = value; }).end();
    flow.sync();

    XCTAssertEqual(received, 100);
}

- (void)test_receive {
    std::string received = "";

    flow::sender<int> sender;
    flow::receiver<std::string> receiver{[&received](std::string const &value) { received = value; }};

    auto node = sender.begin_flow()
                    .convert<std::string>([](int const &value) { return std::to_string(value); })
                    .receive(receiver.receivable())
                    .end();

    sender.send_value(3);

    XCTAssertEqual(received, "3");
}

- (void)test_receive_by_end {
    std::string received = "";

    flow::sender<int> sender;
    flow::receiver<std::string> receiver{[&received](std::string const &value) { received = value; }};

    auto flow = sender.begin_flow()
                    .convert<std::string>([](int const &value) { return std::to_string(value); })
                    .end(receiver.receivable());

    sender.send_value(4);

    XCTAssertEqual(received, "4");
}

- (void)test_guard {
    int received = -1;

    flow::sender<int> sender;

    auto flow = sender.begin_flow()
                    .guard([](int const &value) { return value % 2; })
                    .perform([&received](int const &value) { received = value; })
                    .end();

    sender.send_value(2);

    XCTAssertNotEqual(received, 2);

    sender.send_value(3);

    XCTAssertEqual(received, 3);
}

- (void)test_merge_by_sender {
    std::string received;

    flow::sender<int> sender;
    flow::sender<std::string> sub_sender;

    auto flow = sender.begin_flow()
                    .convert<std::string>([](int const &value) { return std::to_string(value); })
                    .merge(sub_sender)
                    .perform([&received](std::string const &value) { received = value; })
                    .end();

    sender.send_value(1);

    XCTAssertEqual(received, "1");

    sub_sender.send_value("test_text_1");

    XCTAssertEqual(received, "test_text_1");
}

- (void)test_merge_by_node {
    std::string received;

    flow::sender<int> sender;
    flow::sender<float> sub_sender;

    auto sub_flow =
        sub_sender.begin_flow().convert<std::string>([](float const &value) { return std::to_string(int(value)); });

    auto flow = sender.begin_flow()
                    .convert<std::string>([](int const &value) { return std::to_string(value); })
                    .merge(sub_flow)
                    .perform([&received](std::string const &value) { received = value; })
                    .end();

    sender.send_value(10);

    XCTAssertEqual(received, "10");

    sub_sender.send_value(20.0f);

    XCTAssertEqual(received, "20");
}

- (void)test_receiver {
    int received = -1;

    flow::sender<int> sender;

    flow::receiver<int> receiver{[&received](int const &value) { received = value; }};

    auto flow = sender.begin_flow().end(receiver.receivable());

    sender.send_value(100);

    XCTAssertEqual(received, 100);
}

@end
