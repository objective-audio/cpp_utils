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

    auto flow = sender.begin_flow().perform([&received](int const &value) { received = value; }).end();

    XCTAssertEqual(received, -1);

    sender.send_value(2);

    XCTAssertEqual(received, 2);
}

- (void)test_sender_many_begin {
    int received1 = -1;
    int received2 = -1;

    flow::sender<int> sender;

    auto flow1 = sender.begin_flow().perform([&received1](int const &value) { received1 = value; }).end();
    auto flow2 = sender.begin_flow().perform([&received2](int const &value) { received2 = value; }).end();

    sender.send_value(3);

    XCTAssertEqual(received1, 3);
    XCTAssertEqual(received2, 3);
}

- (void)test_sender_receiver {
    int received = -1;

    flow::sender<int> sender1;
    flow::sender<int> sender2;

    auto flow1 = sender1.begin_flow().receive(sender2.receiver()).end();
    auto flow2 = sender2.begin_flow().perform([&received](int const &value) { received = value; }).end();

    sender1.send_value(4);

    XCTAssertEqual(received, 4);
}

- (void)test_sender_block_recursive_call {
    int received = -1;

    flow::sender<int> sender;

    flow::receiver<int> receiver{[&sender, &received](int const &value) {
        received = value;
        sender.send_value(value + 1);
    }};

    auto flow = sender.begin_flow().receive(receiver).end();

    sender.send_value(1);

    XCTAssertEqual(received, 1);
}

- (void)test_to {
    flow::sender<int> sender;

    int received = -1;

    auto flow = sender.begin_flow()
                    .map([](int const &value) { return value + 1; })
                    .perform([&received](int const &value) { received = value; })
                    .end();

    sender.send_value(10);

    XCTAssertEqual(received, 11);
}

- (void)test_to_type {
    flow::sender<int> sender;

    std::string received = "";

    auto flow = sender.begin_flow()
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

    auto flow = sender.begin_flow()
                    .to_value(std::string("test_value"))
                    .perform([&received](std::string const &value) { received = value; })
                    .end();

    sender.send_value(0);

    XCTAssertEqual(received, "test_value");
}

- (void)test_to_null {
    flow::sender<int> sender;

    bool called = false;

    auto flow = sender.begin_flow().to_null().perform([&called](std::nullptr_t const &) { called = true; }).end();

    sender.send_value(1);

    XCTAssertTrue(called);
}

- (void)test_to_tuple {
    flow::sender<int> sender;

    opt_t<std::tuple<int>> called;

    auto flow =
        sender.begin_flow().to_tuple().perform([&called](std::tuple<int> const &value) { called = value; }).end();

    sender.send_value(1);

    XCTAssertTrue(called);
    XCTAssertEqual(std::get<0>(*called), 1);
}

- (void)test_to_tuple_from_tuple {
    flow::sender<std::tuple<int>> sender;

    opt_t<std::tuple<int>> called;

    auto flow = sender.begin_flow().to_tuple().perform([&called](auto const &value) { called = value; }).end();

    sender.send_value(std::make_tuple(int(1)));

    XCTAssertTrue(called);
    XCTAssertEqual(std::get<0>(*called), 1);
}

- (void)test_to_tuple_from_pair {
    flow::sender<std::pair<int, std::string>> sender;

    opt_t<std::tuple<int, std::string>> called;

    auto flow = sender.begin_flow().to_tuple().perform([&called](auto const &value) { called = value; }).end();

    sender.send_value(std::make_pair(int(1), std::string("2")));

    XCTAssertTrue(called);
    XCTAssertEqual(std::get<0>(*called), 1);
    XCTAssertEqual(std::get<1>(*called), "2");
}

- (void)test_sync {
    flow::sync_sender<int> sender;
    sender.set_sync_handler([] { return 100; });

    int received = -1;

    auto flow = sender.begin_flow().perform([&received](int const &value) { received = value; }).end();
    flow.sync();

    XCTAssertEqual(received, 100);
}

- (void)test_sync_by_observer {
    flow::sync_sender<int> sender;
    sender.set_sync_handler([] { return 100; });

    int received = -1;

    flow::observer flow = sender.begin_flow().perform([&received](int const &value) { received = value; }).end();
    flow.sync();

    XCTAssertEqual(received, 100);
}

