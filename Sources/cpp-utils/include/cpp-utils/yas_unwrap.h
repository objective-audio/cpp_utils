//
//  yas_unwrap.h
//

#pragma once

#include <optional>
#include <tuple>

namespace yas {
template <typename Type>
auto unwrap(std::optional<Type> const &);

template <typename First, typename... Opts>
auto unwrap(std::optional<First> const &, Opts const &...);

template <typename Type>
bool has_values(std::optional<Type> const &);

template <typename First, typename... Opts>
bool has_values(std::optional<First> const &, Opts const &...);
}  // namespace yas

#include "yas_unwrap_private.h"
