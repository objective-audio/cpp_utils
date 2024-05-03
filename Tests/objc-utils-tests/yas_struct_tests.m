//
//  yas_mac_struct_tests.m
//

#import <TargetConditionals.h>

#if !TARGET_OS_IPHONE && TARGET_OS_MAC

#import <XCTest/XCTest.h>
@import objc_utils;

@interface yas_mac_struct_tests : XCTestCase

@end

@implementation yas_mac_struct_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_edge_insets {
    yas_edge_insets edge_insets;
    edge_insets.top = 1.0;
    edge_insets.left = 2.0;
    edge_insets.bottom = 4.0;
    edge_insets.right = 16.0;

    XCTAssertEqual(edge_insets.top, 1.0);
    XCTAssertEqual(edge_insets.left, 2.0);
    XCTAssertEqual(edge_insets.bottom, 4.0);
    XCTAssertEqual(edge_insets.right, 16.0);
}

@end

#endif
