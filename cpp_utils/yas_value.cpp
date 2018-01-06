//
//  yas_value.cpp
//  cpp_utils_test
//
//  Created by Yuki Yasoshima on 2018/01/06.
//

#include "yas_value.h"

using namespace yas;

value::value(impl_base_ptr &&impl) : _impl_ptr(std::move(impl)) {
}

std::type_info const &value::type() const {
    return this->_impl_ptr->type();
}

value const &value::null() {
    static value _null_value = make_value(nullptr);
    return _null_value;
}
