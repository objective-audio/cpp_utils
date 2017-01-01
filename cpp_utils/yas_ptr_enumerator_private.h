//
//  yas_ptr_enumerator_private.h
//

#pragma once

namespace yas {
template <typename T>
ptr_enumerator<T>::ptr_enumerator(T *pointer, length_t const length)
    : _ptr(pointer), _top_ptr(pointer), _ptr_ptr(&_ptr), _index(0), length(length) {
}

template <typename T>
T const *const *ptr_enumerator<T>::ptr() const {
    return _ptr_ptr;
}

template <typename T>
T *const *ptr_enumerator<T>::ptr() {
    return _ptr_ptr;
}

template <typename T>
typename ptr_enumerator<T>::index_t const *ptr_enumerator<T>::index() const {
    return &_index;
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
void ptr_enumerator<T>::reset() {
    _index = 0;
    _ptr = _top_ptr;
}

template <typename T>
ptr_enumerator<T> &ptr_enumerator<T>::operator++() {
    yas_ptr_enumerator_move(*this);
    return *this;
}
}
