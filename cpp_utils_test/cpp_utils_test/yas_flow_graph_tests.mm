//
//  yas_flow_graph_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_flow_graph.h"

using namespace yas;

@interface yas_flow_graph_tests : XCTestCase

@end

@implementation yas_flow_graph_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_graph {
    enum class waiting { closed, opened };
    enum class running { closing, opening };
    enum class event { open, close };

    flow::graph<waiting, running, event> graph{waiting::closed};

    graph.add_waiting(waiting::closed, [](auto const &signal) {
        if (signal.event == event::open) {
            return signal.run(running::opening, signal.event);
        } else {
            return signal.stay();
        }
    });

    graph.add_waiting(waiting::opened, [](auto const &signal) {
        if (signal.event == event::close) {
            return signal.run(running::closing, signal.event);
        } else {
            return signal.stay();
        }
    });

    std::vector<running> called;

    graph.add_running(running::closing, [&called](auto const &signal) {
        called.push_back(running::closing);
        return signal.wait(waiting::closed);
    });

    graph.add_running(running::opening, [&called](auto const &signal) {
        called.push_back(running::opening);
        return signal.wait(waiting::opened);
    });

    XCTAssertEqual(graph.current().kind(), flow::state_kind::waiting);
    XCTAssertEqual(graph.current().waiting(), waiting::closed);

    graph.run(event::open);

    XCTAssertEqual(called.size(), 1);
    XCTAssertEqual(called[0], running::opening);
    XCTAssertEqual(graph.current().kind(), flow::state_kind::waiting);
    XCTAssertEqual(graph.current().waiting(), waiting::opened);

    graph.run(event::close);

    XCTAssertEqual(called.size(), 2);
    XCTAssertEqual(called[1], running::closing);
    XCTAssertEqual(graph.current().kind(), flow::state_kind::waiting);
    XCTAssertEqual(graph.current().waiting(), waiting::closed);

    graph.run(event::close);

    XCTAssertEqual(called.size(), 2);
    XCTAssertEqual(graph.current().kind(), flow::state_kind::waiting);
    XCTAssertEqual(graph.current().waiting(), waiting::closed);
}

- (void)test_waiting_to_waiting {
    enum class waiting { closed, opened };
    enum class running {};
    enum class event { open, close };

    flow::graph<waiting, running, event> graph{waiting::closed};

    graph.add_waiting(waiting::closed, [](auto const &signal) {
        if (signal.event == event::open) {
            return signal.wait(waiting::opened);
        } else {
            return signal.stay();
        }
    });

    graph.add_waiting(waiting::opened, [](auto const &signal) {
        if (signal.event == event::close) {
            return signal.wait(waiting::closed);
        } else {
            return signal.stay();
        }
    });

    XCTAssertEqual(graph.current().waiting(), waiting::closed);

    graph.run(event::open);

    XCTAssertEqual(graph.current().waiting(), waiting::opened);

    graph.run(event::close);

    XCTAssertEqual(graph.current().waiting(), waiting::closed);
}

- (void)test_running_to_running {
    enum class waiting { root };
    enum class running { first, second };
    enum class event { bang };

    flow::graph<waiting, running, event> graph{waiting::root};

    graph.add_waiting(waiting::root, [](auto const &signal) {
        if (signal.event == event::bang) {
            return signal.run(running::first, signal.event);
        } else {
            return signal.stay();
        }
    });

    std::vector<running> called;

    graph.add_running(running::first, [&called](auto const &signal) {
        called.push_back(running::first);
        return signal.run(running::second, signal.event);
    });

    graph.add_running(running::second, [&called](auto const &signal) {
        called.push_back(running::second);
        return signal.wait(waiting::root);
    });

    graph.run(event::bang);

    XCTAssertEqual(graph.current().waiting(), waiting::root);
    XCTAssertEqual(called.size(), 2);
    XCTAssertEqual(called[0], running::first);
    XCTAssertEqual(called[1], running::second);
}

@end
