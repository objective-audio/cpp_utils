//
//  yas_data_private.h
//  cpp_utils_test
//
//  Created by Yuki Yasoshima on 2018/03/24.
//

#pragma once

namespace yas {
template <typename T>
data<T> make_data(T *ptr, std::size_t length) {
    return {.ptr = ptr, .length = length};
}

template <typename T>
data<T> make_data(std::vector<T> &vec) {
    return {.ptr = vec.data(), .length = vec.size()};
}

template <typename T>
const_data<T> make_const_data(T const *ptr, std::size_t length) {
    return {.ptr = ptr, .length = length};
}

template <typename T>
const_data<T> make_const_data(std::vector<T> const &vec) {
    return {.ptr = vec.data(), .length = vec.size()};
}

template <typename T>
void data_copy<T>::copy() {
    if (this->length == 0) {
        return;
    }

    if (!this->src_data.ptr) {
        throw std::invalid_argument("src_data.ptr is null.");
    }

    if (!this->dst_data.ptr) {
        throw std::invalid_argument("dst_data.ptr is null.");
    }

    if (this->src_data.length < this->src_begin_idx + this->length) {
        throw std::out_of_range("src_data out of range.");
    }

    if (this->dst_data.length < this->dst_begin_idx + this->length) {
        throw std::out_of_range("src_data out of range.");
    }

    memcpy(&this->dst_data.ptr[this->dst_begin_idx], &this->src_data.ptr[this->src_begin_idx],
           this->length * sizeof(T));
}
}
