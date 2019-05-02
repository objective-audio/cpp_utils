//
//  yas_file_manager_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/yas_cf_utils.h>
#import <cpp_utils/yas_file_manager.h>
#import <cpp_utils/yas_file_path.h>
#import <cpp_utils/yas_stl_utils.h>
#import <cpp_utils/yas_system_path_utils.h>

using namespace yas;

@interface yas_file_manager_tests : XCTestCase

@end

struct yas_file_manager_tests_cpp {
    yas::file_path root_path =
        yas::file_path{system_path_utils::directory_path(system_path_utils::dir::document)}.appending("root");
    yas::file_path file_path = this->root_path.appending("file");
    yas::file_path dir_path = this->root_path.appending("dir");
    yas::file_path empty_path = this->root_path.appending("empty");
};

@implementation yas_file_manager_tests {
    yas_file_manager_tests_cpp _cpp;
}

- (void)setUp {
    file_manager::remove_content(self->_cpp.root_path.string());
}

- (void)tearDown {
    file_manager::remove_content(self->_cpp.root_path.string());
}

- (void)test_create_directory_if_exists {
    auto const &root_path = self->_cpp.root_path;
    auto const &file_path = self->_cpp.file_path;

    auto const result1 = file_manager::create_directory_if_not_exists(root_path.string());

    XCTAssertTrue(result1);

    auto const result2 = file_manager::create_directory_if_not_exists(root_path.string());

    XCTAssertTrue(result1);

    [self create_file];

    auto const result3 = file_manager::create_directory_if_not_exists(file_path.string());

    XCTAssertFalse(result3);
    XCTAssertEqual(result3.error(), file_manager::create_dir_error::file_exists);
}

- (void)test_content_exists {
    auto const &root_path = self->_cpp.root_path;
    auto const &file_path = self->_cpp.file_path;

    XCTAssertFalse(file_manager::content_exists(root_path.string()));
    XCTAssertFalse(file_manager::content_exists(file_path.string()));

    auto const result = file_manager::create_directory_if_not_exists(root_path.string());
    [self create_file];

    XCTAssertTrue(file_manager::content_exists(root_path.string()));
    XCTAssertTrue(file_manager::content_exists(file_path.string()));
}

- (void)test_remove_content {
    auto const &root_path = self->_cpp.root_path;
    auto const &file_path = self->_cpp.file_path;

    auto const result = file_manager::create_directory_if_not_exists(root_path.string());
    [self create_file];

    auto const result1 = file_manager::remove_content(file_path.string());

    XCTAssertTrue(result1);
    XCTAssertTrue(file_manager::content_exists(root_path.string()));
    XCTAssertFalse(file_manager::content_exists(file_path.string()));

    auto const result2 = file_manager::remove_content(root_path.string());

    XCTAssertFalse(file_manager::content_exists(root_path.string()));
}

- (void)test_remove_contents_in_directory {
    auto const &root_path = self->_cpp.root_path;
    auto const &file_path = self->_cpp.file_path;

    auto const result = file_manager::create_directory_if_not_exists(root_path.string());
    [self create_file];

    auto const result1 = file_manager::remove_contents_in_directory(root_path.string());

    XCTAssertTrue(result1);
    XCTAssertTrue(file_manager::content_exists(root_path.string()));
    XCTAssertFalse(file_manager::content_exists(file_path.string()));
}

- (void)test_content_paths_in_directory {
    auto const &root_path = self->_cpp.root_path;
    auto const &file_path = self->_cpp.file_path;
    auto const &dir_path = self->_cpp.dir_path;
    auto const &empty_path = self->_cpp.empty_path;

    auto const root_result = file_manager::create_directory_if_not_exists(root_path.string());
    auto const dir_result = file_manager::create_directory_if_not_exists(dir_path.string());
    [self create_file];

    auto result = file_manager::content_paths_in_directory(root_path.string());

    XCTAssertTrue(result);

    auto const &paths = result.value();

    XCTAssertEqual(paths.size(), 2);
    XCTAssertTrue(contains(paths, file_path.string()));
    XCTAssertTrue(contains(paths, dir_path.string()));

    auto result2 = file_manager::content_paths_in_directory(file_path.string());

    XCTAssertFalse(result2);
    XCTAssertEqual(result2.error(), file_manager::content_paths_error::not_directory);

    auto result3 = file_manager::content_paths_in_directory(empty_path.string());

    XCTAssertFalse(result3);
    XCTAssertEqual(result3.error(), file_manager::content_paths_error::directory_not_found);
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
    auto cf_file_path = to_cf_object(self->_cpp.file_path.string());
    [[NSFileManager defaultManager] createFileAtPath:(__bridge NSString *)cf_file_path contents:data attributes:nil];
}

@end
