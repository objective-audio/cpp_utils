//
//  objc_cast_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp-utils/objc_cast.h>

using namespace yas;

@interface CastTestA : NSObject
@end
@implementation CastTestA
@end

@interface CastTestA2 : CastTestA
@end
@implementation CastTestA2
@end

@interface CastTestB : NSObject
@end
@implementation CastTestB
@end

@interface objc_cast_tests : XCTestCase

@end

@implementation objc_cast_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_down_cast_success {
    id const obj = [[CastTestA2 alloc] init];

    auto castedObj = objc_cast<CastTestA2>(obj);
    XCTAssertNotNil(castedObj);
}

- (void)test_down_cast_failed {
    id const obj = [[CastTestA alloc] init];

    auto castedObj = objc_cast<CastTestA2>(obj);
    XCTAssertNil(castedObj);
}

- (void)test_up_cast {
    id const obj = [[CastTestA2 alloc] init];

    auto castedObj = objc_cast<CastTestA>(obj);
    XCTAssertNotNil(castedObj);
}

- (void)test_cast_failed {
    id const obj = [[CastTestB alloc] init];

    auto castedObj = objc_cast<CastTestA>(obj);
    XCTAssertNil(castedObj);
}

@end
