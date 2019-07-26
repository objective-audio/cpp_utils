//
//  yas_path_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/yas_file_path.h>

@interface yas_path_tests : XCTestCase

@end

@implementation yas_path_tests

- (void)setUp {
}

- (void)tearDown {
}

- (void)test_make_file_path {
    auto path = yas::file_path{"test/dir"};

    XCTAssertEqual(path.string(), "/test/dir");
}

- (void)test_top_slash {
    auto path = yas::file_path{"/test/dir"};

    XCTAssertEqual(path.string(), "/test/dir");
}

- (void)test_last_slash {
    auto path = yas::file_path{"test/dir/"};

    XCTAssertEqual(path.string(), "/test/dir");
}

- (void)test_last_component {
    XCTAssertEqual(yas::file_path{"test/dir/file.ext"}.last_component(), "file.ext");
    XCTAssertEqual(yas::file_path{"test/dir/"}.last_component(), "dir");
    XCTAssertEqual(yas::file_path{"test/dir"}.last_component(), "dir");
}

- (void)test_appending {
    auto path = yas::file_path{"test/dir"};
    auto appended = path.appending("file.ext");

    XCTAssertEqual(appended.string(), "/test/dir/file.ext");
}

- (void)test_is_equal {
    auto path1a = yas::file_path{"test/dir"};
    auto path1b = yas::file_path{"test/dir"};
    auto path2 = yas::file_path{"test/dir2"};

    XCTAssertEqual(path1a, path1b);
    XCTAssertNotEqual(path1a, path2);
}

- (void)test_move_and_copy {
    auto path = yas::file_path{"test/dir"};
    auto copied = path;
    auto moved = std::move(path);

    XCTAssertEqual(moved, copied);
}

@end
