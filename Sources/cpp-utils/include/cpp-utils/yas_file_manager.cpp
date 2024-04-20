//
//  yas_file_manager.mm
//

#include "yas_file_manager.h"

#include "yas_cf_utils.h"

using namespace yas;

file_manager::create_dir_result_t file_manager::create_directory_if_not_exists(std::filesystem::path const &path) {
    std::error_code error_code;

    if (auto const result = content_exists(path)) {
        switch (result.value()) {
            case content_kind::directory:
                return create_dir_result_t{nullptr};
            case content_kind::file:
                return create_dir_result_t{create_dir_error::file_exists};
        }
    }

    auto const result = std::filesystem::create_directories(path, error_code);

    if (!result || error_code) {
        return create_dir_result_t{create_dir_error::create_failed};
    }

    return create_dir_result_t{nullptr};
}

file_manager::exists_result_t file_manager::content_exists(std::filesystem::path const &content_path) {
    std::error_code error_code;

    bool exists = std::filesystem::exists(content_path, error_code);

    if (error_code) {
        return exists_result_t{nullptr};
    }

    if (exists) {
        bool const result = std::filesystem::is_directory(content_path, error_code);

        if (error_code) {
            return exists_result_t{nullptr};
        }

        if (result) {
            return exists_result_t{content_kind::directory};
        } else {
            return exists_result_t{content_kind::file};
        }
    } else {
        return exists_result_t{nullptr};
    }
}

file_manager::remove_content_t file_manager::remove_content(std::filesystem::path const &path) {
    if (file_manager::content_exists(path)) {
        std::error_code error_code;

        bool result = std::filesystem::remove_all(path, error_code);

        if (error_code || !result) {
            return remove_content_t{remove_content_error::remove_failed};
        }
    }
    return remove_content_t{nullptr};
}

file_manager::remove_contents_result_t file_manager::remove_contents_in_directory(std::filesystem::path const &path) {
    if (auto const result = file_manager::content_exists(path)) {
        if (result.value() != content_kind::directory) {
            return remove_contents_result_t{remove_contents_error::not_directory};
        }
    } else {
        return remove_contents_result_t{nullptr};
    }

    std::error_code error_code;

    auto const iterator = std::filesystem::directory_iterator(path, error_code);

    if (error_code) {
        return remove_contents_result_t{remove_contents_error::find_contents_failed};
    }

    for (auto const &content : iterator) {
        auto const result = std::filesystem::remove_all(content.path(), error_code);
        if (error_code || !result) {
            return remove_contents_result_t{remove_contents_error::remove_failed};
        }
    }

    return remove_contents_result_t{nullptr};
}

file_manager::content_paths_result_t file_manager::content_paths_in_directory(std::filesystem::path const &path) {
    if (auto const result = file_manager::content_exists(path)) {
        if (result.value() != content_kind::directory) {
            return content_paths_result_t{content_paths_error::not_directory};
        }
    } else {
        return content_paths_result_t{content_paths_error::directory_not_found};
    }

    std::error_code error_code;

    auto const iterator = std::filesystem::directory_iterator(path, error_code);

    if (error_code) {
        return content_paths_result_t{content_paths_error::find_contents_failed};
    }

    std::vector<std::filesystem::path> paths;

    for (auto const &content : iterator) {
        paths.emplace_back(content.path());
    }

    return content_paths_result_t{std::move(paths)};
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

std::ostream &operator<<(std::ostream &os, yas::file_manager::create_dir_error const &value) {
    os << to_string(value);
    return os;
}

std::ostream &operator<<(std::ostream &os, yas::file_manager::content_kind const &value) {
    os << to_string(value);
    return os;
}

std::ostream &operator<<(std::ostream &os, yas::file_manager::remove_content_error const &value) {
    os << to_string(value);
    return os;
}

std::ostream &operator<<(std::ostream &os, yas::file_manager::remove_contents_error const &value) {
    os << to_string(value);
    return os;
}
