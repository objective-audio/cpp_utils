//
//  yas_fast_each.h
//

#pragma once

#include <vector>
#include <string>

namespace yas {
template <typename T>
using enable_if_integral_t = typename std::enable_if_t<std::is_integral<T>::value>;
template <typename T>
using enable_if_pointer_t = typename std::enable_if_t<std::is_pointer<T>::value>;

template <typename T>
struct ptr_enumerator {
    using index_t = uint32_t;
    using length_t = uint32_t;

    ptr_enumerator(T *, length_t const);
    explicit ptr_enumerator(std::vector<T> &);

    T const *const *ptr_ptr() const;
    T *const *ptr_ptr();
    index_t const *index_ptr() const;

    bool has_value() const;
    T const &value() const;
    T &value();
    void set_value(T const &);
    void set_value(T &&);

    index_t index() const;
    void set_index(uint32_t const);

    void move();
    void stop();
    void reset();

    ptr_enumerator &operator++();

    T *_ptr;
    T *_top_ptr;
    T **_ptr_ptr;
    index_t _index;
    length_t const length;
};

template <typename T, typename Enable = void>
class fast_each;

template <typename T>
struct fast_each<T, enable_if_integral_t<T>> {
    fast_each(T const end);
    fast_each(T const start, T const end);

    T _end;
    T _index;
    T _next;
};

template <typename T>
struct fast_each<T, enable_if_pointer_t<T>> {
    fast_each(T, std::size_t const length);

    T _ptr;
    T _top_ptr;
    T *_ptr_ptr;
    std::size_t _index;
    std::size_t const length;
};

template <typename T>
fast_each<T> make_fast_each(T const end);

template <typename T>
fast_each<T> make_fast_each(T const start, T const end);

template <typename T>
fast_each<T> make_fast_each(T ptr, std::size_t const length);
}

#define yas_ptr_enumerator_move(__v)      \
    if (++(__v)._index >= (__v).length) { \
        (__v)._ptr = nullptr;             \
    } else {                              \
        ++(__v)._ptr;                     \
    }

#define yas_ptr_enumerator_stop(__v) \
    (__v)._ptr = nullptr;            \
    (__v)._index = (__v).length;

#define yas_ptr_enumerator_reset(__v) \
    (__v)._index = 0;                 \
    (__v)._ptr = (__v)._top_ptr;

#define yas_ptr_enumerator_value(__v) (*(__v)._ptr)
#define yas_ptr_enumerator_index(__v) ((__v)._index)
#define yas_ptr_enumerator_has_value(__v) ((__v)._ptr != nullptr)

#define yas_fast_each_stop(__v) \
    { (__v)._next = (__v)._end; }
#define yas_fast_each_index(__v) (__v)._index
#define yas_fast_each_next(__v) (((__v)._index = (__v)._next++) < (__v)._end)

#include "yas_fast_each_private.h"
