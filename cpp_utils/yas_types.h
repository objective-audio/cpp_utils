//
//  yas_types.h
//

#pragma once

#include <optional>

namespace yas {
template <typename T>
using opt_t = std::optional<T>;

std::nullopt_t constexpr nullopt = std::nullopt;
}  // namespace yas
