//
//  yas_to_enum_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_to_bool.h"

@interface yas_to_enum_tests : XCTestCase

@end

@implementation yas_to_enum_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_enum_to_bool {
    enum class test_enum {
        zero,
        one,
        two,
    };

    XCTAssertFalse(to_bool(test_enum::zero));
    XCTAssertTrue(to_bool(test_enum::one));
    XCTAssertTrue(to_bool(test_enum::two));
}

@end
