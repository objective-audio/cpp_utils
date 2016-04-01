//
//  yas_objc_ptr_private.h
//

#pragma once

#include "yas_objc_macros.h"

namespace yas {
template <typename T>
objc_ptr<T, enable_if_id_t<T>>::objc_ptr() : super_class(std::make_shared<objc_ptr_impl>()) {
}

template <typename T>
objc_ptr<T, enable_if_id_t<T>>::objc_ptr(T const obj) : super_class(std::make_shared<objc_ptr_impl>(obj)) {
}

template <typename T>
objc_ptr<T, enable_if_id_t<T>> &objc_ptr<T, enable_if_id_t<T>>::operator=(T const obj) {
    set_impl_ptr(std::make_shared<objc_ptr_impl>(obj));
    return *this;
}

template <typename T>
objc_ptr<T, enable_if_id_t<T>>::operator bool() const {
    auto imp_ptr = impl_ptr<objc_ptr_impl>();
    return imp_ptr && imp_ptr->object();
}

template <typename T>
void objc_ptr<T, enable_if_id_t<T>>::set_object(T const obj) {
    impl_ptr<objc_ptr_impl>()->set_object(obj);
}

template <typename T>
void objc_ptr<T, enable_if_id_t<T>>::move_object(T const obj) {
    impl_ptr<objc_ptr_impl>()->move_object(obj);
}

template <typename T>
T objc_ptr<T, enable_if_id_t<T>>::object() const {
    return impl_ptr<objc_ptr_impl>()->object();
}

template <typename T>
T objc_ptr<T, enable_if_id_t<T>>::retained_object() const {
    return impl_ptr<objc_ptr_impl>()->retained_object();
}

template <typename T>
T objc_ptr<T, enable_if_id_t<T>>::autoreleased_object() const {
    return impl_ptr<objc_ptr_impl>()->autoreleased_object();
}

template <typename T>
objc_ptr<T> make_objc_ptr(T const obj) {
    auto ptr = objc_ptr<T>{obj};
    yas_release(obj);
    return ptr;
}

template <typename T>
objc_ptr<T> make_objc_ptr(std::function<T(void)> const &func) {
    objc_ptr<T> objc_obj;
    @autoreleasepool {
        auto obj = func();
        objc_obj.set_object(obj);
    }
    return objc_obj;
}
}
