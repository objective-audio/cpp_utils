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

    graph.add(test_state::a, [](int const &signal) { return flow::wait(test_state::b); });
    graph.add(test_state::b, [](int const &signal) { return flow::run(test_state::c); });
    graph.add(test_state::c, [](int const &signal) { return flow::wait(test_state::a); });

    XCTAssertEqual(graph.state(), test_state::a);

    graph.run(0);

    XCTAssertEqual(graph.state(), test_state::b);

    graph.run(0);

    XCTAssertEqual(graph.state(), test_state::a);
}

@end
