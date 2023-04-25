//
//  yas_data.cpp
//

#include "yas_data.h"

#define ACCELERATE_NEW_LAPACK

#include <Accelerate/Accelerate.h>

using namespace yas;

namespace yas::data_copy_utils {
template <>
void copy(data_copy<float> &data_copy) {
    int const src_stride = static_cast<int>(data_copy.src_data.stride);
    int const dst_stride = static_cast<int>(data_copy.dst_data.stride);
    float const *const src_ptr = &data_copy.src_data.ptr[data_copy.src_begin_idx * src_stride];
    float *const dst_ptr = &data_copy.dst_data.ptr[data_copy.dst_begin_idx * dst_stride];

    cblas_scopy(static_cast<int>(data_copy.length), src_ptr, src_stride, dst_ptr, dst_stride);
}

template <>
void copy(data_copy<double> &data_copy) {
    int const src_stride = static_cast<int>(data_copy.src_data.stride);
    int const dst_stride = static_cast<int>(data_copy.dst_data.stride);
    double const *const src_ptr = &data_copy.src_data.ptr[data_copy.src_begin_idx * src_stride];
    double *const dst_ptr = &data_copy.dst_data.ptr[data_copy.dst_begin_idx * dst_stride];

    cblas_dcopy(static_cast<int>(data_copy.length), src_ptr, src_stride, dst_ptr, dst_stride);
}

template <>
std::size_t copy_cyclical(data_copy<float> &data_copy) {
    int const &src_stride = static_cast<int>(data_copy.src_data.stride);
    int const &dst_stride = static_cast<int>(data_copy.dst_data.stride);
    int const src_length = static_cast<int>(data_copy.src_data.length);
    int const dst_length = static_cast<int>(data_copy.dst_data.length);
    int src_idx = static_cast<int>(data_copy.src_begin_idx);
    int dst_idx = static_cast<int>(data_copy.dst_begin_idx);
    int src_end_idx = static_cast<int>(src_idx + data_copy.length);

    while (src_idx < src_end_idx) {
        int const copy_length = std::min(src_length - src_idx, dst_length - dst_idx);

        float const *const src_ptr = &data_copy.src_data.ptr[src_idx * src_stride];
        float *const dst_ptr = &data_copy.dst_data.ptr[dst_idx * dst_stride];

        cblas_scopy(copy_length, src_ptr, src_stride, dst_ptr, dst_stride);

        dst_idx = (dst_idx + copy_length) % dst_length;
        src_idx = src_idx + copy_length;
    }

    return dst_idx;
}

template <>
std::size_t copy_cyclical(data_copy<double> &data_copy) {
    int const &src_stride = static_cast<int>(data_copy.src_data.stride);
    int const &dst_stride = static_cast<int>(data_copy.dst_data.stride);
    int const src_length = static_cast<int>(data_copy.src_data.length);
    int const dst_length = static_cast<int>(data_copy.dst_data.length);
    int src_idx = static_cast<int>(data_copy.src_begin_idx);
    int dst_idx = static_cast<int>(data_copy.dst_begin_idx);
    int src_end_idx = static_cast<int>(src_idx + data_copy.length);

    while (src_idx < src_end_idx) {
        int const copy_length = std::min(src_length - src_idx, dst_length - dst_idx);

        double const *const src_ptr = &data_copy.src_data.ptr[src_idx * src_stride];
        double *const dst_ptr = &data_copy.dst_data.ptr[dst_idx * dst_stride];

        cblas_dcopy(copy_length, src_ptr, src_stride, dst_ptr, dst_stride);

        dst_idx = (dst_idx + copy_length) % dst_length;
        src_idx = src_idx + copy_length;
    }

    return dst_idx;
}
}  // namespace yas::data_copy_utils
