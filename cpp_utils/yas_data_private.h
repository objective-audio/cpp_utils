//
//  yas_data_private.h
//

#pragma once

#include <cpp_utils/yas_fast_each.h>

namespace yas::data_copy_utils {
template <typename T>
void copy(data_copy<T> &data_copy) {
    T const *const src_ptr = data_copy.src_data.ptr;
    T *const dst_ptr = data_copy.dst_data.ptr;
    std::size_t const &src_stride = data_copy.src_data.stride;
    std::size_t const &dst_stride = data_copy.dst_data.stride;

    auto each = make_fast_each(data_copy.length);
    while (yas_each_next(each)) {
        auto const &idx = yas_each_index(each);
        dst_ptr[(data_copy.dst_begin_idx + idx) * dst_stride] = src_ptr[(data_copy.src_begin_idx + idx) * src_stride];
    }
}

template <typename T>
std::size_t copy_cyclical_memcpy(data_copy<T> &data_copy) {
    int const src_length = static_cast<int>(data_copy.src_data.length);
    int const dst_length = static_cast<int>(data_copy.dst_data.length);
    int src_idx = static_cast<int>(data_copy.src_begin_idx);
    int dst_idx = static_cast<int>(data_copy.dst_begin_idx);

    while (src_idx < data_copy.length) {
        int const copy_length = std::min(src_length - src_idx, dst_length - dst_idx);

        T const *const src_ptr = &data_copy.src_data.ptr[src_idx];
        T *const dst_ptr = &data_copy.dst_data.ptr[dst_idx];

        memcpy(dst_ptr, src_ptr, copy_length * sizeof(T));

        dst_idx = (dst_idx + copy_length) % dst_length;
        src_idx = src_idx + copy_length;
    }

    return dst_idx;
}

template <typename T>
std::size_t copy_cyclical(data_copy<T> &data_copy) {
    T const *const src_ptr = data_copy.src_data.ptr;
    T *const dst_ptr = data_copy.dst_data.ptr;
    std::size_t const &src_stride = data_copy.src_data.stride;
    std::size_t const &dst_stride = data_copy.dst_data.stride;
    std::size_t const dst_length = data_copy.dst_data.length;

    auto each = make_fast_each(data_copy.length);
    while (yas_each_next(each)) {
        auto const &idx = yas_each_index(each);
        auto const dst_idx = (data_copy.dst_begin_idx + idx) % dst_length;
        dst_ptr[dst_idx * dst_stride] = src_ptr[(data_copy.src_begin_idx + idx) * src_stride];
    }

    return (data_copy.dst_begin_idx + data_copy.length) % dst_length;
}
}  // namespace yas::data_copy_utils

namespace yas {
template <typename T>
data<T> make_data(T *const ptr, std::size_t const length) {
    return {.ptr = ptr, .length = length};
}

template <typename T>
data<T> make_data(T *const ptr, std::size_t const length, std::size_t const stride) {
    return {.ptr = ptr, .length = length, .stride = stride};
}

template <typename T>
data<T> make_data(std::vector<T> &vec) {
    return {.ptr = vec.data(), .length = vec.size()};
}

template <typename T>
data<T> make_data(std::vector<T> &vec, std::size_t const stride) {
    return {.ptr = vec.data(), .length = vec.size() / stride, .stride = stride};
}

template <typename T>
const_data<T> make_const_data(T const *const ptr, std::size_t const length) {
    return {.ptr = ptr, .length = length};
}

template <typename T>
const_data<T> make_const_data(T const *const ptr, std::size_t const length, std::size_t const stride) {
    return {.ptr = ptr, .length = length, .stride = stride};
}

template <typename T>
const_data<T> make_const_data(std::vector<T> const &vec) {
    return {.ptr = vec.data(), .length = vec.size()};
}

template <typename T>
const_data<T> make_const_data(std::vector<T> const &vec, std::size_t const stride) {
    return {.ptr = vec.data(), .length = vec.size() / stride, .stride = stride};
}

template <typename T>
typename data_copy<T>::result_t data_copy<T>::execute() {
    if (this->length == 0) {
        return result_t{nullptr};
    }

    if (!this->src_data.ptr || !this->dst_data.ptr) {
        return result_t{error::invalid_data};
    }

    if (this->src_data.stride == 0 || this->dst_data.stride == 0) {
        return result_t{error::invalid_data};
    }

    if (this->src_data.length < this->src_begin_idx + this->length ||
        this->dst_data.length < this->dst_begin_idx + this->length) {
        return result_t{error::out_of_range};
    }

    if (this->src_data.stride == 1 && this->dst_data.stride == 1) {
        memcpy(&this->dst_data.ptr[this->dst_begin_idx], &this->src_data.ptr[this->src_begin_idx],
               this->length * sizeof(T));
    } else {
        data_copy_utils::copy(*this);
    }

    return result_t{nullptr};
}

template <typename T>
typename data_copy<T>::cyclical_result_t data_copy<T>::execute_cyclical() {
    if (this->length == 0) {
        return cyclical_result_t{this->dst_begin_idx};
    }

    if (!this->src_data.ptr || !this->dst_data.ptr) {
        return cyclical_result_t{error::invalid_data};
    }

    if (this->src_data.stride == 0 || this->dst_data.stride == 0) {
        return cyclical_result_t{error::invalid_data};
    }

    if (this->src_data.length < this->src_begin_idx + this->length) {
        return cyclical_result_t{error::out_of_range};
    }

    if (this->src_data.stride == 1 && this->dst_data.stride == 1) {
        return cyclical_result_t{data_copy_utils::copy_cyclical_memcpy(*this)};
    } else {
        return cyclical_result_t{data_copy_utils::copy_cyclical(*this)};
    }
}
}  // namespace yas
