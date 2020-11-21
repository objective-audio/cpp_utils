//
//  yas_objc_cast_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/cpp_utils.h>

using namespace yas;

@interface YASCastTestA : NSObject
@end
@implementation YASCastTestA
@end

@interface YASCastTestA2 : YASCastTestA
@end
@implementation YASCastTestA2
@end

@interface YASCastTestB : NSObject
@end
@implementation YASCastTestB
@end

@interface yas_objc_cast_tests : XCTestCase

@end

@implementation yas_objc_cast_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_down_cast_success {
    id const obj = [[YASCastTestA2 alloc] init];

    auto castedObj = objc_cast<YASCastTestA2>(obj);
    XCTAssertNotNil(castedObj);
}

- (void)test_down_cast_failed {
    id const obj = [[YASCastTestA alloc] init];

    auto castedObj = objc_cast<YASCastTestA2>(obj);
    XCTAssertNil(castedObj);
}

- (void)test_up_cast {
    id const obj = [[YASCastTestA2 alloc] init];

    auto castedObj = objc_cast<YASCastTestA>(obj);
    XCTAssertNotNil(castedObj);
}

- (void)test_cast_failed {
    id const obj = [[YASCastTestB alloc] init];

    auto castedObj = objc_cast<YASCastTestA>(obj);
    XCTAssertNil(castedObj);
}

@end
