//
//  yas_path_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_url.h"

#import <iostream>

using namespace yas;

@interface yas_url_tests : XCTestCase

@end

@implementation yas_url_tests

- (void)setUp {
}

- (void)tearDown {
}

- (void)test_make_path {
    auto url = yas::url{"test/dir"};

    XCTAssertEqual(url.path(), "test/dir");
}

- (void)test_make_file_url {
    auto url = yas::url::file_url("test/dir");

    std::string expected = "/test/dir";
    XCTAssertEqual(url.path().compare(url.path().size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_make_path_last_slash {
    auto url = yas::url{"test/dir/"};

    XCTAssertEqual(url.path(), "test/dir");
}

- (void)test_append {
    auto url = yas::url{"test/dir"};
    auto appended = url.appending("file.ext");

    XCTAssertEqual(appended.path(), "test/dir/file.ext");
}

@end
