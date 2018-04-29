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

    auto node = flow::begin(subject, std::string("key"))
                    .convert<std::string>([](int const value) { return std::to_string(value); })
                    .perform([&received_value](std::string const &value) { received_value = value; })
                    .end();

    XCTAssertEqual(received_value, "");
    subject.notify("key", 1);
    XCTAssertEqual(received_value, "1");
    subject.notify("key", 2);
    XCTAssertEqual(received_value, "2");
}

- (void)test_input_begin {
    int received = -1;

    flow::input<int> input;

    auto flow = input.begin().perform([&received](int const &value) { received = value; }).end();

    XCTAssertEqual(received, -1);

    input.send_value(2);

    XCTAssertEqual(received, 2);
}

- (void)test_sender_many_begin {
    int received1 = -1;
    int received2 = -1;

    flow::sender<int> sender;

    auto flow1 = sender.begin().perform([&received1](int const &value) { received1 = value; }).end();
    auto flow2 = sender.begin().perform([&received2](int const &value) { received2 = value; }).end();

    sender.send_value(3);

    XCTAssertEqual(received1, 3);
    XCTAssertEqual(received2, 3);
}

- (void)test_template_begin {
    int received = -1;

    auto flow = flow::begin<int>().perform([&received](int const &value) { received = value; }).end();

    XCTAssertEqual(received, -1);

    flow.input().send_value(2);

    XCTAssertEqual(received, 2);
}

- (void)test_convert {
    flow::input<int> input;

    int received = -1;

    auto flow = input.begin()
                    .convert([](int const &value) { return value + 1; })
                    .perform([&received](int const &value) { received = value; })
                    .end();

    input.send_value(10);

    XCTAssertEqual(received, 11);
}

- (void)test_convert_type {
    flow::input<int> input;

    std::string received = "";

    auto flow = input.begin()
                    .guard([](int const &) { return true; })
                    .convert<bool>([](int const &value) { return value > 0; })
                    .guard([](bool const &) { return true; })
                    .convert<std::string>([](bool const &value) { return value ? "true" : "false"; })
                    .guard([](std::string const &) { return true; })
                    .perform([&received](std::string const &value) { received = value; })
                    .end();

    input.send_value(0);

    XCTAssertEqual(received, "false");

    input.send_value(1);

    XCTAssertEqual(received, "true");
}

- (void)test_wait {
    flow::input<int> input;

    auto waitExp = [self expectationWithDescription:@"wait"];

    CFAbsoluteTime begin = 0.0;
    CFAbsoluteTime end = 0.0;
    std::string result = "";

    auto flow = input.begin()
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

    input.send_value(10);

    [self waitForExpectations:@[waitExp] timeout:5.0];

    XCTAssertGreaterThan(end - begin, 0.15);
    XCTAssertEqual(result, "10");
}

- (void)test_sync {
    flow::input<int> input;
    input.set_can_send_handler([]() { return true; });
    input.set_send_handler([]() { return 100; });

    int received = -1;

    auto flow = input.begin().perform([&received](int const &value) { received = value; }).end();
    flow.sync();

    XCTAssertEqual(received, 100);
}

- (void)test_sync_with_combined_sub_input {
    flow::input<int> input;
    input.set_can_send_handler([]() { return true; });
    input.set_send_handler([]() { return 123; });

    flow::input<int> sub_input;
    sub_input.set_can_send_handler([]() { return true; });
    sub_input.set_send_handler([]() { return 456; });

    std::vector<std::pair<int, int>> received;

    auto flow =
        input.begin()
            .combine(sub_input.begin())
            .guard([](auto const &pair) { return pair.first && pair.second; })
            .convert<std::pair<int, int>>([](auto const &pair) { return std::make_pair(*pair.first, *pair.second); })
            .perform([&received](auto const &pair) { received.emplace_back(pair); })
            .end();

    flow.sync();

    // 2つのinputから来た値が両方揃ってから受け取った
    XCTAssertEqual(received.size(), 1);
    XCTAssertEqual(received.at(0).first, 123);
    XCTAssertEqual(received.at(0).second, 456);
}

