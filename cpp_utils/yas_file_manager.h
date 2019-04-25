//
//  yas_file_manager.h
//

#pragma once

#include <string>
#include "yas_result.h"

namespace yas {
struct file_manager {
    enum class create_dir_error {
        create_failed,
        file_exists,
    };

    enum class content_kind {
        file,
        directory,
    };

    enum class remove_content_error {
        remove_failed,
    };

    enum class remove_contents_error {
        not_directory,
        remove_failed,
        find_contents_failed,
    };

    using create_dir_result_t = result<std::nullptr_t, create_dir_error>;
    using exists_result_t = result<content_kind, std::nullptr_t>;
    using remove_content_t = result<std::nullptr_t, remove_content_error>;
    using remove_contents_result_t = result<std::nullptr_t, remove_contents_error>;

    [[nodiscard]] static create_dir_result_t create_directory_if_not_exists(std::string const &path);
    [[nodiscard]] static exists_result_t content_exists(std::string const &path);
    static remove_content_t remove_content(std::string const &path);
    static remove_contents_result_t remove_contents_in_directory(std::string const &dir_path);
};

std::string to_string(file_manager::create_dir_error const &);
std::string to_string(file_manager::content_kind const &);
std::string to_string(file_manager::remove_content_error const &);
std::string to_string(file_manager::remove_contents_error const &);
}  // namespace yas
