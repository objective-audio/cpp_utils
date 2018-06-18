//
//  yas_flow_property_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_flow.h"

using namespace yas;

@interface yas_flow_property_tests : XCTestCase

@end

@implementation yas_flow_property_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_getter_setter {
    flow::property<int> property{1};

    XCTAssertEqual(property.value(), 1);

    property.set_value(2);

    XCTAssertEqual(property.value(), 2);
}

- (void)test_begin_flow {
    flow::property<int> property{10};

    int received = -1;

    auto flow = property.begin_flow().perform([&received](int const &value) { received = value; }).sync();

    XCTAssertEqual(received, 10);

    property.set_value(20);

    XCTAssertEqual(received, 20);
}

- (void)test_receive {
    flow::property<int> property{100};
    flow::notifier<int> notifier;

    auto flow = notifier.begin_flow().receive(property.receiver()).end();

    XCTAssertEqual(property.value(), 100);

    notifier.notify(200);

    XCTAssertEqual(property.value(), 200);
}

- (void)test_recursive_flow {
    flow::property<int> property1{123};
    flow::property<int> property2{456};

    auto flow1 = property1.begin_flow().receive(property2.receiver()).sync();

    XCTAssertEqual(property1.value(), 123);
    XCTAssertEqual(property2.value(), 123);

    auto flow2 = property2.begin_flow().receive(property1.receiver()).sync();

    XCTAssertEqual(property1.value(), 123);
    XCTAssertEqual(property2.value(), 123);

    property1.set_value(789);

    XCTAssertEqual(property1.value(), 789);
    XCTAssertEqual(property2.value(), 789);

    property2.set_value(0);

    XCTAssertEqual(property1.value(), 0);
    XCTAssertEqual(property2.value(), 0);
}

- (void)test_is_equal {
    flow::property<int> property1a{1};
    flow::property<int> property1b{1};
    flow::property<int> property2{2};

    XCTAssertTrue(property1a == property1a);
    XCTAssertTrue(property1a == property1b);
    XCTAssertFalse(property1a == property2);

    XCTAssertFalse(property1a != property1a);
    XCTAssertFalse(property1a != property1b);
    XCTAssertTrue(property1a != property2);
}

@end
