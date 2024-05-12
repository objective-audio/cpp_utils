//
//  file_path.h
//

#pragma once

#include <string>
#include <vector>

namespace yas {
struct file_path final {
    explicit file_path(std::string const &);
    explicit file_path(std::vector<std::string> const &);

    std::string string() const;
    std::string last_component() const;

    file_path appending(std::string) const;

    bool operator==(file_path const &) const;
    bool operator!=(file_path const &) const;

   private:
    std::vector<std::string> const _components;
    std::string const _path;
};
}  // namespace yas
