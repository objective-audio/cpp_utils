//
//  yas_objc_ptr_private.h
//

#pragma once

#include <objc_utils/yas_objc_macros.h>

namespace yas {
template <typename T>
objc_ptr<T, enable_if_id_t<T>>::objc_ptr() : _impl(std::make_shared<objc_ptr_impl>()) {
}

template <typename T>
objc_ptr<T, enable_if_id_t<T>>::objc_ptr(T const obj) : _impl(std::make_shared<objc_ptr_impl>(obj)) {
}

template <typename T>
objc_ptr<T, enable_if_id_t<T>>::objc_ptr(std::function<T(void)> const &func) : objc_ptr() {
    @autoreleasepool {
        this->set_object(func());
    }
}

template <typename T>
objc_ptr<T, enable_if_id_t<T>> &objc_ptr<T, enable_if_id_t<T>>::operator=(T const obj) {
    this->_impl = std::make_shared<objc_ptr_impl>(obj);
    return *this;
}

template <typename T>
T objc_ptr<T, enable_if_id_t<T>>::operator*() const noexcept {
    return this->object();
}

template <typename T>
objc_ptr<T, enable_if_id_t<T>>::operator bool() const {
    return this->_impl && this->_impl->object();
}

template <typename T>
void objc_ptr<T, enable_if_id_t<T>>::set_object(T const obj) {
    this->_impl->set_object(obj);
}

template <typename T>
void objc_ptr<T, enable_if_id_t<T>>::move_object(T const obj) {
    this->_impl->move_object(obj);
}

template <typename T>
T objc_ptr<T, enable_if_id_t<T>>::object() const {
    return this->_impl->object();
}

template <typename T>
T objc_ptr<T, enable_if_id_t<T>>::retained_object() const {
    return this->_impl->retained_object();
}

template <typename T>
T objc_ptr<T, enable_if_id_t<T>>::autoreleased_object() const {
    return this->_impl->autoreleased_object();
}

template <typename T>
objc_ptr<T> objc_ptr_with_move_object(T const obj) {
    auto ptr = objc_ptr<T>{obj};
    yas_release(obj);
    return ptr;
}
}  // namespace yas
