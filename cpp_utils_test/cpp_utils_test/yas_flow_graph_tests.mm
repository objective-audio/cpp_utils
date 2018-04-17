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
    enum class test_state { a, b, c };

    flow::graph<test_state, int> graph{test_state::a};
    
    XCTAssertEqual(graph.state(), test_state::a);

    auto flow_a = graph.begin_flow()
                      .perform([](int const &signal) { NSLog(@"call state a %@", @(signal)); })
                      .convert<test_state>([](int const &value) { return test_state::b; })
                      .end();

    auto flow_b = graph.begin_flow()
                      .perform([](int const &signal) { NSLog(@"call state b %@", @(signal)); })
                      .convert<test_state>([](int const &value) { return test_state::c; })
                      .end();

    graph.add_state(test_state::a, flow_a);
    graph.add_state(test_state::b, flow_b);
    
    
}

@end
