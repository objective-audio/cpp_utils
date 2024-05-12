//
//  path_utils.h
//

#pragma once

#include <CoreFoundation/CoreFoundation.h>

#include <ostream>
#include <string>

namespace yas {
struct url final {
    class impl;

    explicit url(std::string const &str);
    static url file_url(std::string const &path);

    std::string path() const;
    std::string last_path_component() const;

    CFURLRef cf_url() const;

    url appending(std::string const &) const;
    url deleting_last_path_component() const;
    url deleting_path_extension() const;

    bool operator==(url const &rhs) const;
    bool operator!=(url const &rhs) const;

   private:
    std::shared_ptr<impl> _impl;

    url(std::shared_ptr<impl> &&);
};

std::string to_string(url const &);
}  // namespace yas

std::ostream &operator<<(std::ostream &os, yas::url const &url);