- (void)test_sync_with_merged_sub_input {
    flow::input<int> input;
    input.set_can_send_handler([]() { return true; });
    input.set_send_handler([]() { return 78; });

    flow::input<int> sub_input;
    sub_input.set_can_send_handler([]() { return true; });
    sub_input.set_send_handler([]() { return 90; });

    std::vector<int> received;

    auto flow = input.begin()
                    .merge(sub_input.begin())
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

    flow::input<int> input;
    flow::receiver<std::string> receiver{[&received](std::string const &value) { received = value; }};

    auto node = input.begin()
                    .convert<std::string>([](int const &value) { return std::to_string(value); })
                    .receive(receiver.receivable())
                    .end();

    input.send_value(3);

    XCTAssertEqual(received, "3");
}

- (void)test_receive_by_end {
    std::string received = "";

    flow::input<int> input;
    flow::receiver<std::string> receiver{[&received](std::string const &value) { received = value; }};

    auto flow = input.begin()
                    .convert<std::string>([](int const &value) { return std::to_string(value); })
                    .end(receiver.receivable());

    input.send_value(4);

    XCTAssertEqual(received, "4");
}

- (void)test_guard {
    float received = -1.0f;

    flow::input<int> input;

    auto flow = input.begin()
                    .convert<float>([](int const &value) { return value; })
                    .guard([](float const &value) { return value > 2.5f; })
                    .perform([&received](float const &value) { received = value; })
                    .end();

    input.send_value(2);

    XCTAssertEqual(received, -1.0f);

    input.send_value(3);

    XCTAssertEqual(received, 3.0f);
}

- (void)test_merge {
    std::string received;

    flow::input<int> input;
    flow::input<float> sub_input;

    auto sub_flow =
        sub_input.begin().convert<std::string>([](float const &value) { return std::to_string(int(value)); });

    auto flow = input.begin()
                    .convert<std::string>([](int const &value) { return std::to_string(value); })
                    .merge(sub_flow)
                    .perform([&received](std::string const &value) { received = value; })
                    .end();

    input.send_value(10);

    XCTAssertEqual(received, "10");

    sub_input.send_value(20.0f);

    XCTAssertEqual(received, "20");
}

- (void)test_receiver {
    int received = -1;

    flow::input<int> input;

    flow::receiver<int> receiver{[&received](int const &value) { received = value; }};

    auto flow = input.begin().end(receiver.receivable());

    input.send_value(100);

    XCTAssertEqual(received, 100);
}

- (void)test_pair {
    flow::input<int> main_input;
    flow::input<std::string> sub_input;

    using opt_pair_t = std::pair<opt_t<int>, opt_t<std::string>>;

    opt_pair_t received;

    auto sub_flow = sub_input.begin();
    auto main_flow =
        main_input.begin().pair(sub_flow).perform([&received](auto const &value) { received = value; }).end();

    main_input.send_value(1);

    XCTAssertEqual(*received.first, 1);
    XCTAssertFalse(!!received.second);

    sub_input.send_value("test_text");

    XCTAssertFalse(!!received.first);
    XCTAssertEqual(*received.second, "test_text");
}

- (void)test_combine {
    flow::input<int> main_input;
    flow::input<std::string> sub_input;

    using opt_pair_t = std::pair<opt_t<int>, opt_t<std::string>>;

    opt_pair_t received;

    auto sub_flow = sub_input.begin();
    auto main_flow =
        main_input.begin().combine(sub_flow).perform([&received](auto const &value) { received = value; }).end();

    main_input.send_value(1);

    XCTAssertEqual(*received.first, 1);
    XCTAssertFalse(!!received.second);

    sub_input.send_value("test_text");

    XCTAssertEqual(*received.first, 1);
    XCTAssertEqual(*received.second, "test_text");
}

@end
