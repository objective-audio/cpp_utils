//
//  yas_each_index.h
//

#pragma once

#include <cpp_utils/yas_type_traits.h>

#include <iterator>

namespace yas {
template <typename T>
struct each_index_iterator {
    each_index_iterator(T const index);

    each_index_iterator &operator++();
    each_index_iterator operator++(int);

    T const &operator*() const;

    bool operator==(each_index_iterator const &rhs) const;
    bool operator!=(each_index_iterator const &rhs) const;

   private:
    T _index;
};

template <typename T, typename Enable = void>
class each_index;

template <typename T>
struct each_index<T, enable_if_integral_t<T>> {
    using iterator = each_index_iterator<T>;

    each_index(T const end);
    each_index(T const start, T const end);

    bool operator==(each_index const &rhs) const;
    bool operator!=(each_index const &rhs) const;

    each_index::iterator begin() const;
    each_index::iterator end() const;

   private:
    T _start;
    T _end;
};

template <typename T>
each_index<T> make_each_index(T const end);

template <typename T>
each_index<T> make_each_index(T const start, T const end);
}  // namespace yas

#include <cpp_utils/yas_each_index_private.h>