- (void)test_sync_many_sender {
    flow::sync_sender<int> sender;
    sender.set_sync_handler([] { return 100; });

    int received1 = -1;
    int received2 = -1;

    auto flow1 = sender.begin_flow().perform([&received1](int const &value) { received1 = value; }).end();
    auto flow2 = sender.begin_flow().perform([&received2](int const &value) { received2 = value; }).end();

    flow1.sync();

    XCTAssertEqual(received1, 100);
    XCTAssertEqual(received2, -1);
}

- (void)test_sync_end {
    flow::sync_sender<int> sender;
    sender.set_sync_handler([] { return 100; });

    int received = -1;

    auto flow = sender.begin_flow().perform([&received](int const &value) { received = value; }).sync();

    XCTAssertEqual(received, 100);
}

- (void)test_sync_with_combined_sub_sender {
    flow::sync_sender<int> sender;
    sender.set_sync_handler([]() { return 123; });

    flow::sync_sender<int> sub_sender;
    sub_sender.set_sync_handler([]() { return 456; });

    std::vector<std::pair<int, int>> received;

    auto flow = sender.begin_flow()
                    .combine(sub_sender.begin_flow())
                    .perform([&received](auto const &pair) { received.emplace_back(pair); })
                    .sync();

    // 2つのsenderから来た値が両方揃ってから受け取った
    XCTAssertEqual(received.size(), 1);
    XCTAssertEqual(received.at(0).first, 123);
    XCTAssertEqual(received.at(0).second, 456);
}

- (void)test_sync_with_merged_sub_sender {
    flow::sync_sender<int> sender;
    sender.set_sync_handler([]() { return 78; });

    flow::sync_sender<int> sub_sender;
    sub_sender.set_sync_handler([]() { return 90; });

    std::vector<int> received;

    auto flow = sender.begin_flow()
                    .merge(sub_sender.begin_flow())
                    .perform([&received](int const &value) { received.emplace_back(value); })
                    .sync();

    // main -> sub の順番で実行される
    XCTAssertEqual(received.size(), 2);
    XCTAssertEqual(received.at(0), 78);
    XCTAssertEqual(received.at(1), 90);
}

- (void)test_receive {
    std::string received = "";

    flow::sender<int> sender;
    flow::receiver<std::string> receiver{[&received](std::string const &value) { received = value; }};

    auto node = sender.begin_flow().map([](int const &value) { return std::to_string(value); }).receive(receiver).end();

    sender.send_value(3);

    XCTAssertEqual(received, "3");
}

- (void)test_receive_array {
    flow::sender<std::array<int, 2>> sender;
    int received0 = -1;
    int received1 = -1;

    flow::receiver<int> receiver0{[&received0](int const &value) { received0 = value; }};
    flow::receiver<int> receiver1{[&received1](int const &value) { received1 = value; }};
    std::array<flow::receiver<int>, 2> receivers{receiver0, receiver1};

    flow::observer flow = sender.begin_flow().receive(receivers).end();

    sender.send_value(std::array<int, 2>{10, 20});

    XCTAssertEqual(received0, 10);
    XCTAssertEqual(received1, 20);
}

- (void)test_receive_array_individual {
    flow::sender<std::array<int, 2>> sender;
    int received0 = -1;
    int received1 = -1;

    flow::receiver<int> receiver0{[&received0](int const &value) { received0 = value; }};
    flow::receiver<int> receiver1{[&received1](int const &value) { received1 = value; }};

    flow::observer flow = sender.begin_flow().receive<0>(receiver0).receive<1>(receiver1).end();

    sender.send_value(std::array<int, 2>{10, 20});

    XCTAssertEqual(received0, 10);
    XCTAssertEqual(received1, 20);
}

- (void)test_receiver_vector {
    flow::sender<std::vector<int>> sender;
    int received0 = -1;
    int received1 = -1;

    flow::receiver<int> receiver0{[&received0](int const &value) { received0 = value; }};
    flow::receiver<int> receiver1{[&received1](int const &value) { received1 = value; }};
    std::vector<flow::receiver<int>> receivers{receiver0, receiver1};

    flow::observer flow = sender.begin_flow().receive(receivers).end();

    sender.send_value(std::vector<int>{30, 40});

    XCTAssertEqual(received0, 30);
    XCTAssertEqual(received1, 40);
}

