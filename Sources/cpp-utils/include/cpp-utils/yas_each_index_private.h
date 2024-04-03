//
//  yas_each_index_private.h
//

#pragma once

namespace yas {

#pragma mark - iterator

template <typename T>
each_index_iterator<T>::each_index_iterator(T const index) : _index(index) {
}

template <typename T>
each_index_iterator<T> &each_index_iterator<T>::operator++() {
    ++_index;
    return *this;
}

template <typename T>
each_index_iterator<T> each_index_iterator<T>::operator++(int) {
    each_index_iterator result = *this;
    ++_index;
    return result;
}

template <typename T>
T const &each_index_iterator<T>::operator*() const {
    return _index;
}

template <typename T>
bool each_index_iterator<T>::operator==(each_index_iterator const &rhs) const {
    return _index == rhs._index;
}

template <typename T>
bool each_index_iterator<T>::operator!=(each_index_iterator const &rhs) const {
    return _index != rhs._index;
}

#pragma mark - each_index

template <typename T>
each_index<T, enable_if_integral_t<T>>::each_index(T const end) : each_index(0, end) {
}

template <typename T>
each_index<T, enable_if_integral_t<T>>::each_index(T const start, T const end)
    : _start(start), _end(start > end ? start : end) {
}

template <typename T>
bool each_index<T, enable_if_integral_t<T>>::operator==(each_index const &rhs) const {
    return _start == rhs._start && _end == rhs._end;
}

template <typename T>
bool each_index<T, enable_if_integral_t<T>>::operator!=(each_index const &rhs) const {
    return _start != rhs._start || _end != rhs._end;
}

template <typename T>
each_index<T, enable_if_integral_t<T>>::each_index::iterator each_index<T, enable_if_integral_t<T>>::begin() const {
    return each_index_iterator<T>(_start);
}

template <typename T>
each_index<T, enable_if_integral_t<T>>::each_index::iterator each_index<T, enable_if_integral_t<T>>::end() const {
    return each_index_iterator<T>(_end);
}

template <typename T>
each_index<T> make_each_index(T const end) {
    return each_index<T>(end);
}

template <typename T>
each_index<T> make_each_index(T const start, T const end) {
    return each_index<T>(start, end);
}
}  // namespace yas
