//
//  yas_flex_ptr.cpp
//

#include "yas_flex_ptr.h"

using namespace yas;

flex_ptr::flex_ptr(std::nullptr_t) : v(nullptr) {
}

template <typename T>
flex_ptr::flex_ptr(const T *const p) : v(static_cast<void *>(const_cast<T *>(p))) {
}

template yas::flex_ptr::flex_ptr(const void *);
template yas::flex_ptr::flex_ptr(const float *);
template yas::flex_ptr::flex_ptr(const double *);
template yas::flex_ptr::flex_ptr(const int32_t *);
template yas::flex_ptr::flex_ptr(const uint32_t *);
template yas::flex_ptr::flex_ptr(const int16_t *);
template yas::flex_ptr::flex_ptr(const uint16_t *);
template yas::flex_ptr::flex_ptr(const int8_t *);
template yas::flex_ptr::flex_ptr(const uint8_t *);
