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

- (void)test_to {
    flow::notifier<int> sender;

    int received = -1;

    auto flow = sender.begin_flow()
                    .map([](int const &value) { return value + 1; })
                    .perform([&received](int const &value) { received = value; })
                    .end();

    sender.notify(10);

    XCTAssertEqual(received, 11);
}

- (void)test_to_type {
    flow::notifier<int> sender;

    std::string received = "";

    auto flow = sender.begin_flow()
                    .filter([](int const &) { return true; })
                    .map([](int const &value) { return value > 0; })
                    .filter([](bool const &) { return true; })
                    .map([](bool const &value) { return value ? "true" : "false"; })
                    .filter([](std::string const &) { return true; })
                    .perform([&received](std::string const &value) { received = value; })
                    .end();

    sender.notify(0);

    XCTAssertEqual(received, "false");

    sender.notify(1);

    XCTAssertEqual(received, "true");
}

- (void)test_to_value {
    flow::notifier<int> sender;

    std::string received = "";

    auto flow = sender.begin_flow()
                    .to_value(std::string("test_value"))
                    .perform([&received](std::string const &value) { received = value; })
                    .end();

    sender.notify(0);

    XCTAssertEqual(received, "test_value");
}

- (void)test_to_null {
    flow::notifier<int> sender;

    bool called = false;

    auto flow = sender.begin_flow().to_null().perform([&called](std::nullptr_t const &) { called = true; }).end();

    sender.notify(1);

    XCTAssertTrue(called);
}

- (void)test_to_tuple {
    flow::notifier<int> sender;

    opt_t<std::tuple<int>> called;

    auto flow =
        sender.begin_flow().to_tuple().perform([&called](std::tuple<int> const &value) { called = value; }).end();

    sender.notify(1);

    XCTAssertTrue(called);
    XCTAssertEqual(std::get<0>(*called), 1);
}

- (void)test_to_tuple_from_tuple {
    flow::notifier<std::tuple<int>> sender;

    opt_t<std::tuple<int>> called;

    auto flow = sender.begin_flow().to_tuple().perform([&called](auto const &value) { called = value; }).end();

    sender.notify(std::make_tuple(int(1)));

    XCTAssertTrue(called);
    XCTAssertEqual(std::get<0>(*called), 1);
}

- (void)test_to_tuple_from_pair {
    flow::notifier<std::pair<int, std::string>> sender;

    opt_t<std::tuple<int, std::string>> called;

    auto flow = sender.begin_flow().to_tuple().perform([&called](auto const &value) { called = value; }).end();

    sender.notify(std::make_pair(int(1), std::string("2")));

    XCTAssertTrue(called);
    XCTAssertEqual(std::get<0>(*called), 1);
    XCTAssertEqual(std::get<1>(*called), "2");
}

- (void)test_sync {
    flow::fetcher<int> sender{[] { return 100; }};

    int received = -1;

    auto flow = sender.begin_flow().perform([&received](int const &value) { received = value; }).end();
    flow.sync();

    XCTAssertEqual(received, 100);
}

- (void)test_sync_by_observer {
    flow::fetcher<int> sender{[] { return 100; }};

    int received = -1;

    flow::observer flow = sender.begin_flow().perform([&received](int const &value) { received = value; }).end();
    flow.sync();

    XCTAssertEqual(received, 100);
}

- (void)test_sync_many_sender {
    flow::fetcher<int> sender{[] { return 100; }};

    int received1 = -1;
    int received2 = -1;

    auto flow1 = sender.begin_flow().perform([&received1](int const &value) { received1 = value; }).end();
    auto flow2 = sender.begin_flow().perform([&received2](int const &value) { received2 = value; }).end();

    flow1.sync();

    XCTAssertEqual(received1, 100);
    XCTAssertEqual(received2, -1);
}

- (void)test_sync_end {
    flow::fetcher<int> sender{[] { return 100; }};

    int received = -1;

    auto flow = sender.begin_flow().perform([&received](int const &value) { received = value; }).sync();

    XCTAssertEqual(received, 100);
}

