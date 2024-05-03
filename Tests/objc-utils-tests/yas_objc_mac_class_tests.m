//
//  yas_objc_mac_class_tests.m
//

#import <TargetConditionals.h>

#if !TARGET_OS_IPHONE && TARGET_OS_MAC

#import <XCTest/XCTest.h>
@import objc_utils;

@interface yas_objc_mac_class_tests : XCTestCase

@end

@implementation yas_objc_mac_class_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_class {
    XCTAssertEqualObjects([yas_objc_view class], [NSView class]);
    XCTAssertEqualObjects([yas_objc_view_controller class], [NSViewController class]);
    XCTAssertEqualObjects([yas_objc_color class], [NSColor class]);
}

@end

#endif
