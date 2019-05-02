//
//  yas_file_path.cpp
//

#include "yas_file_path.h"
#include "yas_stl_utils.h"

using namespace yas;

namespace yas {
static std::vector<std::string> splited(std::string const &path) {
    auto splited = yas::split(path, '/');
    if (splited.size() > 0 && splited.at(0).length() == 0) {
        splited.erase(splited.begin());
    }
    return splited;
}
}  // namespace yas

struct file_path::impl : base::impl {
    std::vector<std::string> components;

    impl(std::string &&path) : components(splited(path)) {
    }

    impl(std::vector<std::string> &&components) : components(std::move(components)) {
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
    auto const &components = impl_ptr<impl>()->components;
    if (components.size() > 0) {
        return "/" + joined(components, "/");
    } else {
        return "";
    }
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
