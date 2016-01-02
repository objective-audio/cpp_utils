//
//  yas_version.h
//

#pragma once

#include <string>
#include <vector>

namespace yas {
class version {
   public:
    version();
    version(std::string const &str);
    version(std::vector<int> const &);
    version(std::nullptr_t);

    bool operator==(version const &) const;
    bool operator!=(version const &) const;
    bool operator<(version const &) const;
    bool operator<=(version const &) const;
    bool operator>(version const &) const;
    bool operator>=(version const &) const;

    std::string str() const;
    std::vector<int> const &numbers() const;

   private:
    std::vector<int> _numbers;
};
}
