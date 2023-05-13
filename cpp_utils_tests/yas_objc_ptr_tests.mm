//
//  yas_objc_ptr_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/yas_objc_ptr.h>

using namespace yas;

static int _objc_object_count = 0;

@interface YASObjCTestObject : NSObject

@end

@implementation YASObjCTestObject

- (instancetype)init {
    self = [super init];
    if (self) {
        _objc_object_count++;
    }
    return self;
}

- (void)dealloc {
    _objc_object_count--;
    [super dealloc];
}

@end

@interface yas_objc_ptr_tests : XCTestCase

@end

@implementation yas_objc_ptr_tests

- (void)setUp {
    [super setUp];

    _objc_object_count = 0;
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_retain_objc_object {
    YASObjCTestObject *objcObject = [[YASObjCTestObject alloc] init];

    XCTAssertEqual(_objc_object_count, 1);
    XCTAssertEqual([objcObject retainCount], 1);

    if (auto objc_obj = objc_ptr<>(objcObject)) {
        XCTAssertEqual(_objc_object_count, 1);
        XCTAssertEqual([objcObject retainCount], 2);
    }

    [objcObject release];
    objcObject = nil;

    XCTAssertEqual(_objc_object_count, 0);
}

- (void)test_set_objc_object_on_strong_container {
    YASObjCTestObject *objcObject = [[YASObjCTestObject alloc] init];

    auto objc_obj = objc_ptr<>{nil};
    XCTAssertNil(objc_obj.retained_object());
    XCTAssertNil(objc_obj.autoreleased_object());
    XCTAssertEqual(_objc_object_count, 1);
    XCTAssertEqual([objcObject retainCount], 1);

    objc_obj.set_object(objcObject);

    XCTAssertEqual([objcObject retainCount], 2);

    id retained_object = objc_obj.retained_object();

    XCTAssertNotNil(retained_object);
    XCTAssertEqual([objcObject retainCount], 3);

    [objcObject release];
    retained_object = nil;

    XCTAssertEqual([objcObject retainCount], 2);

    @autoreleasepool {
        id autoreleased_object = objc_obj.autoreleased_object();

        XCTAssertNotNil(autoreleased_object);
        XCTAssertEqual([objcObject retainCount], 3);
    }

    XCTAssertEqual([objcObject retainCount], 2);

    objc_obj.set_object(nil);

    XCTAssertNil(objc_obj.retained_object());
    XCTAssertNil(objc_obj.autoreleased_object());
    XCTAssertEqual(_objc_object_count, 1);
    XCTAssertEqual([objcObject retainCount], 1);

    [objcObject release];
    objcObject = nil;

    XCTAssertEqual(_objc_object_count, 0);
}

- (void)test_objc_ptr_constructor_with_func {
    {
        yas::objc_ptr<YASObjCTestObject *> container(
            []() { return yas_autorelease([[YASObjCTestObject alloc] init]); });

        XCTAssertNotNil(container.object());
        XCTAssertEqual([container.object() retainCount], 1);
    }

    XCTAssertEqual(_objc_object_count, 0);
}

#pragma mark - copy

- (void)test_copy {
    YASObjCTestObject *objcObject = [[YASObjCTestObject alloc] init];

    XCTAssertEqual([objcObject retainCount], 1);

    {
        objc_ptr<> objc_obj1(objcObject);

        XCTAssertEqual([objcObject retainCount], 2);

        objc_ptr<> objc_obj2(objcObject);

        XCTAssertEqual([objcObject retainCount], 3);

        objc_obj1 = objc_obj2;

        XCTAssertEqual([objcObject retainCount], 2);
    }

    XCTAssertEqual([objcObject retainCount], 1);

    [objcObject release];
    objcObject = nil;

    XCTAssertEqual(_objc_object_count, 0);
}

- (void)test_copy_constructor_strong {
    YASObjCTestObject *objcObject = [[YASObjCTestObject alloc] init];

    XCTAssertEqual([objcObject retainCount], 1);

    {
        objc_ptr<> objc_obj1(objcObject);

        XCTAssertEqual([objcObject retainCount], 2);

        objc_ptr<> objc_obj2(objc_obj1);

        XCTAssertEqual([objcObject retainCount], 2);
    }

    XCTAssertEqual([objcObject retainCount], 1);

    [objcObject release];
    objcObject = nil;

    XCTAssertEqual(_objc_object_count, 0);
}

- (void)test_copy_different_objc_objects {
    YASObjCTestObject *objcObject1 = [[YASObjCTestObject alloc] init];
    YASObjCTestObject *objcObject2 = [[YASObjCTestObject alloc] init];

    {
        objc_ptr<> objc_obj1(objcObject1);
        objc_ptr<> objc_obj2(objcObject2);

        XCTAssertEqual([objcObject1 retainCount], 2);
        XCTAssertEqual([objcObject2 retainCount], 2);

        objc_obj1 = objc_obj2;

        XCTAssertEqual([objcObject1 retainCount], 1);
        XCTAssertEqual([objcObject2 retainCount], 2);
    }

    [objcObject1 release];
    objcObject1 = nil;
    [objcObject2 release];
    objcObject2 = nil;

    XCTAssertEqual(_objc_object_count, 0);
}

#pragma mark - move

- (void)test_move {
    YASObjCTestObject *objcObject = [[YASObjCTestObject alloc] init];

    {
        objc_ptr<> objc_obj1(objcObject);
        objc_ptr<> objc_obj2;

        XCTAssertEqual([objcObject retainCount], 2);

        objc_obj2 = std::move(objc_obj1);

        XCTAssertEqual([objcObject retainCount], 2);
        XCTAssertFalse(objc_obj1);

        id retainedObject = objc_obj2.retained_object();
        XCTAssertNotNil(retainedObject);
        [retainedObject release];
    }

    [objcObject release];
    objcObject = nil;

    XCTAssertEqual(_objc_object_count, 0);
}

- (void)test_move_constructor {
    YASObjCTestObject *objcObject = [[YASObjCTestObject alloc] init];

    {
        objc_ptr<> objc_obj1(objcObject);

        XCTAssertEqual([objcObject retainCount], 2);

        objc_ptr<> objc_obj2(std::move(objc_obj1));

        XCTAssertEqual([objcObject retainCount], 2);
        XCTAssertFalse(objc_obj1);

        id retainedObject = objc_obj2.retained_object();
        XCTAssertNotNil(retainedObject);
        [retainedObject release];
    }

    [objcObject release];
    objcObject = nil;

    XCTAssertEqual(_objc_object_count, 0);
}

#pragma mark -

- (void)test_direct_set {
    YASObjCTestObject *objcObject = [[YASObjCTestObject alloc] init];

    {
        objc_ptr<> objc_obj;

        XCTAssertEqual([objcObject retainCount], 1);

        objc_obj = objcObject;

        XCTAssertEqual([objcObject retainCount], 2);

        id retainedObject = objc_obj.retained_object();
        XCTAssertNotNil(retainedObject);
        [retainedObject release];
    }

    [objcObject release];
    objcObject = nil;

    XCTAssertEqual(_objc_object_count, 0);
}

- (void)test_typed {
    YASObjCTestObject *objcObject = [[YASObjCTestObject alloc] init];

    {
        objc_ptr<YASObjCTestObject *> objc_obj{objcObject};

        XCTAssertEqualObjects(objc_obj.object(), objcObject);
        XCTAssertEqual([objcObject retainCount], 2);
    }

    [objcObject release];
    objcObject = nil;

    XCTAssertEqual(_objc_object_count, 0);
}

- (void)test_make_objc_ptr {
    {
        auto objc_obj = objc_ptr_with_move_object([[YASObjCTestObject alloc] init]);

        XCTAssertNotNil(objc_obj.object());
        XCTAssertEqual([objc_obj.object() retainCount], 1);
    }

    XCTAssertEqual(_objc_object_count, 0);
}

- (void)test_move_object {
    {
        objc_ptr<YASObjCTestObject *> objc_obj;

        XCTAssertFalse(objc_obj);

        objc_obj.move_object([[YASObjCTestObject alloc] init]);

        XCTAssertTrue(objc_obj);
        XCTAssertEqual([objc_obj.object() retainCount], 1);
    }

    XCTAssertEqual(_objc_object_count, 0);
}

- (void)test_dispatch_retaining {
    dispatch_queue_t queue = dispatch_queue_create("test_serial_queue", DISPATCH_QUEUE_SERIAL);

    XCTAssertEqual([queue retainCount], 1);

    yas_dispatch_queue_retain(queue);

    XCTAssertEqual([queue retainCount], 2);

    yas_dispatch_queue_release(queue);

    XCTAssertEqual([queue retainCount], 1);
}

- (void)test_weak {
    {
        std::weak_ptr<objc_ptr<YASObjCTestObject *>> weak_objc_obj;

        {
            auto testObj = [[YASObjCTestObject alloc] init];
            auto objc_obj = std::make_shared<objc_ptr<YASObjCTestObject *>>(testObj);
            yas_release(testObj);

            XCTAssertTrue(objc_obj);
            XCTAssertEqual([objc_obj->object() retainCount], 1);

            XCTAssertEqual(weak_objc_obj.use_count(), 0);

            weak_objc_obj = objc_obj;

            XCTAssertEqual(weak_objc_obj.use_count(), 1);
            XCTAssertEqual([objc_obj->object() retainCount], 1);
        }

        XCTAssertEqual(weak_objc_obj.use_count(), 0);
    }

    XCTAssertEqual(_objc_object_count, 0);
}

- (void)test_asterisk {
    auto objc_obj = objc_ptr_with_move_object([[YASObjCTestObject alloc] init]);

    XCTAssertEqualObjects(*objc_obj, objc_obj.object());

    objc_obj.set_object(nil);

    XCTAssertNil(*objc_obj);
}

@end
