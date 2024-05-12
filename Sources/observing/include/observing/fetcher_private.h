//
//  fetcher_private.h
//

#pragma once

namespace yas::observing {
template <typename T>
fetcher<T>::fetcher(std::function<std::optional<T>(void)> &&handler) : _fetching_handler(std::move(handler)) {
}

template <typename T>
std::optional<T> fetcher<T>::fetched_value() const {
    return this->_fetching_handler();
}

template <typename T>
void fetcher<T>::push() {
    if (auto const fetched = this->fetched_value(); fetched.has_value()) {
        if (auto const &caller = this->_caller) {
            caller->call(fetched.value());
        }
    }
}

template <typename T>
void fetcher<T>::push(T const &value) {
    if (auto const &caller = this->_caller) {
        caller->call(value);
    }
}

template <typename T>
syncable fetcher<T>::observe(typename caller<T>::handler_f &&handler) {
    return this->observe(0, std::move(handler));
}

template <typename T>
syncable fetcher<T>::observe(std::size_t const order, typename caller<T>::handler_f &&handler) {
    if (!this->_caller) {
        this->_caller = caller<T>::make_shared();
    }

    return syncable{[this, order, handler = std::move(handler)](bool const sync) mutable {
        if (sync) {
            if (auto const fetched = this->fetched_value(); fetched.has_value()) {
                handler(fetched.value());
            }
        }
        return this->_caller->add(order, std::move(handler));
    }};
}

template <typename T>
fetcher_ptr<T> fetcher<T>::make_shared(std::function<std::optional<T>(void)> handler) {
    return fetcher_ptr<T>(new fetcher<T>{std::move(handler)});
}
}  // namespace yas::observing
