//
//  yas_each_data_private.h
//

#pragma once

namespace yas {
template <typename T>
each_data<T>::each_data(T **ptrs, std::size_t const frame_length, std::size_t const ptr_count,
                        std::size_t const ptr_stride)
    : frm_idx(0),
      ptr_idx(0),
      ch_idx(0),
      _ptrs(ptrs),
      _end_frm_idx(frame_length),
      _end_ptr_idx(ptr_count),
      _end_ch_idx(ptr_stride),
      _next_frm_idx(0),
      _next_ptr_idx(0),
      _next_ch_idx(0) {
}
}
