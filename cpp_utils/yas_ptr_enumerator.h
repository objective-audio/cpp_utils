//
//  yas_ptr_enumerator.h
//

#pragma once

#include <vector>
#include <string>
#include <vector>

namespace yas {
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

#include "yas_ptr_enumerator_private.h"
