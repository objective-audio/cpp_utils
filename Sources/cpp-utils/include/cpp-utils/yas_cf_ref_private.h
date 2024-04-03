//
//  yas_cf_ref_private.h
//

#pragma once

namespace yas {
template <typename T>
cf_ref<T>::cf_ref() : _impl(std::make_shared<cf_ref_impl>()) {
}

template <typename T>
cf_ref<T>::cf_ref(T const obj) : _impl(std::make_shared<cf_ref_impl>(obj)) {
}

template <typename T>
cf_ref<T>::cf_ref(std::nullptr_t) : _impl(std::make_shared<cf_ref_impl>()) {
}

template <typename T>
cf_ref<T> &cf_ref<T>::operator=(T const obj) {
    this->_impl = std::make_shared<cf_ref_impl>(obj);
    return *this;
}

template <typename T>
cf_ref<T>::operator bool() const {
    return this->_impl && this->_impl->object();
}

template <typename T>
void cf_ref<T>::set_object(T const obj) {
    this->_impl->set_object(obj);
}

template <typename T>
void cf_ref<T>::move_object(T const obj) {
    this->_impl->move_object(obj);
}

template <typename T>
T cf_ref<T>::object() const {
    return static_cast<T>(this->_impl->object());
}

template <typename T>
T cf_ref<T>::retained_object() const {
    return static_cast<T>(this->_impl->retained_object());
}

template <typename T>
T cf_ref<T>::autoreleased_object() const {
    return static_cast<T>(this->_impl->autoreleased_object());
}

template <typename T>
cf_ref<T> cf_ref_with_move_object(T const obj) {
    auto ptr = cf_ref<T>{obj};
    CFRelease(obj);
    return ptr;
}
}  // namespace yas
