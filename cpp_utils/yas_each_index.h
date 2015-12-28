//
//  yas_each_index.h
//

#pragma once

#include <iterator>

namespace yas {
template <typename T>
using enable_if_integral_t = typename std::enable_if_t<std::is_integral<T>::value>;

template <typename T>
class each_index_iterator : public std::iterator<std::input_iterator_tag, T> {
   public:
    each_index_iterator(T const index);

    each_index_iterator &operator++();
    each_index_iterator operator++(int);

    T const &operator*() const;

    bool operator==(const each_index_iterator &rhs) const;
    bool operator!=(const each_index_iterator &rhs) const;

   private:
    T _index;
};

template <typename T, typename Enable = void>
class each_index;

template <typename T>
class each_index<T, enable_if_integral_t<T>> {
   public:
    using iterator = each_index_iterator<T>;

    each_index(T const end);
    each_index(T const start, T const end);

    bool operator==(const each_index &rhs) const;
    bool operator!=(const each_index &rhs) const;

    each_index::iterator begin() const;
    each_index::iterator end() const;

   private:
    T _start;
    T _end;
};
}

#include "yas_each_index_private.h"