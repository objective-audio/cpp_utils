//
//  to_integer.h
//

#pragma once

#include <limits.h>
#include <type_traits>
#include <string>

namespace yas {
template <typename T>
T to_integer(std::string const &str) {
    static_assert(std::is_integral<T>::value, "T must be integral type.");

    try {
        auto val = stoll(str);
        if (val <= std::numeric_limits<T>::max() && val >= std::numeric_limits<T>::min()) {
            return T(val);
        }
    } catch (...) {
    }

    return 0;
}

template <>
int64_t to_integer(std::string const &str);
template <>
uint64_t to_integer(std::string const &str);
}  // namespace yas
