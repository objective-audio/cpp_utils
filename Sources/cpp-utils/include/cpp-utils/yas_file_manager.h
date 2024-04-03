//
//  yas_file_manager.h
//

#pragma once

#include <cpp-utils/yas_result.h>

#include <filesystem>
#include <ostream>
#include <string>

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

    enum class content_paths_error {
        not_directory,
        directory_not_found,
        find_contents_failed,
    };

    using create_dir_result_t = result<std::nullptr_t, create_dir_error>;
    using exists_result_t = result<content_kind, std::nullptr_t>;
    using remove_content_t = result<std::nullptr_t, remove_content_error>;
    using remove_contents_result_t = result<std::nullptr_t, remove_contents_error>;
    using content_paths_result_t = result<std::vector<std::filesystem::path>, content_paths_error>;

    [[nodiscard]] static create_dir_result_t create_directory_if_not_exists(std::filesystem::path const &);
    [[nodiscard]] static exists_result_t content_exists(std::filesystem::path const &);
    static remove_content_t remove_content(std::filesystem::path const &);
    static remove_contents_result_t remove_contents_in_directory(std::filesystem::path const &);
    [[nodiscard]] static content_paths_result_t content_paths_in_directory(std::filesystem::path const &);
};

std::string to_string(file_manager::create_dir_error const &);
std::string to_string(file_manager::content_kind const &);
std::string to_string(file_manager::remove_content_error const &);
std::string to_string(file_manager::remove_contents_error const &);
}  // namespace yas

std::ostream &operator<<(std::ostream &, yas::file_manager::create_dir_error const &);
std::ostream &operator<<(std::ostream &, yas::file_manager::content_kind const &);
std::ostream &operator<<(std::ostream &, yas::file_manager::remove_content_error const &);
std::ostream &operator<<(std::ostream &, yas::file_manager::remove_contents_error const &);
