//
//  yas_to_string.h
//

#pragma once

#include <string>

namespace yas {
template <typename T>
std::string to_string(T const &value) {
    return std::to_string(value);
}
}
