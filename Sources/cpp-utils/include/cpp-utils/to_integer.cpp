//
//  to_integer.cpp
//

#include "to_integer.h"

namespace yas {
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
}  // namespace yas
