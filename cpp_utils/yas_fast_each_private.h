//
//  yas_fast_each_private.h
//

#pragma once

namespace yas {
#pragma mark - ptr

template <typename T>
ptr_enumerator<T>::ptr_enumerator(T *pointer, length_t const length)
    : _ptr(pointer), _top_ptr(pointer), _ptr_ptr(&_ptr), _index(0), length(length) {
}

template <typename T>
ptr_enumerator<T>::ptr_enumerator(std::vector<T> &vec) : ptr_enumerator(vec.data(), static_cast<length_t>(vec.size())) {
}

template <typename T>
T const *const *ptr_enumerator<T>::ptr_ptr() const {
    return _ptr_ptr;
}

template <typename T>
T *const *ptr_enumerator<T>::ptr_ptr() {
    return _ptr_ptr;
}

template <typename T>
typename ptr_enumerator<T>::index_t const *ptr_enumerator<T>::index_ptr() const {
    return &_index;
}

template <typename T>
bool ptr_enumerator<T>::has_value() const {
    return yas_ptr_enumerator_has_value(*this);
}

template <typename T>
T const &ptr_enumerator<T>::value() const {
    return yas_ptr_enumerator_value(*this);
}

template <typename T>
T &ptr_enumerator<T>::value() {
    return yas_ptr_enumerator_value(*this);
}

template <typename T>
void ptr_enumerator<T>::set_value(T const &value) {
    yas_ptr_enumerator_value(*this) = value;
}

template <typename T>
void ptr_enumerator<T>::set_value(T &&value) {
    yas_ptr_enumerator_value(*this) = std::move(value);
}

template <typename T>
typename ptr_enumerator<T>::index_t ptr_enumerator<T>::index() const {
    return yas_ptr_enumerator_index(*this);
}

template <typename T>
void ptr_enumerator<T>::set_index(uint32_t const index) {
    if (index >= length) {
        throw std::out_of_range(std::string(__PRETTY_FUNCTION__) + " : out of range. position(" +
                                std::to_string(index) + ") length(" + std::to_string(length) + ")");
        return;
    }
    _index = index;
    _ptr = _top_ptr + index;
}

template <typename T>
void ptr_enumerator<T>::move() {
    yas_ptr_enumerator_move(*this);
}

template <typename T>
void ptr_enumerator<T>::stop() {
    yas_ptr_enumerator_stop(*this);
}

template <typename T>
void ptr_enumerator<T>::reset() {
    _index = 0;
    _ptr = _top_ptr;
}

template <typename T>
ptr_enumerator<T> &ptr_enumerator<T>::operator++() {
    yas_ptr_enumerator_move(*this);
    return *this;
}

#pragma mark - index

template <typename T>
fast_each<T, enable_if_integral_t<T>>::fast_each(T const end) : fast_each(0, end) {
}

template <typename T>
fast_each<T, enable_if_integral_t<T>>::fast_each(T const start, T const end)
    : _end(start > end ? start : end), _index(start), _next(start) {
}

template <typename T>
fast_each<T> make_fast_each(T const end) {
    return fast_each<T>(end);
}

template <typename T>
fast_each<T> make_fast_each(T const start, T const end) {
    return fast_each<T>(start, end);
}

template <typename T>
fast_each<T> make_fast_each(T ptr, std::size_t const length) {
    return fast_each<T>(ptr, length);
}

#pragma mark - pointer

template <typename T>
fast_each<T, enable_if_pointer_t<T>>::fast_each(T ptr, std::size_t const length)
    : _ptr(ptr), _top_ptr(ptr), _ptr_ptr(&_ptr), _index(0), length(length) {
}
}
