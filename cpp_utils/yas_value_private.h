//
//  yas_value_private.h
//

#pragma once

namespace yas {
struct value::impl_base {
    virtual std::type_info const &type() const = 0;
};

template <typename T>
struct value::impl : impl_base {
    T _value;

    impl(T const &val) : _value(val) {
    }

    impl(T &&val) : _value(std::move(val)) {
    }

    std::type_info const &type() const override {
        return typeid(T);
    }
};

template <typename T>
T const &value::get() const {
    if (auto ip = std::dynamic_pointer_cast<impl<T>>(this->_impl_ptr)) {
        return ip->_value;
    }

    static const T _default{};
    return _default;
}

template <typename T>
struct value_factory : value {
    value_factory(T const &val) : value(std::make_shared<impl<T>>(val)) {
    }

    value_factory(T &&val) : value(std::make_shared<impl<T>>(std::move(val))) {
    }
};

template <typename T>
value make_value(T const &val) {
    value_factory<T> factory{val};
    return factory;
}

template <typename T>
value make_value(T &&val) {
    value_factory<T> factory{std::move(val)};
    return factory;
}
}
