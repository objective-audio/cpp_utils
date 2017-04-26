//
//  yas_each_data_private.h
//

#pragma once

namespace yas {
template <typename T>
each_data<T>::each_data(T *const *const ptrs, std::size_t const frame_length, std::size_t const ptr_count,
                        std::size_t const ptr_stride)
    : frm_idx(0),
      ptr_idx(0),
      ch_idx(0),
      _end_frm_idx(frame_length),
      _end_ptr_idx(ptr_count),
      _end_ch_idx(ptr_stride),
      _next_frm_idx(0),
      _next_ptr_idx(0),
      _next_ch_idx(0),
      _vecs(ptr_count) {
    _ptrs = _vecs.data();
    for (std::size_t i = 0; i < ptr_count; ++i) {
        _ptrs[i] = ptrs[i];
    }
}

template <typename T>
const_each_data<T>::const_each_data(T const *const *const ptrs, std::size_t const frame_length,
                                    std::size_t const ptr_count, std::size_t const ptr_stride)
    : frm_idx(0),
      ptr_idx(0),
      ch_idx(0),
      _end_frm_idx(frame_length),
      _end_ptr_idx(ptr_count),
      _end_ch_idx(ptr_stride),
      _next_frm_idx(0),
      _next_ptr_idx(0),
      _next_ch_idx(0),
      _vecs(ptr_count) {
    _ptrs = _vecs.data();
    for (std::size_t i = 0; i < ptr_count; ++i) {
        _ptrs[i] = ptrs[i];
    }
}

template <typename T>
each_data<T> make_each_data(T *const *const ptrs, std::size_t const frame_length, std::size_t const ptr_count,
                            std::size_t const ptr_stride) {
    return each_data<T>{ptrs, frame_length, ptr_count, ptr_stride};
}

template <typename T>
const_each_data<T> make_each_data(T const *const *const ptrs, std::size_t const frame_length,
                                  std::size_t const ptr_count, std::size_t const ptr_stride) {
    return const_each_data<T>{ptrs, frame_length, ptr_count, ptr_stride};
}
}
