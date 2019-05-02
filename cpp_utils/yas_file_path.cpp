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

struct file_path::impl : base::impl {
    std::vector<std::string> const components;
    std::string const path;

    impl(std::string &&path) : impl(file_path_utils::splited(path)) {
    }

    impl(std::vector<std::string> &&components)
        : components(std::move(components)), path(file_path_utils::joined(this->components)) {
    }

    bool is_equal(std::shared_ptr<base::impl> const &rhs) const {
        if (auto casted_rhs = std::dynamic_pointer_cast<impl>(rhs)) {
            return this->components == casted_rhs->components;
        } else {
            return false;
        }
    }
};

file_path::file_path(std::string path) : base(std::make_shared<impl>(std::move(path))) {
}

file_path::file_path(std::vector<std::string> components) : base(std::make_shared<impl>(std::move(components))) {
}

file_path::file_path(std::nullptr_t) : base(nullptr) {
}

std::string file_path::string() const {
    return impl_ptr<impl>()->path;
}

std::string file_path::last_component() const {
    auto const &components = impl_ptr<impl>()->components;
    if (components.size() > 0) {
        return components.back();
    } else {
        return "";
    }
}

file_path file_path::appending(std::string component) const {
    auto components = impl_ptr<impl>()->components;
    components.emplace_back(std::move(component));
    return file_path{std::move(components)};
}
