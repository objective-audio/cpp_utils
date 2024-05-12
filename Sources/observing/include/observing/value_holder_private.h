//
//  value_holder_private.h
//

#pragma once

namespace yas::observing::value {
template <typename T>
holder<T>::holder(T &&value) : _value(std::move(value)) {
}

template <typename T>
void holder<T>::set_value(T &&value) {
    if (this->_value != value) {
        this->_value = std::move(value);
        if (auto const &caller = this->_caller) {
            caller->call(this->_value);
        }
    }
}

template <typename T>
void holder<T>::set_value(T const &value) {
    if (this->_value != value) {
        T copied = value;
        this->set_value(std::move(copied));
    }
}

template <typename T>
T const &holder<T>::value() const {
    return this->_value;
}

template <typename T>
syncable holder<T>::observe(typename caller<T>::handler_f &&handler) {
    return this->observe(0, std::move(handler));
}

template <typename T>
syncable holder<T>::observe(std::size_t const order, typename caller<T>::handler_f &&handler) {
    if (!this->_caller) {
        this->_caller = caller<T>::make_shared();
    }

    return syncable{[this, order, handler = std::move(handler)](bool const sync) mutable {
        if (sync) {
            handler(this->_value);
        }
        return this->_caller->add(order, std::move(handler));
    }};
}

template <typename T>
[[nodiscard]] holder_ptr<T> holder<T>::make_shared(T const &value) {
    T copied = value;
    return make_shared(std::move(copied));
}

template <typename T>
[[nodiscard]] holder_ptr<T> holder<T>::make_shared(T &&value) {
    return std::shared_ptr<holder<T>>(new holder<T>{std::move(value)});
}
}  // namespace yas::observing::value
