//
//  yas_cf_ref_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/yas_cf_ref.h>

using namespace yas;

@interface yas_cf_ref_tests : XCTestCase

@end

@implementation yas_cf_ref_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_retain_cf_object {
    auto arrayObj = CFArrayCreate(nullptr, nullptr, 0, nullptr);

    XCTAssertEqual(CFGetRetainCount(arrayObj), 1);

    if (auto cf_obj = cf_ref<CFArrayRef>(arrayObj)) {
        XCTAssertEqual(CFGetRetainCount(arrayObj), 2);
    }

    XCTAssertEqual(CFGetRetainCount(arrayObj), 1);

    CFRelease(arrayObj);
}

- (void)test_set_cf_object_on_strong_container {
    auto arrayObj = CFArrayCreate(nullptr, nullptr, 0, nullptr);

    auto cf_obj = cf_ref<CFArrayRef>{nullptr};

    XCTAssertFalse(cf_obj.retained_object());
    XCTAssertFalse(cf_obj.autoreleased_object());
    XCTAssertEqual(CFGetRetainCount(arrayObj), 1);

    cf_obj.set_object(arrayObj);

    XCTAssertEqual(CFGetRetainCount(arrayObj), 2);

    auto retainedObject = cf_obj.retained_object();

    XCTAssertTrue(retainedObject);
    XCTAssertEqual(CFGetRetainCount(arrayObj), 3);

    CFRelease(arrayObj);
    retainedObject = nullptr;

    XCTAssertEqual(CFGetRetainCount(arrayObj), 2);

    @autoreleasepool {
        auto autoreleasedObject = cf_obj.autoreleased_object();

        XCTAssertTrue(autoreleasedObject);
        XCTAssertEqual(CFGetRetainCount(arrayObj), 3);
    }

    XCTAssertEqual(CFGetRetainCount(arrayObj), 2);

    cf_obj.set_object(nullptr);

    XCTAssertFalse(cf_obj.retained_object());
    XCTAssertFalse(cf_obj.autoreleased_object());
    XCTAssertEqual(CFGetRetainCount(arrayObj), 1);

    CFRelease(arrayObj);
}

#pragma mark - copy

- (void)test_copy {
    auto arrayObj = CFArrayCreate(nullptr, nullptr, 0, nullptr);

    XCTAssertEqual(CFGetRetainCount(arrayObj), 1);
    {
        cf_ref<CFArrayRef> cf_obj1(arrayObj);

        XCTAssertEqual(CFGetRetainCount(arrayObj), 2);

        cf_ref<CFArrayRef> cf_obj2(arrayObj);

        XCTAssertEqual(CFGetRetainCount(arrayObj), 3);

        cf_obj1 = cf_obj2;

        XCTAssertEqual(CFGetRetainCount(arrayObj), 2);
    }

    XCTAssertEqual(CFGetRetainCount(arrayObj), 1);

    CFRelease(arrayObj);
}

- (void)test_copy_constructor_strong {
    auto arrayObj = CFArrayCreate(nullptr, nullptr, 0, nullptr);

    XCTAssertEqual(CFGetRetainCount(arrayObj), 1);

    {
        cf_ref<CFArrayRef> cf_obj1(arrayObj);

        XCTAssertEqual(CFGetRetainCount(arrayObj), 2);

        cf_ref<CFArrayRef> cf_obj2(cf_obj1);

        XCTAssertEqual(CFGetRetainCount(arrayObj), 2);
    }

    XCTAssertEqual(CFGetRetainCount(arrayObj), 1);

    CFRelease(arrayObj);
}

- (void)test_copy_different_cf_objects {
    auto arrayObj1 = CFArrayCreate(nullptr, nullptr, 0, nullptr);
    auto arrayObj2 = CFArrayCreate(nullptr, nullptr, 0, nullptr);

    {
        cf_ref<CFArrayRef> cf_obj1(arrayObj1);
        cf_ref<CFArrayRef> cf_obj2(arrayObj2);

        XCTAssertEqual(CFGetRetainCount(arrayObj1), 2);
        XCTAssertEqual(CFGetRetainCount(arrayObj2), 2);

        cf_obj1 = cf_obj2;

        XCTAssertEqual(CFGetRetainCount(arrayObj1), 1);
        XCTAssertEqual(CFGetRetainCount(arrayObj2), 2);
    }

    CFRelease(arrayObj1);
    CFRelease(arrayObj2);
}

#pragma mark - move

- (void)test_move {
    auto arrayObj = CFArrayCreate(nullptr, nullptr, 0, nullptr);

    {
        cf_ref<CFArrayRef> cf_obj1(arrayObj);
        cf_ref<CFArrayRef> cf_obj2;

        XCTAssertEqual(CFGetRetainCount(arrayObj), 2);

        cf_obj2 = std::move(cf_obj1);

        XCTAssertEqual(CFGetRetainCount(arrayObj), 2);
        XCTAssertFalse(cf_obj1);

        auto retainedObject = cf_obj2.retained_object();
        XCTAssertTrue(retainedObject);
        CFRelease(retainedObject);
    }

    CFRelease(arrayObj);
}

- (void)test_move_constructor {
    auto arrayObj = CFArrayCreate(nullptr, nullptr, 0, nullptr);

    {
        cf_ref<CFArrayRef> cf_obj1(arrayObj);

        XCTAssertEqual(CFGetRetainCount(arrayObj), 2);

        cf_ref<CFArrayRef> cf_obj2(std::move(cf_obj1));

        XCTAssertEqual(CFGetRetainCount(arrayObj), 2);
        XCTAssertFalse(cf_obj1);

        auto retainedObject = cf_obj2.retained_object();
        XCTAssertTrue(retainedObject);
        CFRelease(retainedObject);
    }

    CFRelease(arrayObj);
}

#pragma mark -

- (void)test_direct_set {
    auto arrayObj = CFArrayCreate(nullptr, nullptr, 0, nullptr);

    {
        cf_ref<CFArrayRef> cf_obj;

        XCTAssertEqual(CFGetRetainCount(arrayObj), 1);

        cf_obj = arrayObj;

        XCTAssertEqual(CFGetRetainCount(arrayObj), 2);

        auto retainedObject = cf_obj.retained_object();
        XCTAssertTrue(retainedObject);
        CFRelease(retainedObject);
    }

    CFRelease(arrayObj);
}

- (void)test_cf_ref_with_move_object {
    auto cf_obj = cf_ref_with_move_object(CFArrayCreate(nullptr, nullptr, 0, nullptr));

    XCTAssertTrue(cf_obj.object());
    XCTAssertEqual(CFGetRetainCount(cf_obj.object()), 1);
}

- (void)test_move_object {
    cf_ref<CFArrayRef> cf_obj;

    XCTAssertFalse(cf_obj);

    cf_obj.move_object(CFArrayCreate(nullptr, nullptr, 0, nullptr));

    XCTAssertTrue(cf_obj);
    XCTAssertEqual(CFGetRetainCount(cf_obj.object()), 1);
}

@end
