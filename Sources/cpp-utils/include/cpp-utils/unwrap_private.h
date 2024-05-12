//
//  unwrap_private.h
//

#pragma once

namespace yas {

template <typename Type>
auto unwrap(std::optional<Type> const &opt_value) {
    return std::make_tuple(opt_value.value());
}

template <typename First, typename... Opts>
auto unwrap(std::optional<First> const &first_opt, Opts const &...opts) {
    return std::tuple_cat(std::make_tuple(first_opt.value()), yas::unwrap(opts...));
}

template <typename Type>
bool has_values(std::optional<Type> const &opt_value) {
    return opt_value.has_value();
}

template <typename First, typename... Opts>
bool has_values(std::optional<First> const &first_opt, Opts const &...opts) {
    if (first_opt.has_value()) {
        return has_values(std::forward<Opts const &>(opts)...);
    } else {
        return false;
    }
}
}  // namespace yas
