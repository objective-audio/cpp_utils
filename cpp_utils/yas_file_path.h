//
//  yas_file_path.h
//

#pragma once

#include <string>
#include <vector>
#include "yas_base.h"

namespace yas {
struct file_path {
    class impl;

    explicit file_path(std::string);
    explicit file_path(std::vector<std::string>);

    std::string string() const;
    std::string last_component() const;

    file_path appending(std::string) const;

    bool operator==(file_path const &) const;
    bool operator!=(file_path const &) const;

   private:
    std::shared_ptr<impl> _impl;
};
}  // namespace yas