- (void)test_receiver_initializer_list {
    flow::sender<std::vector<int>> sender;
    int received0 = -1;
    int received1 = -1;

    flow::receiver<int> receiver0{[&received0](int const &value) { received0 = value; }};
    flow::receiver<int> receiver1{[&received1](int const &value) { received1 = value; }};

    flow::observer flow = sender.begin_flow().receive({receiver0, receiver1}).end();

    sender.send_value(std::vector<int>{50, 60});

    XCTAssertEqual(received0, 50);
    XCTAssertEqual(received1, 60);
}

- (void)test_receive_tuple {
    flow::sender<std::tuple<int, std::string>> sender;

    int int_received = -1;
    std::string string_received = "";

    flow::receiver<int> int_receiver{[&int_received](int const &value) { int_received = value; }};
    flow::receiver<std::string> string_receiver{
        [&string_received](std::string const &value) { string_received = value; }};

    auto flow = sender.begin_flow().receive<0>(int_receiver).receive<1>(string_receiver).end();

    sender.send_value(std::make_tuple(int(10), std::string("20")));

    XCTAssertEqual(int_received, 10);
    XCTAssertEqual(string_received, "20");
}

- (void)test_receive_null {
    bool received = false;

    flow::sender<int> sender;
    flow::receiver<> receiver{[&received]() { received = true; }};

    auto flow = sender.begin_flow().receive_null(receiver).end();

    sender.send_value(4);

    XCTAssertTrue(received);
}

- (void)test_receiver {
    int received = -1;

    flow::sender<int> sender;

    flow::receiver<int> receiver{[&received](int const &value) { received = value; }};

    auto flow = sender.begin_flow().receive(receiver).end();

    sender.send_value(100);

    XCTAssertEqual(received, 100);
}

- (void)test_guard {
    float received = -1.0f;

    flow::sender<int> sender;

    auto flow = sender.begin_flow()
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

    auto sub_flow = sub_sender.begin_flow().map([](float const &value) { return std::to_string(int(value)); });

    auto flow = sender.begin_flow()
                    .map([](int const &value) { return std::to_string(value); })
                    .merge(sub_flow)
                    .perform([&received](std::string const &value) { received = value; })
                    .end();

    sender.send_value(10);

    XCTAssertEqual(received, "10");

    sub_sender.send_value(20.0f);

    XCTAssertEqual(received, "20");
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

    using opt_pair_t = opt_t<std::pair<int, std::string>>;

    opt_pair_t received;

    auto sub_flow = sub_sender.begin_flow();
    auto main_flow =
        main_sender.begin_flow().combine(sub_flow).perform([&received](auto const &value) { received = value; }).end();

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
    flow::sender<float> sub_sender2;

    auto sub_flow = sub_sender.begin_flow().to_tuple();
    auto main_flow = main_sender.begin_flow().to_tuple();
    auto sub_flow2 = sub_sender2.begin_flow().to_tuple();

    opt_t<std::tuple<int, std::string, float>> received;

    auto flow = main_flow.combine(sub_flow)
                    .combine(sub_flow2)
                    .perform([&received](std::tuple<int, std::string, float> const &value) { received = value; })
                    .end();

    main_sender.send_value(33);
    sub_sender.send_value("44");
    sub_sender2.send_value(55.0f);

    XCTAssertTrue(received);
    XCTAssertEqual(std::get<0>(*received), 33);
    XCTAssertEqual(std::get<1>(*received), "44");
    XCTAssertEqual(std::get<2>(*received), 55.0f);
}

- (void)test_normalize {
    flow::sender<int> sender;

    flow::node<std::string, int, int, false> toed_flow =
        sender.begin_flow().map([](int const &value) { return std::to_string(value); });

    flow::node<std::string, std::string, int, false> normalized_flow = toed_flow.normalize();

    std::string received = "";

    flow::typed_observer<int> observer =
        normalized_flow.perform([&received](std::string const &value) { received = value; }).end();

    sender.send_value(10);

    XCTAssertEqual(received, "10");
}

@end
