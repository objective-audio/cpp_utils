//
//  yas_file_path.cpp
//

#include "yas_file_path.h"
#include "yas_stl_utils.h"

using namespace yas;

namespace yas::file_path_utils {
static std::vector<std::string> splited(std::string const &path) {
    auto splited = yas::split(path, '/');
    if (splited.size() > 0 && splited.at(0).length() == 0) {
        splited.erase(splited.begin());
    }
    return splited;
}

static std::string joined(std::vector<std::string> const &components) {
    if (components.size() > 0) {
        return "/" + yas::joined(components, "/");
    } else {
        return "";
    }
}
}  // namespace yas::file_path_utils

struct file_path::impl {
    std::vector<std::string> const components;
    std::string const path;

    impl(std::string &&path) : impl(file_path_utils::splited(path)) {
    }

    impl(std::vector<std::string> &&components)
        : components(std::move(components)), path(file_path_utils::joined(this->components)) {
    }

    bool is_equal(std::shared_ptr<impl> const &rhs) const {
        return this->components == rhs->components;
    }
};

file_path::file_path(std::string path) : _impl(std::make_shared<impl>(std::move(path))) {
}

file_path::file_path(std::vector<std::string> components) : _impl(std::make_shared<impl>(std::move(components))) {
}

std::string file_path::string() const {
    return this->_impl->path;
}

std::string file_path::last_component() const {
    auto const &components = this->_impl->components;
    if (components.size() > 0) {
        return components.back();
    } else {
        return "";
    }
}

file_path file_path::appending(std::string component) const {
    auto components = this->_impl->components;
    components.emplace_back(std::move(component));
    return file_path{std::move(components)};
}

bool file_path::operator==(file_path const &rhs) const {
    return this->_impl->is_equal(rhs._impl);
}

bool file_path::operator!=(file_path const &rhs) const {
    return !(*this == rhs);
}
