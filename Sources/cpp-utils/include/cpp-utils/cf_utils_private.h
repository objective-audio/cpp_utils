//
//  cf_utils_private.h
//

#pragma once

#include <CoreFoundation/CoreFoundation.h>
#include <cpp-utils/each_index.h>

template <typename T>
void yas::set_cf_property(T &_property, T const &value) {
    if (_property != value) {
        if (_property) {
            CFRelease(_property);
        }

        _property = value;

        if (value) {
            CFRetain(value);
        }
    }
}

template <typename T>
T yas::get_cf_property(T &_property) {
    if (_property) {
        return (T)CFAutorelease(CFRetain(_property));
    }
    return nullptr;
}

template <typename T>
CFNumberRef yas::to_cf_object(T const &value) {
    CFNumberRef number = CFNumberCreate(kCFAllocatorDefault, cf_number_type(value), &value);
    CFAutorelease(number);
    return number;
}

template CFNumberRef yas::to_cf_object(float const &);
template CFNumberRef yas::to_cf_object(double const &);
template CFNumberRef yas::to_cf_object(int32_t const &);
template CFNumberRef yas::to_cf_object(int16_t const &);

template <typename T, typename F>
std::vector<T> yas::to_vector(CFArrayRef const array, F function) {
    CFIndex const count = CFArrayGetCount(array);

    std::vector<T> vector;
    vector.reserve(count);

    for (auto const &idx : yas::make_each_index(count)) {
        vector.emplace_back(function(CFArrayGetValueAtIndex(array, idx)));
    }

    return vector;
}

template <typename T>
CFArrayRef yas::to_cf_object(std::vector<T> const &vector) {
    CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, vector.size(), &kCFTypeArrayCallBacks);

    for (T const &value : vector) {
        CFTypeRef cf_object = yas::to_cf_object(value);
        CFArrayAppendValue(array, cf_object);
    }
    return array;
}

template <typename K, typename T>
CFDictionaryRef yas::to_cf_object(std::unordered_map<K, T> const &map) {
    CFMutableDictionaryRef dictionary = CFDictionaryCreateMutable(
        kCFAllocatorDefault, map.size(), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    for (auto const &pair : map) {
        K const &key = pair.first;
        T const &value = pair.second;
        CFTypeRef const key_object = yas::to_cf_object(key);
        CFTypeRef const value_object = yas::to_cf_object(value);
        CFDictionarySetValue(dictionary, key_object, value_object);
    }
    return dictionary;
}
