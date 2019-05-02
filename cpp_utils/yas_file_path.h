//
//  yas_file_path.h
//

#pragma once

#include <string>
#include <vector>
#include "yas_base.h"

namespace yas {
struct file_path : base {
    class impl;

    explicit file_path(std::string);
    explicit file_path(std::vector<std::string>);
    file_path(std::nullptr_t);

    std::string string() const;
    std::string last_component() const;

    file_path appending(std::string) const;
};
}  // namespace yas
