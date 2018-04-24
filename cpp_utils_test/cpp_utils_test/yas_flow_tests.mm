//
//  yas_flow_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_flow.h"
#import "yas_observing.h"
#import "yas_flow_observing.h"

using namespace yas;

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

- (void)test_template_begin_flow {
    int received = -1;

    auto flow = flow::begin_flow<int>().perform([&received](int const &value) { received = value; }).end();

    XCTAssertEqual(received, -1);

    flow.sender().send_value(2);

    XCTAssertEqual(received, 2);
}

- (void)test_convert {
    flow::sender<int> sender;

    int received = -1;

    auto flow = sender.begin_flow()
                    .convert([](int const &value) { return value + 1; })
                    .perform([&received](int const &value) { received = value; })
                    .end();

    sender.send_value(10);

    XCTAssertEqual(received, 11);
}

- (void)test_convert_type {
    flow::sender<int> sender;

    std::string received = "";

    auto flow = sender.begin_flow()
                    .guard([](int const &) { return true; })
                    .convert<bool>([](int const &value) { return value > 0; })
                    .guard([](bool const &) { return true; })
                    .convert<std::string>([](bool const &value) { return value ? "true" : "false"; })
                    .guard([](std::string const &) { return true; })
                    .perform([&received](std::string const &value) { received = value; })
                    .end();

    sender.send_value(0);

    XCTAssertEqual(received, "false");

    sender.send_value(1);

    XCTAssertEqual(received, "true");
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

- (void)test_sync_with_combined_sub_sender {
    flow::sender<int> sender;
    sender.set_can_send_handler([]() { return true; });
    sender.set_send_handler([]() { return 123; });

    flow::sender<int> sub_sender;
    sub_sender.set_can_send_handler([]() { return true; });
    sub_sender.set_send_handler([]() { return 456; });

    std::vector<std::pair<int, int>> received;

    auto flow =
        sender.begin_flow()
            .combine(sub_sender.begin_flow())
            .guard([](auto const &pair) { return pair.first && pair.second; })
            .convert<std::pair<int, int>>([](auto const &pair) { return std::make_pair(*pair.first, *pair.second); })
            .perform([&received](auto const &pair) { received.emplace_back(pair); })
            .end();

    flow.sync();

    // 2つのsenderから来た値が両方揃ってから受け取った
    XCTAssertEqual(received.size(), 1);
    XCTAssertEqual(received.at(0).first, 123);
    XCTAssertEqual(received.at(0).second, 456);
}

- (void)test_sync_with_merged_sub_sender {
    flow::sender<int> sender;
    sender.set_can_send_handler([]() { return true; });
    sender.set_send_handler([]() { return 78; });

    flow::sender<int> sub_sender;
    sub_sender.set_can_send_handler([]() { return true; });
    sub_sender.set_send_handler([]() { return 90; });

    std::vector<int> received;

    auto flow = sender.begin_flow()
                    .merge(sub_sender.begin_flow())
                    .perform([&received](int const &value) { received.emplace_back(value); })
                    .end();

    flow.sync();

    // main -> sub の順番で実行される
    XCTAssertEqual(received.size(), 2);
    XCTAssertEqual(received.at(0), 78);
    XCTAssertEqual(received.at(1), 90);
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
    float received = -1.0f;

    flow::sender<int> sender;

    auto flow = sender.begin_flow()
                    .convert<float>([](int const &value) { return value; })
                    .guard([](float const &value) { return value > 2.5f; })
                    .perform([&received](float const &value) { received = value; })
                    .end();

    sender.send_value(2);

    XCTAssertEqual(received, -1.0f);

    sender.send_value(3);

    XCTAssertEqual(received, 3.0f);
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

- (void)test_pair {
    flow::sender<int> main_sender;
    flow::sender<std::string> sub_sender;
    
    using opt_pair_t = std::pair<opt_t<int>, opt_t<std::string>>;
    
    opt_pair_t received;
    
    auto sub_flow = sub_sender.begin_flow();
    auto main_flow =
    main_sender.begin_flow().pair(sub_flow).perform([&received](auto const &value) { received = value; }).end();
    
    main_sender.send_value(1);
    
    XCTAssertEqual(*received.first, 1);
    XCTAssertFalse(!!received.second);
    
    sub_sender.send_value("test_text");
    
    XCTAssertFalse(!!received.first);
    XCTAssertEqual(*received.second, "test_text");
}

- (void)test_combine {
    flow::sender<int> main_sender;
    flow::sender<std::string> sub_sender;

    using opt_pair_t = std::pair<opt_t<int>, opt_t<std::string>>;

    opt_pair_t received;

    auto sub_flow = sub_sender.begin_flow();
    auto main_flow =
        main_sender.begin_flow().combine(sub_flow).perform([&received](auto const &value) { received = value; }).end();

    main_sender.send_value(1);

    XCTAssertEqual(*received.first, 1);
    XCTAssertFalse(!!received.second);

    sub_sender.send_value("test_text");

    XCTAssertEqual(*received.first, 1);
    XCTAssertEqual(*received.second, "test_text");
}

@end
