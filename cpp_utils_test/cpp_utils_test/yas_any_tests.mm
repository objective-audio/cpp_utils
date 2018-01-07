//
//  yas_any_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_any.h"

using namespace yas;

@interface yas_any_tests : XCTestCase

@end

@implementation yas_any_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_construct {
    any any{1.0};

    XCTAssertEqual(any.get<double>(), 1.0);
}

- (void)test_construct2 {
    any any = 2.0;

    XCTAssertEqual(any.get<double>(), 2.0);
}

- (void)test_assing_any {
    any any1{4.0};
    any any2{5};

    any2 = any1;

    XCTAssertEqual(any2.get<double>(), 4.0);
}

- (void)test_assign_value {
    any any = 1;

    any = 3.0;

    XCTAssertEqual(any.get<double>(), 3.0);
}

@end
