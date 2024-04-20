//
//  yas_data.h
//

#pragma once

#include <cpp-utils/yas_result.h>

#include <vector>

namespace yas {
template <typename T>
struct data {
    T *const ptr;
    std::size_t const length = 0;
    std::size_t const stride = 1;
};

template <typename T>
struct const_data {
    T const *const ptr;
    std::size_t const length = 0;
    std::size_t const stride = 1;
};

template <typename T>
data<T> make_data(T *const ptr, std::size_t const length);
template <typename T>
data<T> make_data(T *const ptr, std::size_t const length, std::size_t const stride);

template <typename T>
data<T> make_data(std::vector<T> &);
template <typename T>
data<T> make_data(std::vector<T> &, std::size_t const stride);

template <typename T>
const_data<T> make_const_data(T const *const ptr, std::size_t const length);
template <typename T>
const_data<T> make_const_data(T const *const ptr, std::size_t const length, std::size_t const stride);

template <typename T>
const_data<T> make_const_data(std::vector<T> const &);
template <typename T>
const_data<T> make_const_data(std::vector<T> const &, std::size_t const stride);

template <typename T>
struct data_copy {
    enum class error {
        invalid_data,
        out_of_range,
    };

    using result_t = result<std::nullptr_t, error>;
    using cyclical_result_t = result<std::size_t, error>;  // 成功した場合はdstの次の開始インデックスを返す

    const_data<T> src_data;
    data<T> dst_data;
    std::size_t src_begin_idx = 0;
    std::size_t dst_begin_idx = 0;
    std::size_t length;

    result_t execute();
    cyclical_result_t execute_cyclical();
};
}  // namespace yas

#include "yas_data_private.h"
