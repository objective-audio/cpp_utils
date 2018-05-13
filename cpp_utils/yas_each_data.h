//
//  yas_each_data.h
//

#pragma once

#include <cstddef>
#include <vector>

namespace yas {
template <typename T>
struct each_data {
    std::size_t frm_idx;
    std::size_t ptr_idx;
    std::size_t elm_idx;

    each_data(T *const *const ptrs, std::size_t const frame_length, std::size_t const ptr_count,
              std::size_t const ptr_stride);

    std::size_t _end_frm_idx;
    std::size_t _end_ptr_idx;
    std::size_t _end_elm_idx;

    std::size_t _next_frm_idx;
    std::size_t _next_ptr_idx;
    std::size_t _next_elm_idx;

    std::vector<T *> _vecs;
    T **_ptrs;
};

template <typename T>
struct const_each_data {
    std::size_t frm_idx;
    std::size_t ptr_idx;
    std::size_t elm_idx;

    const_each_data(T const *const *const ptrs, std::size_t const frame_length, std::size_t const ptr_count,
                    std::size_t const ptr_stride);

    std::size_t _end_frm_idx;
    std::size_t _end_ptr_idx;
    std::size_t _end_elm_idx;

    std::size_t _next_frm_idx;
    std::size_t _next_ptr_idx;
    std::size_t _next_elm_idx;

    std::vector<T const *> _vecs;
    T const **_ptrs;
};

template <typename T>
each_data<T> make_each_data(T *const *const ptrs, std::size_t const frame_length, std::size_t const ptr_count,
                            std::size_t const stride);

template <typename T>
const_each_data<T> make_each_data(T const *const *const ptrs, std::size_t const frame_length,
                                  std::size_t const ptr_count, std::size_t const stride);
}  // namespace yas

#define yas_each_data_stop(__v)                   \
    do {                                          \
        (__v)._next_frm_idx = (__v)._end_frm_idx; \
        (__v)._next_ptr_idx = (__v)._end_ptr_idx; \
        (__v)._next_elm_idx = (__v)._end_elm_idx; \
    } while (0)

#define yas_each_data_index(__v) \
    ((__v).frm_idx * ((__v)._end_elm_idx * (__v)._end_ptr_idx) + (__v).ptr_idx * (__v)._end_elm_idx + (__v).elm_idx)

#define yas_each_data_next(__v)                                                                                   \
    (((__v)._next_frm_idx < (__v)._end_frm_idx || (__v)._next_ptr_idx < (__v)._end_ptr_idx ||                     \
      (__v)._next_elm_idx < (__v)._end_elm_idx) &&                                                                \
     !((((__v).elm_idx = (__v)._next_elm_idx++) >= (__v)._end_elm_idx) && !((__v).elm_idx = 0) &&                 \
       ((__v)._next_elm_idx = 1) && ((__v)._next_ptr_idx = (__v)._next_ptr_idx == 0 ? 1 : (__v)._next_ptr_idx) && \
       (((__v).ptr_idx = (__v)._next_ptr_idx++) >= (__v)._end_ptr_idx) && !((__v).ptr_idx = 0) &&                 \
       ((__v)._next_ptr_idx = 1) && ((__v)._next_frm_idx = (__v)._next_frm_idx == 0 ? 1 : (__v)._next_frm_idx) && \
       (((__v).frm_idx = (__v)._next_frm_idx++) >= (__v)._end_frm_idx)))

#define yas_each_data_next_frame(__v)                                                                  \
    (((__v)._next_frm_idx < (__v)._end_frm_idx || (__v)._next_ptr_idx < (__v)._end_ptr_idx ||          \
      (__v)._next_elm_idx < (__v)._end_elm_idx) &&                                                     \
     (((__v).elm_idx < (__v)._end_elm_idx) || (!((__v).elm_idx = 0) && !((__v)._next_elm_idx = 0))) && \
     (((__v).ptr_idx < (__v)._end_ptr_idx) || (!((__v).ptr_idx = 0) && !((__v)._next_ptr_idx = 0))) && \
     (((__v).frm_idx = (__v)._next_frm_idx++) < (__v)._end_frm_idx))

#define yas_each_data_next_ch(__v)                                                                           \
    (((__v)._next_frm_idx < (__v)._end_frm_idx || (__v)._next_ptr_idx < (__v)._end_ptr_idx ||                \
      (__v)._next_elm_idx < (__v)._end_elm_idx) &&                                                           \
     !((((__v).elm_idx = (__v)._next_elm_idx++) >= (__v)._end_elm_idx) &&                                    \
       (((__v).ptr_idx + 1 >= (__v)._end_ptr_idx) || (!((__v).elm_idx = 0) && ((__v)._next_elm_idx = 1))) && \
       (((__v)._next_ptr_idx = (__v)._next_ptr_idx == 0 ? 1 : (__v)._next_ptr_idx)) &&                       \
       (((__v).ptr_idx = (__v)._next_ptr_idx++) >= (__v)._end_ptr_idx)))

#define yas_each_data_value(__v) ((__v)._ptrs[(__v).ptr_idx][(__v).frm_idx * (__v)._end_elm_idx + (__v).elm_idx])

#define yas_each_data_ptr(__v) (&yas_each_data_value(__v))

#include "yas_each_data_private.h"
