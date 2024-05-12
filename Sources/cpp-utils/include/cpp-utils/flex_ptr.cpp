//
//  flex_ptr.cpp
//

#include "flex_ptr.h"

using namespace yas;

flex_ptr::flex_ptr(std::nullptr_t) : v(nullptr) {
}

template <typename T>
flex_ptr::flex_ptr(T const *const p) : v(static_cast<void *>(const_cast<T *>(p))) {
}

template yas::flex_ptr::flex_ptr(void const *);
template yas::flex_ptr::flex_ptr(float const *);
template yas::flex_ptr::flex_ptr(double const *);
template yas::flex_ptr::flex_ptr(int32_t const *);
template yas::flex_ptr::flex_ptr(uint32_t const *);
template yas::flex_ptr::flex_ptr(int16_t const *);
template yas::flex_ptr::flex_ptr(uint16_t const *);
template yas::flex_ptr::flex_ptr(int8_t const *);
template yas::flex_ptr::flex_ptr(uint8_t const *);
