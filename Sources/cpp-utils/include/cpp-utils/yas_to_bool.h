//
//  yas_to_bool.h
//

#pragma once

#include <type_traits>

template <typename T>
bool to_bool(T const &src_enum) {
    return static_cast<typename std::underlying_type<T>::type>(src_enum);
}
