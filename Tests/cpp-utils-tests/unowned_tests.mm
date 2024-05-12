//
//  unowned.mm
//

#import <XCTest/XCTest.h>
#include <cpp-utils/unowned.h>

using namespace yas;

@interface DummyObject : NSObject

- (NSInteger)value;

@end

@implementation DummyObject

- (NSInteger)value {
    return 123;
}

@end

@interface unowned_tests : XCTestCase

@end

@implementation unowned_tests

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
