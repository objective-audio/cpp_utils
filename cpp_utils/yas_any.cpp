//
//  yas_any.cpp
//  cpp_utils_test
//
//  Created by Yuki Yasoshima on 2018/01/06.
//

#include "yas_any.h"

using namespace yas;

any::any(impl_base_ptr &&impl) : _impl_ptr(std::move(impl)) {
}

std::type_info const &any::type() const {
    return this->_impl_ptr->type();
}

any const &any::null() {
    static any _null_any = make_any(nullptr);
    return _null_any;
}
