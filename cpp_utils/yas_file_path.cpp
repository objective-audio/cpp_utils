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

file_path::file_path(std::string const &path) : file_path(file_path_utils::splited(path)) {
}

file_path::file_path(std::vector<std::string> const &components)
    : _components(components), _path(file_path_utils::joined(this->_components)) {
}

std::string file_path::string() const {
    return this->_path;
}

std::string file_path::last_component() const {
    auto const &components = this->_components;
    if (components.size() > 0) {
        return components.back();
    } else {
        return "";
    }
}

file_path file_path::appending(std::string component) const {
    auto components = this->_components;
    components.emplace_back(std::move(component));
    return file_path{std::move(components)};
}

bool file_path::operator==(file_path const &rhs) const {
    return this->_components == rhs._components;
}

bool file_path::operator!=(file_path const &rhs) const {
    return !(*this == rhs);
}
