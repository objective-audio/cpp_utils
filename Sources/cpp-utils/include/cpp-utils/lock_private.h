//
//  lock_private.h
//

#pragma once

namespace yas {
template <typename Type>
auto lock(std::weak_ptr<Type> const &weak) {
    return std::make_tuple(weak.lock());
}

template <typename First, typename... Weaks>
auto lock(std::weak_ptr<First> const &first_weak, Weaks const &...weaks) {
    return std::tuple_cat(std::make_tuple(first_weak.lock()), yas::lock(weaks...));
}

template <size_t N, typename... Types>
bool fulfilled(std::tuple<Types...> const &tuple) {
    if constexpr (N < std::tuple_size<std::tuple<Types...>>::value) {
        if (std::get<N>(tuple) == nullptr) {
            return false;
        } else {
            return fulfilled<N + 1>(tuple);
        }
    } else {
        return true;
    }
}
}  // namespace yas
