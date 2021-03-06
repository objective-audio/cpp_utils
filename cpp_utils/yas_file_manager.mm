//
//  yas_file_manager.mm
//

#include "yas_file_manager.h"
#import <Foundation/Foundation.h>
#include "yas_cf_utils.h"

using namespace yas;

file_manager::create_dir_result_t file_manager::create_directory_if_not_exists(std::string const &path) {
    auto file_manager = [NSFileManager defaultManager];
    CFStringRef cf_path = to_cf_object(path);

    if (auto exists_result = file_manager::content_exists(path); exists_result.is_error()) {
        NSError *error = nil;
        if (![file_manager createDirectoryAtPath:(__bridge NSString *)cf_path
                     withIntermediateDirectories:YES
                                      attributes:nil
                                           error:&error]) {
            return create_dir_result_t{create_dir_error::create_failed};
        }
    } else if (exists_result.value() == content_kind::file) {
        return create_dir_result_t{create_dir_error::file_exists};
    }

    return create_dir_result_t{nullptr};
}

file_manager::exists_result_t file_manager::content_exists(std::string const &path) {
    auto file_manager = [NSFileManager defaultManager];
    BOOL is_directory = NO;
    CFStringRef cf_path = to_cf_object(path);

    if ([file_manager fileExistsAtPath:(__bridge NSString *)cf_path isDirectory:&is_directory]) {
        if (is_directory) {
            return exists_result_t{content_kind::directory};
        } else {
            return exists_result_t{content_kind::file};
        }
    } else {
        return exists_result_t{nullptr};
    }
}

file_manager::remove_content_t file_manager::remove_content(std::string const &path) {
    if (file_manager::content_exists(path)) {
        auto file_manager = [NSFileManager defaultManager];
        CFStringRef cf_path = to_cf_object(path);

        if (![file_manager removeItemAtPath:(__bridge NSString *)cf_path error:nil]) {
            return remove_content_t{remove_content_error::remove_failed};
        }
    }
    return remove_content_t{nullptr};
}

file_manager::remove_contents_result_t file_manager::remove_contents_in_directory(std::string const &path) {
    if (auto const result = file_manager::content_exists(path)) {
        if (result.value() != content_kind::directory) {
            return remove_contents_result_t{remove_contents_error::not_directory};
        }
    } else {
        return remove_contents_result_t{nullptr};
    }

    auto file_manager = [NSFileManager defaultManager];
    CFStringRef cf_path = to_cf_object(path);

    @autoreleasepool {
        NSError *error = nil;
        NSArray<NSURL *> *urls =
            [file_manager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:(__bridge NSString *)cf_path]
                        includingPropertiesForKeys:nil
                                           options:kNilOptions
                                             error:&error];
        if (error) {
            return remove_contents_result_t{remove_contents_error::find_contents_failed};
        }

        for (NSURL *url in urls) {
            if (![file_manager removeItemAtURL:url error:nil]) {
                return remove_contents_result_t{remove_contents_error::remove_failed};
            }
        }

        return remove_contents_result_t{nullptr};
    }
}

file_manager::content_paths_result_t file_manager::content_paths_in_directory(std::string const &path) {
    if (auto const result = file_manager::content_exists(path)) {
        if (result.value() != content_kind::directory) {
            return content_paths_result_t{content_paths_error::not_directory};
        }
    } else {
        return content_paths_result_t{content_paths_error::directory_not_found};
    }

    auto file_manager = [NSFileManager defaultManager];
    CFStringRef cf_path = to_cf_object(path);

    @autoreleasepool {
        NSError *error = nil;
        NSArray<NSURL *> *urls =
            [file_manager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:(__bridge NSString *)cf_path]
                        includingPropertiesForKeys:nil
                                           options:kNilOptions
                                             error:&error];

        if (error) {
            return content_paths_result_t{content_paths_error::find_contents_failed};
        }

        std::vector<std::string> paths;

        for (NSURL *url in urls) {
            paths.emplace_back(to_string((__bridge CFStringRef)url.path));
        }

        return content_paths_result_t{std::move(paths)};
    }
}

std::string yas::to_string(file_manager::create_dir_error const &error) {
    switch (error) {
        case file_manager::create_dir_error::create_failed:
            return "create_failed";
        case file_manager::create_dir_error::file_exists:
            return "file_exists";
    }
}

std::string yas::to_string(file_manager::content_kind const &kind) {
    switch (kind) {
        case file_manager::content_kind::directory:
            return "directory";
        case file_manager::content_kind::file:
            return "file";
    }
}

std::string yas::to_string(file_manager::remove_content_error const &error) {
    switch (error) {
        case file_manager::remove_content_error::remove_failed:
            return "remove_failed";
    }
}

std::string yas::to_string(file_manager::remove_contents_error const &error) {
    switch (error) {
        case file_manager::remove_contents_error::not_directory:
            return "not_directory";
        case file_manager::remove_contents_error::remove_failed:
            return "remove_failed";
        case file_manager::remove_contents_error::find_contents_failed:
            return "find_contents_failed";
    }
}
