//
//  yas_flow_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_flow.h"
#import "yas_observing.h"

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

- (void)test_sender_begin {
    int received = -1;

    flow::sender<int> sender;

    auto flow = sender.begin().perform([&received](int const &value) { received = value; }).end();

    XCTAssertEqual(received, -1);

    sender.send_value(2);

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

- (void)test_to {
    flow::sender<int> sender;

    int received = -1;

    auto flow = sender.begin()
                    .map([](int const &value) { return value + 1; })
                    .perform([&received](int const &value) { received = value; })
                    .end();

    sender.send_value(10);

    XCTAssertEqual(received, 11);
}

- (void)test_to_type {
    flow::sender<int> sender;

    std::string received = "";

    auto flow = sender.begin()
                    .filter([](int const &) { return true; })
                    .map([](int const &value) { return value > 0; })
                    .filter([](bool const &) { return true; })
                    .map([](bool const &value) { return value ? "true" : "false"; })
                    .filter([](std::string const &) { return true; })
                    .perform([&received](std::string const &value) { received = value; })
                    .end();

    sender.send_value(0);

    XCTAssertEqual(received, "false");

    sender.send_value(1);

    XCTAssertEqual(received, "true");
}

- (void)test_to_value {
    flow::sender<int> sender;

    std::string received = "";

    auto flow = sender.begin()
                    .to_value(std::string("test_value"))
                    .perform([&received](std::string const &value) { received = value; })
                    .end();

    sender.send_value(0);

    XCTAssertEqual(received, "test_value");
}

- (void)test_to_null {
    flow::sender<int> sender;

    bool called = false;

    auto flow = sender.begin().to_null().perform([&called](std::nullptr_t const &) { called = true; }).end();

    sender.send_value(1);

    XCTAssertTrue(called);
}

- (void)test_to_tuple {
    flow::sender<int> sender;

    opt_t<std::tuple<int>> called;

    auto flow = sender.begin().to_tuple().perform([&called](std::tuple<int> const &value) { called = value; }).end();

    sender.send_value(1);

    XCTAssertTrue(called);
    XCTAssertEqual(std::get<0>(*called), 1);
}

- (void)test_to_tuple_from_tuple {
    flow::sender<std::tuple<int>> sender;

    opt_t<std::tuple<int>> called;

    auto flow = sender.begin().to_tuple().perform([&called](auto const &value) { called = value; }).end();

    sender.send_value(std::make_tuple(int(1)));

    XCTAssertTrue(called);
    XCTAssertEqual(std::get<0>(*called), 1);
}

- (void)test_wait {
    flow::sender<int> sender;

    auto waitExp = [self expectationWithDescription:@"wait"];

    CFAbsoluteTime begin = 0.0;
    CFAbsoluteTime end = 0.0;
    std::string result = "";

    auto flow = sender.begin()
                    .perform([&begin](int const &value) { begin = CFAbsoluteTimeGetCurrent(); })
                    .wait(0.1)
                    .map([](int const &value) { return std::to_string(value); })
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
    sender.set_sync_handler([] { return 100; });

    int received = -1;

    auto flow = sender.begin().perform([&received](int const &value) { received = value; }).end();
    flow.sync();

    XCTAssertEqual(received, 100);
}

- (void)test_sync_by_observer {
    flow::sender<int> sender;
    sender.set_sync_handler([] { return 100; });

    int received = -1;

    flow::observer flow = sender.begin().perform([&received](int const &value) { received = value; }).end();
    flow.sync();

    XCTAssertEqual(received, 100);
}

- (void)test_sync_many_sender {
    flow::sender<int> sender;
    sender.set_sync_handler([] { return 100; });

    int received1 = -1;
    int received2 = -1;

    auto flow1 = sender.begin().perform([&received1](int const &value) { received1 = value; }).end();
    auto flow2 = sender.begin().perform([&received2](int const &value) { received2 = value; }).end();

    flow1.sync();

    XCTAssertEqual(received1, 100);
    XCTAssertEqual(received2, -1);
}

- (void)test_sync_end {
    flow::sender<int> sender;
    sender.set_sync_handler([] { return 100; });

    int received = -1;

    auto flow = sender.begin().perform([&received](int const &value) { received = value; }).sync();

    XCTAssertEqual(received, 100);
}

- (void)test_sync_with_combined_sub_sender {
    flow::sender<int> sender;
    sender.set_sync_handler([]() { return 123; });

    flow::sender<int> sub_sender;
    sub_sender.set_sync_handler([]() { return 456; });

    std::vector<std::pair<int, int>> received;

    auto flow = sender.begin()
                    .combine(sub_sender.begin())
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
    sender.set_sync_handler([]() { return 78; });

    flow::sender<int> sub_sender;
    sub_sender.set_sync_handler([]() { return 90; });

    std::vector<int> received;

    auto flow = sender.begin()
                    .merge(sub_sender.begin())
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

    auto node = sender.begin().map([](int const &value) { return std::to_string(value); }).receive(receiver).end();

    sender.send_value(3);

    XCTAssertEqual(received, "3");
}

- (void)test_receive_tuple {
    flow::sender<std::tuple<int, std::string>> sender;

    int int_received = -1;
    std::string string_received = "";

    flow::receiver<int> int_receiver{[&int_received](int const &value) { int_received = value; }};
    flow::receiver<std::string> string_receiver{
        [&string_received](std::string const &value) { string_received = value; }};

    auto flow = sender.begin().receive<0>(int_receiver).receive<1>(string_receiver).end();

    sender.send_value(std::make_tuple(int(10), std::string("20")));

    XCTAssertEqual(int_received, 10);
    XCTAssertEqual(string_received, "20");
}

- (void)test_receive_null {
    bool received = false;

    flow::sender<int> sender;
    flow::receiver<> receiver{[&received]() { received = true; }};

    auto flow = sender.begin().receive_null(receiver).end();

    sender.send_value(4);

    XCTAssertTrue(received);
}

- (void)test_guard {
    float received = -1.0f;

    flow::sender<int> sender;

    auto flow = sender.begin()
                    .map([](int const &value) { return value; })
                    .filter([](float const &value) { return value > 2.5f; })
                    .perform([&received](float const &value) { received = value; })
                    .end();

    sender.send_value(2);

    XCTAssertEqual(received, -1.0f);

    sender.send_value(3);

    XCTAssertEqual(received, 3.0f);
}

- (void)test_merge {
    std::string received;

    flow::sender<int> sender;
    flow::sender<float> sub_sender;

    auto sub_flow = sub_sender.begin().map([](float const &value) { return std::to_string(int(value)); });

    auto flow = sender.begin()
                    .map([](int const &value) { return std::to_string(value); })
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

    auto flow = sender.begin().receive(receiver).end();

    sender.send_value(100);

    XCTAssertEqual(received, 100);
}

- (void)test_pair {
    flow::sender<int> main_sender;
    flow::sender<std::string> sub_sender;

    using opt_pair_t = std::pair<opt_t<int>, opt_t<std::string>>;

    opt_pair_t received;

    auto sub_flow = sub_sender.begin();
    auto main_flow =
        main_sender.begin().pair(sub_flow).perform([&received](auto const &value) { received = value; }).end();

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

    using opt_pair_t = opt_t<std::pair<int, std::string>>;

    opt_pair_t received;

    auto sub_flow = sub_sender.begin();
    auto main_flow =
        main_sender.begin().combine(sub_flow).perform([&received](auto const &value) { received = value; }).end();

    main_sender.send_value(1);

    XCTAssertFalse(received);

    sub_sender.send_value("test_text");

    XCTAssertTrue(received);
    XCTAssertEqual(received->first, 1);
    XCTAssertEqual(received->second, "test_text");
}

- (void)test_combine_tuples {
    flow::sender<int> main_sender;
    flow::sender<std::string> sub_sender;

    auto sub_flow = sub_sender.begin().to_tuple();
    auto main_flow = main_sender.begin().to_tuple();

    opt_t<std::tuple<int, std::string>> received;

    auto flow = main_flow.combine(sub_flow)
                    .perform([&received](std::tuple<int, std::string> const &value) { received = value; })
                    .end();

    main_sender.send_value(33);
    sub_sender.send_value("44");

    XCTAssertTrue(received);
    XCTAssertEqual(std::get<0>(*received), 33);
    XCTAssertEqual(std::get<1>(*received), "44");
}

- (void)test_normalize {
    flow::sender<int> sender;

    flow::node<std::string, int, int> toed_flow =
        sender.begin().map([](int const &value) { return std::to_string(value); });

    flow::node<std::string, std::string, int> normalized_flow = toed_flow.normalize();

    std::string received = "";

    flow::typed_observer<int> observer =
        normalized_flow.perform([&received](std::string const &value) { received = value; }).end();

    sender.send_value(10);

    XCTAssertEqual(received, "10");
}

- (void)test_node_type_1 {
    flow::sender<int> sender;

    flow::node<int> node = sender.begin();

    bool called = false;

    auto flow = node.perform([&called](auto const &) { called = true; }).end();

    sender.send_value(10);

    XCTAssertTrue(called);
}

- (void)test_node_type_2 {
    flow::sender<int> sender;

    flow::node<std::string, int> node = sender.begin().map([](int const &value) { return std::to_string(value); });

    bool called = false;

    auto flow = node.perform([&called](auto const &) { called = true; }).end();

    sender.send_value(20);

    XCTAssertTrue(called);
}

@end
