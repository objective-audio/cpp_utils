//
//  version.h
//

#pragma once

#include <string>
#include <vector>

namespace yas {
class version {
   public:
    version();
    explicit version(std::string str);
    explicit version(std::vector<int>);
    version(std::nullptr_t);

    bool operator==(version const &) const;
    bool operator!=(version const &) const;
    bool operator<(version const &) const;
    bool operator<=(version const &) const;
    bool operator>(version const &) const;
    bool operator>=(version const &) const;

    explicit operator bool() const;

    std::string str() const;
    std::vector<int> const &numbers() const;

   private:
    std::vector<int> _numbers;
};
}  // namespace yas
