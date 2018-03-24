//
//  yas_data.h
//

#pragma once

#include <vector>

namespace yas {
template <typename T>
struct data {
    T *const ptr;
    std::size_t const length;
};

template <typename T>
struct const_data {
    T const *const ptr;
    std::size_t const length;
};

template <typename T>
data<T> make_data(T *ptr, std::size_t length);

template <typename T>
data<T> make_data(std::vector<T> &);

template <typename T>
const_data<T> make_const_data(T const *ptr, std::size_t length);

template <typename T>
const_data<T> make_const_data(std::vector<T> const &);

template <typename T>
struct data_copy {
    const_data<T> src_data;
    data<T> dst_data;
    std::size_t src_begin_idx = 0;
    std::size_t dst_begin_idx = 0;
    std::size_t length;

    void copy();
};
}

#include "yas_data_private.h"
