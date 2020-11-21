//
//  yas_path_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/cpp_utils.h>

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

- (void)test_last_path_component {
    XCTAssertEqual(yas::url{"test/dir/file.ext"}.last_path_component(), "file.ext");
    XCTAssertEqual(yas::url{"test/dir/"}.last_path_component(), "dir");
    XCTAssertEqual(yas::url{"test/dir"}.last_path_component(), "dir");
}

- (void)test_append {
    auto url = yas::url{"test/dir"};
    auto appended = url.appending("file.ext");

    XCTAssertEqual(appended.path(), "test/dir/file.ext");
}

- (void)test_is_equal {
    auto url1a = yas::url{"test/dir"};
    auto url1b = yas::url{"test/dir"};
    auto url2 = yas::url{"test/dir2"};

    XCTAssertEqual(url1a, url1b);
    XCTAssertNotEqual(url1a, url2);
}

@end
