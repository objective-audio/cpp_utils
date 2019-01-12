//
//  yas_to_string_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/yas_boolean.h>
#import <cpp_utils/yas_to_string.h>

using namespace yas;

@interface yas_to_string_tests : XCTestCase

@end

@implementation yas_to_string_tests

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
