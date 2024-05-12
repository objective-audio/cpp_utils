//
//  to_enum_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp-utils/to_bool.h>

@interface to_enum_tests : XCTestCase

@end

@implementation to_enum_tests

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
