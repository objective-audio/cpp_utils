//
//  yas_types.h
//

#pragma once

#include <experimental/optional>

namespace yas {
template <typename T>
using opt_t = std::experimental::optional<T>;

std::experimental::nullopt_t constexpr nullopt = std::experimental::nullopt;
}  // namespace yas
