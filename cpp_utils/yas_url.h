//
//  yas_path_utils.h
//

#pragma once

#include <CoreFoundation/CoreFoundation.h>
#include <string>
#include "yas_base.h"

namespace yas {
struct url : base {
    class impl;

    explicit url(std::string const &str);
    url(std::nullptr_t);
    static url file_url(std::string const &path);

    std::string path() const;
    CFURLRef cf_url() const;

    url appending(std::string const &) const;

   protected:
    url(std::shared_ptr<impl> &&);
};

std::string to_string(url const &);
}  // namespace yas

std::ostream &operator<<(std::ostream &os, yas::url const &url);
