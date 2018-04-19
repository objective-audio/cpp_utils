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

- (void)test_graph2 {
    enum class test_state { a, b, c };

    flow::graph<test_state, int> graph{test_state::a};

    graph.add_state(test_state::a, [](int const &signal) { return flow::make_break(test_state::b); });
    graph.add_state(test_state::b, [](int const &signal) { return flow::make_continue(test_state::c); });
    graph.add_state(test_state::c, [](int const &signal) { return flow::make_break(test_state::a); });

    XCTAssertEqual(graph.state(), test_state::a);

    graph.send_signal(0);

    XCTAssertEqual(graph.state(), test_state::b);

    graph.send_signal(0);

    XCTAssertEqual(graph.state(), test_state::a);
}

@end
