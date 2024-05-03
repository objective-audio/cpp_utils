//
//  yas_objc_weak_tests.m
//

#import <XCTest/XCTest.h>
#import <objc-utils/yas_objc_macros.h>
#import <objc-utils/yas_objc_unowned.h>

static NSInteger _objectCount = 0;

@interface YASWeakTestObject : NSObject
@end

@implementation YASWeakTestObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _objectCount++;
    }
    return self;
}

- (void)dealloc {
    _objectCount--;
    yas_super_dealloc();
}

@end

@interface yas_objc_weak_tests : XCTestCase

@end

@implementation yas_objc_weak_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_create {
    YASUnownedObject<id> *weakObject = [[YASUnownedObject<id> alloc] init];

    XCTAssertNil([weakObject object]);
    XCTAssertNil([weakObject autoreleasedObject]);

    id retainedObject = [weakObject retainedObject];
    XCTAssertNil(retainedObject);
    yas_retain_or_ignore(retainedObject);
}

// #if !__has_feature(objc_arc)

- (void)test_object {
    _objectCount = 0;

    YASUnownedObject<YASWeakTestObject *> *weakObject = [[YASUnownedObject<YASWeakTestObject *> alloc] init];

    YASWeakTestObject *object = [[YASWeakTestObject alloc] init];

    XCTAssertEqual(_objectCount, 1);

    [weakObject setObject:object];

    XCTAssertEqualObjects([weakObject object], object);

    id retainedObject = [weakObject retainedObject];
    XCTAssertEqualObjects(retainedObject, object);
    yas_release(retainedObject);

    @autoreleasepool {
        XCTAssertEqualObjects([weakObject autoreleasedObject], object);
    }

    XCTAssertEqual(_objectCount, 1);

    yas_release(object);

    XCTAssertEqual(_objectCount, 0);
}

// #endif

- (void)test_init_with_object {
    NSString *stringObject = @"test_string";
    YASUnownedObject<NSString *> *unowned = [[YASUnownedObject<NSString *> alloc] initWithObject:stringObject];

    NSString *weakStringObject = unowned.object;
    XCTAssertEqualObjects(stringObject, weakStringObject);
}

@end
