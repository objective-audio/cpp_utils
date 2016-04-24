//
//  yas_tuple_utils_private.h
//

#pragma once

namespace yas {
template <typename Tpl, std::size_t N = std::tuple_size<typename std::remove_reference<Tpl>::type>::value - 1>
struct _is_true_tuple_all_values {
    static const bool value(Tpl const &tpl) {
        if (!std::get<N>(tpl)) {
            return false;
        } else if (std::get<N - 1>(tpl)) {
            return true;
        } else {
            return false;
        }
    }
};

template <typename Tpl>
struct _is_true_tuple_all_values<Tpl, 0> {
    static const bool value(Tpl const &tpl) {
        if (std::get<0>(tpl)) {
            return true;
        } else {
            return false;
        }
    }
};

template <typename Tpl>
bool is_true_all_values(Tpl const &tpl) {
    return _is_true_tuple_all_values<Tpl>::value(tpl);
}

template <typename... Args>
result<std::tuple<Args...>, std::nullptr_t> make_tuple_result(Args &&... args) {
    auto tpl = std::forward_as_tuple(args...);

    if (is_true_all_values(tpl)) {
        return result<std::tuple<Args...>, std::nullptr_t>{std::move(tpl)};
    } else {
        return result<std::tuple<Args...>, std::nullptr_t>{nullptr};
    }
}
}