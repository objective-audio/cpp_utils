//
//  to_string_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp-utils/boolean.h>
#import <cpp-utils/to_string.h>

using namespace yas;

@interface to_string_tests : XCTestCase

@end

@implementation to_string_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_to_string_with_integer {
    XCTAssertEqual(to_string(int32_t(1)), "1");
}

- (void)test_to_string_with_boolean {
    XCTAssertEqual(to_string(boolean(true)), "true");
    XCTAssertEqual(to_string(boolean(false)), "false");
}

@end