- (void)test_sync_with_combined_sub_sender {
    flow::fetcher<int> sender{[]() { return 123; }};

    flow::fetcher<int> sub_sender{[]() { return 456; }};

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
    flow::fetcher<int> sender{[]() { return 78; }};

    flow::fetcher<int> sub_sender{[]() { return 90; }};

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

    flow::notifier<int> sender;
    flow::receiver<std::string> receiver{[&received](std::string const &value) { received = value; }};

    auto node = sender.begin_flow().map([](int const &value) { return std::to_string(value); }).receive(receiver).end();

    sender.notify(3);

    XCTAssertEqual(received, "3");
}

- (void)test_receive_array {
    flow::notifier<std::array<int, 2>> sender;
    int received0 = -1;
    int received1 = -1;

    flow::receiver<int> receiver0{[&received0](int const &value) { received0 = value; }};
    flow::receiver<int> receiver1{[&received1](int const &value) { received1 = value; }};
    std::array<flow::receiver<int>, 2> receivers{receiver0, receiver1};

    flow::observer flow = sender.begin_flow().receive(receivers).end();

    sender.notify(std::array<int, 2>{10, 20});

    XCTAssertEqual(received0, 10);
    XCTAssertEqual(received1, 20);
}

- (void)test_receive_array_individual {
    flow::notifier<std::array<int, 2>> sender;
    int received0 = -1;
    int received1 = -1;

    flow::receiver<int> receiver0{[&received0](int const &value) { received0 = value; }};
    flow::receiver<int> receiver1{[&received1](int const &value) { received1 = value; }};

    flow::observer flow = sender.begin_flow().receive<0>(receiver0).receive<1>(receiver1).end();

    sender.notify(std::array<int, 2>{10, 20});

    XCTAssertEqual(received0, 10);
    XCTAssertEqual(received1, 20);
}

- (void)test_receiver_vector {
    flow::notifier<std::vector<int>> sender;
    int received0 = -1;
    int received1 = -1;

    flow::receiver<int> receiver0{[&received0](int const &value) { received0 = value; }};
    flow::receiver<int> receiver1{[&received1](int const &value) { received1 = value; }};
    std::vector<flow::receiver<int>> receivers{receiver0, receiver1};

    flow::observer flow = sender.begin_flow().receive(receivers).end();

    sender.notify(std::vector<int>{30, 40});

    XCTAssertEqual(received0, 30);
    XCTAssertEqual(received1, 40);
}

- (void)test_receiver_initializer_list {
    flow::notifier<std::vector<int>> sender;
    int received0 = -1;
    int received1 = -1;

    flow::receiver<int> receiver0{[&received0](int const &value) { received0 = value; }};
    flow::receiver<int> receiver1{[&received1](int const &value) { received1 = value; }};

    flow::observer flow = sender.begin_flow().receive({receiver0, receiver1}).end();

    sender.notify(std::vector<int>{50, 60});

    XCTAssertEqual(received0, 50);
    XCTAssertEqual(received1, 60);
}

- (void)test_receive_tuple {
    flow::notifier<std::tuple<int, std::string>> sender;

    int int_received = -1;
    std::string string_received = "";

    flow::receiver<int> int_receiver{[&int_received](int const &value) { int_received = value; }};
    flow::receiver<std::string> string_receiver{
        [&string_received](std::string const &value) { string_received = value; }};

    auto flow = sender.begin_flow().receive<0>(int_receiver).receive<1>(string_receiver).end();

    sender.notify(std::make_tuple(int(10), std::string("20")));

    XCTAssertEqual(int_received, 10);
    XCTAssertEqual(string_received, "20");
}

- (void)test_receive_null {
    bool received = false;

    flow::notifier<int> sender;
    flow::receiver<> receiver{[&received]() { received = true; }};

    auto flow = sender.begin_flow().receive_null(receiver).end();

    sender.notify(4);

    XCTAssertTrue(received);
}

