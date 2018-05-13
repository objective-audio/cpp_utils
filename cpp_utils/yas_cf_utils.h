//
//  yas_cf_utils.h
//

#pragma once

#include <CoreFoundation/CoreFoundation.h>
#include <string>
#include <unordered_map>
#include <vector>

namespace yas {
template <typename T>
void set_cf_property(T &_property, T const &value);

template <typename T>
T get_cf_property(T &_property);

std::string to_string(CFStringRef const &cf_string);
CFStringRef to_cf_object(std::string const &string);

// clang-format off
constexpr CFNumberType cf_number_type(float const &) { return kCFNumberFloat32Type; };
constexpr CFNumberType cf_number_type(double const &) { return kCFNumberFloat64Type; };
constexpr CFNumberType cf_number_type(int32_t const &) { return kCFNumberSInt32Type; };
constexpr CFNumberType cf_number_type(int16_t const &) { return kCFNumberSInt16Type; };
// clang-format on

template <typename T>
CFNumberRef to_cf_object(T const &);

template <typename T, typename F>
std::vector<T> to_vector(CFArrayRef const array, F function);
template <typename T>
CFArrayRef to_cf_object(std::vector<T> const &vector);

template <typename K, typename T>
CFDictionaryRef to_cf_object(std::unordered_map<K, T> const &map);

CFStringRef file_type_for_hfs_type_code(OSType const fcc);
OSType hfs_type_code_from_file_type(CFStringRef const cfStr);
}  // namespace yas

#include "yas_cf_utils_private.h"
