//
//  notifier_private.h
//

#pragma once

namespace yas::observing {
template <typename T>
notifier<T>::notifier() {
}

template <typename T>
void notifier<T>::notify(T const &value) {
    if (auto const &caller = this->_caller) {
        caller->call(value);
    }
}

template <typename T>
void notifier<T>::notify() {
    if (auto const &caller = this->_caller) {
        caller->call(nullptr);
    }
}

template <typename T>
endable notifier<T>::observe(typename caller<T>::handler_f &&handler) {
    return this->observe(0, std::move(handler));
}

template <typename T>
endable notifier<T>::observe(std::size_t const order, typename caller<T>::handler_f &&handler) {
    if (!this->_caller) {
        this->_caller = caller<T>::make_shared();
    }

    return endable{[this, order, handler = std::move(handler)]() mutable {
        return this->_caller->add(order, std::move(handler));
    }};
}

template <typename T>
notifier_ptr<T> notifier<T>::make_shared() {
    return std::shared_ptr<notifier<T>>(new notifier<T>{});
}
}  // namespace yas::observing
