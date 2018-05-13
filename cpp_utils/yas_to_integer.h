//
//  yas_to_integer.h
//

#pragma once

#include <limits.h>
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
int64_t to_integer(std::string const &str) {
    try {
        return stoll(str);
    } catch (...) {
        return 0;
    }
}

template <>
uint64_t to_integer(std::string const &str) {
    try {
        return stoull(str);
    } catch (...) {
        return 0;
    }
}
}
