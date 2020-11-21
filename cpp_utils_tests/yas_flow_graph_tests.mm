//
//  yas_flow_graph_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/cpp_utils.h>
#import <vector>

using namespace yas;

@interface yas_flow_graph_tests : XCTestCase

@end

@implementation yas_flow_graph_tests

- (void)setUp {
}

- (void)tearDown {
}

- (void)test_ {
    enum waiting_state {
        closed,
        opened,
    };

    enum running_state {
        closing,
        opening,
    };

    enum test_event {
        close,
        open,
    };

    auto graph = flow::graph<waiting_state, running_state, test_event>::make_shared(waiting_state::closed);

    graph->add_waiting(waiting_state::closed, [](auto const &signal) {
        switch (signal.event) {
            case test_event::open:
                return signal.run(running_state::opening, signal.event);
            case test_event::close:
                return signal.stay();
        }
    });

    graph->add_waiting(waiting_state::opened, [](auto const &signal) {
        switch (signal.event) {
            case test_event::open:
                return signal.stay();
            case test_event::close:
                return signal.run(running_state::closing, signal.event);
        }
    });

    std::vector<running_state> called_states;

    graph->add_running(running_state::opening, [&called_states](auto const &signal) {
        called_states.push_back(running_state::opening);
        return signal.wait(waiting_state::opened);
    });

    graph->add_running(running_state::closing, [&called_states](auto const &signal) {
        called_states.push_back(running_state::closing);
        return signal.wait(waiting_state::closed);
    });

    XCTAssertEqual(graph->current().kind(), flow::state_kind::waiting);
    XCTAssertEqual(graph->current().waiting(), waiting_state::closed);

    graph->run(test_event::close);

    XCTAssertEqual(graph->current().kind(), flow::state_kind::waiting);
    XCTAssertEqual(graph->current().waiting(), waiting_state::closed);

    graph->run(test_event::open);

    XCTAssertEqual(graph->current().kind(), flow::state_kind::waiting);
    XCTAssertEqual(graph->current().waiting(), waiting_state::opened);

    graph->run(test_event::close);

    XCTAssertEqual(graph->current().kind(), flow::state_kind::waiting);
    XCTAssertEqual(graph->current().waiting(), waiting_state::closed);
}

@end
