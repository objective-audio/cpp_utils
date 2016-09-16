//
//  yas_cf_ref_private.h
//

#pragma once

namespace yas {
template <typename T>
cf_ref<T>::cf_ref() : base(std::make_shared<cf_ref_impl>()) {
}

template <typename T>
cf_ref<T>::cf_ref(T const obj) : base(std::make_shared<cf_ref_impl>(obj)) {
}

template <typename T>
cf_ref<T>::cf_ref(std::nullptr_t) : base(std::make_shared<cf_ref_impl>()) {
}

template <typename T>
cf_ref<T> &cf_ref<T>::operator=(T const obj) {
    set_impl_ptr(std::make_shared<cf_ref_impl>(obj));
    return *this;
}

template <typename T>
cf_ref<T>::operator bool() const {
    auto imp_ptr = impl_ptr<cf_ref_impl>();
    return imp_ptr && imp_ptr->object();
}

template <typename T>
void cf_ref<T>::set_object(T const obj) {
    impl_ptr<cf_ref_impl>()->set_object(obj);
}

template <typename T>
void cf_ref<T>::move_object(T const obj) {
    impl_ptr<cf_ref_impl>()->move_object(obj);
}

template <typename T>
T cf_ref<T>::object() const {
    return static_cast<T>(impl_ptr<cf_ref_impl>()->object());
}

template <typename T>
T cf_ref<T>::retained_object() const {
    return static_cast<T>(impl_ptr<cf_ref_impl>()->retained_object());
}

template <typename T>
T cf_ref<T>::autoreleased_object() const {
    return static_cast<T>(impl_ptr<cf_ref_impl>()->autoreleased_object());
}

template <typename T>
cf_ref<T> make_cf_ref(T const obj) {
    auto ptr = cf_ref<T>{obj};
    CFRelease(obj);
    return ptr;
}
}
