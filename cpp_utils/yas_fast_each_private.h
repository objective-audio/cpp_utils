//
//  yas_fast_each_private.h
//

#pragma once

namespace yas {

#pragma mark - index

template <typename T>
fast_each<T, enable_if_integral_t<T>>::fast_each(T const end) : fast_each(0, end) {
}

template <typename T>
fast_each<T, enable_if_integral_t<T>>::fast_each(T const start, T const end)
    : _end(start > end ? start : end), _index(start), _next(start) {
}

template <typename T>
fast_each<T> make_each(T const end) {
    return fast_each<T>(end);
}

template <typename T>
fast_each<T> make_each(T const start, T const end) {
    return fast_each<T>(start, end);
}

#pragma mark - pointer

template <typename T>
fast_each<T, enable_if_pointer_t<T>>::fast_each(T ptr, std::size_t const end)
    : _ptr(ptr), _end(end), _index(0), _next(0) {
}

template <typename T>
fast_each<T> make_each(T ptr, std::size_t const length) {
    return fast_each<T>(ptr, length);
}
}
