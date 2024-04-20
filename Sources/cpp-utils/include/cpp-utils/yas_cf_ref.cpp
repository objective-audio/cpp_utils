//
//  yas_cf_ref.cpp
//

#include "yas_cf_ref.h"

using namespace yas;

cf_ref_impl::cf_ref_impl() : _obj(nullptr) {
}

cf_ref_impl::cf_ref_impl(CFTypeRef const obj) : _obj(obj) {
    CFRetain(obj);
}

cf_ref_impl::cf_ref_impl(std::nullptr_t) : _obj(nullptr) {
}

cf_ref_impl::~cf_ref_impl() {
    if (this->_obj) {
        CFRelease(this->_obj);
        this->_obj = nullptr;
    }
}

void cf_ref_impl::set_object(CFTypeRef const obj) {
    std::lock_guard<std::recursive_mutex> lock(this->_mutex);
    if (obj) {
        CFRetain(obj);
    }

    if (this->_obj) {
        CFRelease(this->_obj);
    }

    this->_obj = obj;
}

void cf_ref_impl::move_object(CFTypeRef const obj) {
    std::lock_guard<std::recursive_mutex> lock(this->_mutex);

    if (this->_obj) {
        CFRelease(this->_obj);
    }

    this->_obj = obj;
}

CFTypeRef cf_ref_impl::object() {
    std::lock_guard<std::recursive_mutex> lock(this->_mutex);
    return this->_obj;
}

CFTypeRef cf_ref_impl::retained_object() {
    std::lock_guard<std::recursive_mutex> lock(this->_mutex);
    if (this->_obj) {
        return CFRetain(this->_obj);
    }
    return nullptr;
}

CFTypeRef cf_ref_impl::autoreleased_object() {
    std::lock_guard<std::recursive_mutex> lock(this->_mutex);
    if (this->_obj) {
        return CFAutorelease(CFRetain(this->_obj));
    }
    return nullptr;
}
