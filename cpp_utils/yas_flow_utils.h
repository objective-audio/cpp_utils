//
//  yas_flow_utils.h
//

#pragma once

#include <functional>

namespace yas::flow {
template <typename T>
std::function<T(T const &)> add(T const &adding) {
    return [adding](T const &value) { return value + adding; };
}

template <typename T>
std::function<T(T const &)> multiply(T const &multiplying) {
    return [multiplying](T const &value) { return value * multiplying; };
}
}  // namespace yas::flow