//
//  ns_utils_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp-utils/ns_utils.h>

using namespace yas;

@interface ns_utils_tests : XCTestCase

@end

@implementation ns_utils_tests

- (void)test_to_ns_object_from_string {
    auto ns_object = to_ns_object("test_string");
    XCTAssertEqualObjects(ns_object.object(), @"test_string");

    XCTAssertEqualObjects(to_ns_object("autoreleased_string").autoreleased_object(), @"autoreleased_string");
}

@end
