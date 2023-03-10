//
//  yas_lock.hpp
//

#pragma once

#include <memory>
#include <tuple>

namespace yas {
template <typename Type>
auto lock(std::weak_ptr<Type> const &);

template <typename First, typename... Weaks>
auto lock(std::weak_ptr<First> const &, Weaks const &...);

template <size_t N = 0, typename... Types>
bool fulfilled(std::tuple<Types...> const &);
}  // namespace yas

#include <cpp_utils/yas_lock_private.h>
