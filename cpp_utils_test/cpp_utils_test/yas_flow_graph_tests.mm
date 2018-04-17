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

    auto flow_a = graph.begin_flow().perform([](test_state const &state) { NSLog(@"call state a"); }).end();
    auto flow_b = graph.begin_flow().perform([](test_state const &state) { NSLog(@"call state b"); }).end();

    graph.add_state(test_state::a, flow_a);
    graph.add_state(test_state::b, flow_b);
}

@end
