//
//  yas_types.h
//

#pragma once

#include <experimental/optional>

namespace yas {
template <typename T>
using opt_t = std::experimental::optional<T>;

constexpr std::experimental::nullopt_t nullopt = std::experimental::nullopt;
}  // namespace yas
