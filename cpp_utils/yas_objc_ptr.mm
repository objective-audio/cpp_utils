//
//  yas_objc_ptr.mm
//

#include <Foundation/Foundation.h>
#include "yas_objc_ptr.h"

using namespace yas;

objc_ptr_impl::objc_ptr_impl() : _obj(nil) {
}

objc_ptr_impl::objc_ptr_impl(id const obj) : _obj(obj) {
    yas_retain_or_ignore(_obj);
}

objc_ptr_impl::~objc_ptr_impl() {
    yas_release(_obj);
    _obj = nil;
}

void objc_ptr_impl::set_object(id const obj) {
    std::lock_guard<std::recursive_mutex> lock(_mutex);
    yas_retain_or_ignore(obj);
    yas_release(_obj);
    _obj = obj;
}

void objc_ptr_impl::move_object(id const obj) {
    std::lock_guard<std::recursive_mutex> lock(_mutex);
    yas_release(_obj);
    _obj = obj;
}

id objc_ptr_impl::object() {
    std::lock_guard<std::recursive_mutex> lock(_mutex);
    return _obj;
}

id objc_ptr_impl::retained_object() {
    std::lock_guard<std::recursive_mutex> lock(_mutex);
    return yas_retain(_obj);
}

id objc_ptr_impl::autoreleased_object() {
    std::lock_guard<std::recursive_mutex> lock(_mutex);
    return yas_retain_and_autorelease(_obj);
}