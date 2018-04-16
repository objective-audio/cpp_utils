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
    subject<std::string, float> subject;

    float received_value = 0.0f;

    auto node = begin_flow(subject, std::string("key"))
                    .change<int>([](float const value) { return int(value * 10.0f); })
                    .perform([&received_value](int const &value) { received_value = value; })
                    .end();

    XCTAssertEqual(received_value, 0.0f);
    subject.notify("key", 1.0f);
    XCTAssertEqual(received_value, 10.0f);
    subject.notify("key", 2.0f);
    XCTAssertEqual(received_value, 20.0f);
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
                    .change<std::string>([](int const &value) { return std::to_string(value); })
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
    float received = 0.0f;

    test::receiver receiver{[&received](float const &value) { received = value; }};

    flow::sender<float> sender;

    auto node = sender.begin_flow().receive(receiver.receivable()).end();

    sender.send_value(3.0f);

    XCTAssertEqual(received, 3.0f);
}

- (void)test_receive_by_end {
    float received = 0.0f;

    test::receiver receiver{[&received](float const &value) { received = value; }};

    flow::sender<float> sender;

    auto node = sender.begin_flow().end(receiver.receivable());

    sender.send_value(4.0f);

    XCTAssertEqual(received, 4.0f);
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
                    .change<std::string>([](int const &value) { return std::to_string(value); })
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
    flow::sender<std::string> sub_sender;

    auto sub_flow = sub_sender.begin_flow();
    auto flow = sender.begin_flow()
                    .change<std::string>([](int const &value) { return std::to_string(value); })
                    .merge(sub_flow)
                    .perform([&received](std::string const &value) { received = value; })
                    .end();

    sender.send_value(10);

    XCTAssertEqual(received, "10");

    sub_sender.send_value("test_text_2");

    XCTAssertEqual(received, "test_text_2");
}

@end
