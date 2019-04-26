//
//  yas_file_manager_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/yas_cf_utils.h>
#import <cpp_utils/yas_file_manager.h>
#import <cpp_utils/yas_system_url_utils.h>
#import <cpp_utils/yas_url.h>

using namespace yas;

@interface yas_file_manager_tests : XCTestCase

@end

struct yas_file_manager_tests_cpp {
    url test_dir_url = system_url_utils::directory_url(system_url_utils::dir::document).appending("test");
    url test_file_url = this->test_dir_url.appending("test_file");
};

@implementation yas_file_manager_tests {
    yas_file_manager_tests_cpp _cpp;
}

- (void)setUp {
    file_manager::remove_content(self->_cpp.test_dir_url.path());
}

- (void)tearDown {
    file_manager::remove_content(self->_cpp.test_dir_url.path());
}

- (void)test_create_directory_if_exists {
    auto const &dir_url = self->_cpp.test_dir_url;
    auto const &file_url = self->_cpp.test_file_url;

    auto result1 = file_manager::create_directory_if_not_exists(dir_url.path());

    XCTAssertTrue(result1);

    auto result2 = file_manager::create_directory_if_not_exists(dir_url.path());

    XCTAssertTrue(result1);

    [self create_file];

    auto result3 = file_manager::create_directory_if_not_exists(file_url.path());

    XCTAssertFalse(result3);
    XCTAssertEqual(result3.error(), file_manager::create_dir_error::file_exists);
}

- (void)test_content_exists {
    auto const &dir_url = self->_cpp.test_dir_url;
    auto const &file_url = self->_cpp.test_file_url;

    XCTAssertFalse(file_manager::content_exists(dir_url.path()));
    XCTAssertFalse(file_manager::content_exists(file_url.path()));

    auto result = file_manager::create_directory_if_not_exists(dir_url.path());
    [self create_file];

    XCTAssertTrue(file_manager::content_exists(dir_url.path()));
    XCTAssertTrue(file_manager::content_exists(file_url.path()));
}

- (void)test_remove_content {
    auto const &dir_url = self->_cpp.test_dir_url;
    auto const &file_url = self->_cpp.test_file_url;

    auto result = file_manager::create_directory_if_not_exists(dir_url.path());
    [self create_file];

    auto result1 = file_manager::remove_content(file_url.path());

    XCTAssertTrue(result1);
    XCTAssertTrue(file_manager::content_exists(dir_url.path()));
    XCTAssertFalse(file_manager::content_exists(file_url.path()));

    auto result2 = file_manager::remove_content(dir_url.path());

    XCTAssertFalse(file_manager::content_exists(dir_url.path()));
}

- (void)test_remove_contents_in_directory {
    auto const &dir_url = self->_cpp.test_dir_url;
    auto const &file_url = self->_cpp.test_file_url;

    auto result = file_manager::create_directory_if_not_exists(dir_url.path());
    [self create_file];

    auto result1 = file_manager::remove_contents_in_directory(dir_url.path());

    XCTAssertTrue(result1);
    XCTAssertTrue(file_manager::content_exists(dir_url.path()));
    XCTAssertFalse(file_manager::content_exists(file_url.path()));
}

- (void)test_to_string_from_create_dir_error {
    XCTAssertEqual(to_string(file_manager::create_dir_error::create_failed), "create_failed");
    XCTAssertEqual(to_string(file_manager::create_dir_error::file_exists), "file_exists");
}

- (void)test_to_string_from_content_kind {
    XCTAssertEqual(to_string(file_manager::content_kind::directory), "directory");
    XCTAssertEqual(to_string(file_manager::content_kind::file), "file");
}

- (void)test_to_string_from_remove_content_error {
    XCTAssertEqual(to_string(file_manager::remove_content_error::remove_failed), "remove_failed");
}

- (void)test_to_string_from_remove_contents_error {
    XCTAssertEqual(to_string(file_manager::remove_contents_error::not_directory), "not_directory");
    XCTAssertEqual(to_string(file_manager::remove_contents_error::remove_failed), "remove_failed");
    XCTAssertEqual(to_string(file_manager::remove_contents_error::find_contents_failed), "find_contents_failed");
}

#pragma mark -

- (void)create_file {
    NSData *data = [NSMutableData dataWithLength:1];
    auto cf_file_path = to_cf_object(self->_cpp.test_file_url.path());
    [[NSFileManager defaultManager] createFileAtPath:(__bridge NSString *)cf_file_path contents:data attributes:nil];
}

@end
