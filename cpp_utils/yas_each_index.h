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

    bool operator==(each_index_iterator const &rhs) const;
    bool operator!=(each_index_iterator const &rhs) const;

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

    bool operator==(each_index const &rhs) const;
    bool operator!=(each_index const &rhs) const;

    each_index::iterator begin() const;
    each_index::iterator end() const;

   private:
    T _start;
    T _end;
};

template <typename T, typename Enable = void>
class fast_each;

template <typename T>
class fast_each<T, enable_if_integral_t<T>> {
   public:
    fast_each(T const end);
    fast_each(T const start, T const end);

    T _start;
    T _end;
    T _index;
    T _next;
};

template <typename T>
each_index<T> make_each(T const end);

template <typename T>
each_index<T> make_each(T const start, T const end);

template <typename T>
fast_each<T> make_fast_each(T const end);

template <typename T>
fast_each<T> make_fast_each(T const start, T const end);
}

#define yas_fast_each_stop(__v) \
    { (__v)._next = (__v)._end; }
#define yas_fast_each_index(__v) (__v)._index
#define yas_fast_each_next(__v) (((__v)._index = (__v)._next++) < (__v)._end)

#include "yas_each_index_private.h"