- (void)test_receiver {
    int received = -1;

    flow::notifier<int> sender;

    flow::receiver<int> receiver{[&received](int const &value) { received = value; }};

    auto flow = sender.begin_flow().receive(receiver).end();

    sender.notify(100);

    XCTAssertEqual(received, 100);
}

- (void)test_guard {
    float received = -1.0f;

    flow::notifier<int> sender;

    auto flow = sender.begin_flow()
                    .map([](int const &value) { return value; })
                    .filter([](float const &value) { return value > 2.5f; })
                    .perform([&received](float const &value) { received = value; })
                    .end();

    sender.notify(2);

    XCTAssertEqual(received, -1.0f);

    sender.notify(3);

    XCTAssertEqual(received, 3.0f);
}

- (void)test_merge {
    std::string received;

    flow::notifier<int> sender;
    flow::notifier<float> sub_sender;

    auto sub_flow = sub_sender.begin_flow().map([](float const &value) { return std::to_string(int(value)); });

    auto flow = sender.begin_flow()
                    .map([](int const &value) { return std::to_string(value); })
                    .merge(sub_flow)
                    .perform([&received](std::string const &value) { received = value; })
                    .end();

    sender.notify(10);

    XCTAssertEqual(received, "10");

    sub_sender.notify(20.0f);

    XCTAssertEqual(received, "20");
}

- (void)test_pair {
    flow::notifier<int> main_sender;
    flow::notifier<std::string> sub_sender;

    using opt_pair_t = std::pair<opt_t<int>, opt_t<std::string>>;

    opt_pair_t received;

    auto sub_flow = sub_sender.begin_flow();
    auto main_flow =
        main_sender.begin_flow().pair(sub_flow).perform([&received](auto const &value) { received = value; }).end();

    main_sender.notify(1);

    XCTAssertEqual(*received.first, 1);
    XCTAssertFalse(!!received.second);

    sub_sender.notify("test_text");

    XCTAssertFalse(!!received.first);
    XCTAssertEqual(*received.second, "test_text");
}

- (void)test_combine {
    flow::notifier<int> main_sender;
    flow::notifier<std::string> sub_sender;

    using opt_pair_t = opt_t<std::pair<int, std::string>>;

    opt_pair_t received;

    auto sub_flow = sub_sender.begin_flow();
    auto main_flow =
        main_sender.begin_flow().combine(sub_flow).perform([&received](auto const &value) { received = value; }).end();

    main_sender.notify(1);

    XCTAssertFalse(received);

    sub_sender.notify("test_text");

    XCTAssertTrue(received);
    XCTAssertEqual(received->first, 1);
    XCTAssertEqual(received->second, "test_text");
}

- (void)test_combine_tuples {
    flow::notifier<int> main_sender;
    flow::notifier<std::string> sub_sender;
    flow::notifier<float> sub_sender2;

    auto sub_flow = sub_sender.begin_flow().to_tuple();
    auto main_flow = main_sender.begin_flow().to_tuple();
    auto sub_flow2 = sub_sender2.begin_flow().to_tuple();

    opt_t<std::tuple<int, std::string, float>> received;

    auto flow = main_flow.combine(sub_flow)
                    .combine(sub_flow2)
                    .perform([&received](std::tuple<int, std::string, float> const &value) { received = value; })
                    .end();

    main_sender.notify(33);
    sub_sender.notify("44");
    sub_sender2.notify(55.0f);

    XCTAssertTrue(received);
    XCTAssertEqual(std::get<0>(*received), 33);
    XCTAssertEqual(std::get<1>(*received), "44");
    XCTAssertEqual(std::get<2>(*received), 55.0f);
}

- (void)test_normalize {
    flow::notifier<int> sender;

    flow::node<std::string, int, int, false> toed_flow =
        sender.begin_flow().map([](int const &value) { return std::to_string(value); });

    flow::node<std::string, std::string, int, false> normalized_flow = toed_flow.normalize();

    std::string received = "";

    flow::typed_observer<int> observer =
        normalized_flow.perform([&received](std::string const &value) { received = value; }).end();

    sender.notify(10);

    XCTAssertEqual(received, "10");
}

@end
