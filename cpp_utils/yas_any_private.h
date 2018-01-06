//
//  yas_any_private.h
//

#pragma once

namespace yas {
struct any::impl_base {
    virtual std::type_info const &type() const = 0;
};

template <typename T>
struct any::impl : impl_base {
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
T const &any::get() const {
    if (auto ip = std::dynamic_pointer_cast<impl<T>>(this->_impl_ptr)) {
        return ip->_value;
    }

    static const T _default{};
    return _default;
}

template <typename T>
struct any_factory : any {
    any_factory(T const &val) : any(std::make_shared<impl<T>>(val)) {
    }

    any_factory(T &&val) : any(std::make_shared<impl<T>>(std::move(val))) {
    }
};

template <typename T>
any make_any(T const &val) {
    any_factory<T> factory{val};
    return factory;
}

template <typename T>
any make_any(T &&val) {
    any_factory<T> factory{std::move(val)};
    return factory;
}
}
