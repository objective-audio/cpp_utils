//
//  yas_unowned.mm
//

#import <XCTest/XCTest.h>
#include <cpp-utils/yas_unowned.h>

using namespace yas;

@interface DummyObject : NSObject

- (NSInteger)value;

@end

@implementation DummyObject

- (NSInteger)value {
    return 123;
}

@end

@interface yas_unowned_tests : XCTestCase

@end

@implementation yas_unowned_tests

- (void)setUp {
}

- (void)tearDown {
}

- (void)test_make_unowned {
    DummyObject *object = [[DummyObject alloc] init];

    auto const unowned = make_unowned(object);

    XCTAssertEqual(unowned.object.value, 123);
}

@end
