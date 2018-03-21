//
//  yas_fast_each.h
//

#pragma once

#include "yas_type_traits.h"

namespace yas {
template <typename T, typename Enable = void>
class fast_each;

template <typename T>
struct fast_each<T, enable_if_integral_t<T>> {
    fast_each(T const end);
    fast_each(T const begin, T const end);

    void reset(T const end);
    void reset(T const begin, T const end);

    T _end;
    T _index;
    T _next;
};

template <typename T>
struct fast_each<T, enable_if_pointer_t<T>> {
    fast_each(T, std::size_t const end);
    fast_each();

    void reset(T, std::size_t const end);

    T _ptr;
    std::size_t _end;
    std::size_t _index;
    std::size_t _next;
};

template <typename T>
fast_each<T> make_fast_each(T const end);

template <typename T>
fast_each<T> make_fast_each(T const begin, T const end);

template <typename T>
fast_each<T> make_fast_each(T ptr, std::size_t const end);
}

#define yas_each_stop(__v)        \
    do {                          \
        (__v)._next = (__v)._end; \
    } while (0)
#define yas_each_index(__v) (__v)._index
#define yas_each_next(__v) (((__v)._index = (__v)._next++) < (__v)._end)
#define yas_each_value(__v) ((__v)._ptr[(__v)._index])
#define yas_each_ptr(__v) (&yas_each_value(__v))

#include "yas_fast_each_private.h"
