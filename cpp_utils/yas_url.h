//
//  yas_path_utils.h
//

#pragma once

#include <CoreFoundation/CoreFoundation.h>
#include <ostream>
#include <string>
#include "yas_base.h"

namespace yas {
struct url : base {
    class impl;

    explicit url(std::string const &str);
    static url file_url(std::string const &path);

    std::string path() const;
    std::string last_path_component() const;

    CFURLRef cf_url() const;

    url appending(std::string const &) const;

   protected:
    url(std::shared_ptr<impl> &&);
};

std::string to_string(url const &);
}  // namespace yas

std::ostream &operator<<(std::ostream &os, yas::url const &url);
