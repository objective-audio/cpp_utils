//
//  yas_version.h
//

#pragma once

#include <string>
#include <vector>

namespace yas {
class version {
   public:
    version(std::string const &);
    version(std::vector<int> const &);

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
