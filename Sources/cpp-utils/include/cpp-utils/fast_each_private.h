//
//  fast_each_private.h
//

#pragma once

namespace yas {

#pragma mark - index

template <typename T>
fast_each<T, enable_if_integral_t<T>>::fast_each(T const end) : fast_each(0, end) {
}

template <typename T>
fast_each<T, enable_if_integral_t<T>>::fast_each(T const begin, T const end)
    : _end(begin > end ? begin : end), _index(begin), _next(begin) {
}

template <typename T>
void fast_each<T, enable_if_integral_t<T>>::reset(T const end) {
    this->reset(0, end);
}

template <typename T>
void fast_each<T, enable_if_integral_t<T>>::reset(T const begin, T const end) {
    this->_end = begin > end ? begin : end;
    this->_next = begin;
    this->_index = begin;
}

template <typename T>
fast_each<T> make_fast_each(T const end) {
    return fast_each<T>(end);
}

template <typename T>
fast_each<T> make_fast_each(T const begin, T const end) {
    return fast_each<T>(begin, end);
}

#pragma mark - pointer

template <typename T>
fast_each<T, enable_if_pointer_t<T>>::fast_each(T ptr, std::size_t const end)
    : _ptr(ptr), _end(end), _index(0), _next(0) {
}

template <typename T>
fast_each<T, enable_if_pointer_t<T>>::fast_each() : _ptr(nullptr), _end(0), _index(0), _next(0) {
}

template <typename T>
void fast_each<T, enable_if_pointer_t<T>>::reset(T ptr, std::size_t const end) {
    this->_ptr = ptr;
    this->_end = end;
    this->_index = 0;
    this->_next = 0;
}

template <typename T>
fast_each<T> make_fast_each_ptr(T ptr, std::size_t const length) {
    return fast_each<T>(ptr, length);
}
}  // namespace yas
