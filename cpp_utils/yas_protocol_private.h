//
//  yas_protocol_private.h
//

#pragma once

namespace yas {
template <typename T>
std::shared_ptr<T> protocol::impl_ptr() const {
    return std::static_pointer_cast<T>(_impl);
}

template <typename T>
protocol::weak<T>::weak() : _impl() {
}

template <typename T>
protocol::weak<T>::weak(T const &obj) : _impl(obj.impl_ptr()) {
}

template <typename T>
template <typename U>
protocol::weak<T>::weak(protocol::weak<U> const &wobj) : _impl(wobj.lock().impl_ptr()) {
    static_assert(std::is_base_of<T, U>(), "base class is not T.");
}

template <typename T>
protocol::weak<T>::weak(protocol::weak<T> const &) = default;

template <typename T>
protocol::weak<T>::weak(protocol::weak<T> &&) = default;

template <typename T>
protocol::weak<T> &protocol::weak<T>::operator=(protocol::weak<T> const &) = default;

template <typename T>
protocol::weak<T> &protocol::weak<T>::operator=(protocol::weak<T> &&) = default;

template <typename T>
protocol::weak<T> &protocol::weak<T>::operator=(T const &obj) {
    _impl = obj.impl_ptr();

    return *this;
}

template <typename T>
template <typename U>
protocol::weak<T> &protocol::weak<T>::operator=(protocol::weak<U> const &wobj) {
    static_assert(std::is_base_of<T, U>(), "base class is not T.");

    _impl = wobj.lock().impl_ptr();

    return *this;
}

template <typename T>
protocol::weak<T>::operator bool() const {
    return !_impl.expired();
}

template <typename T>
uintptr_t protocol::weak<T>::identifier() const {
    if (auto impl = _impl.lock()) {
        return reinterpret_cast<uintptr_t>(&*impl);
    }
    return 0;
}

template <typename T>
bool protocol::weak<T>::operator==(weak const &rhs) const {
    if (_impl.expired() || rhs._impl.expired()) {
        return false;
    } else {
        auto impl = _impl.lock();
        auto rhs_impl = rhs._impl.lock();
        return impl && rhs_impl && (impl == rhs_impl || impl->is_equal(rhs_impl));
    }
}

template <typename T>
bool protocol::weak<T>::operator!=(weak const &rhs) const {
    if (_impl.expired() || rhs._impl.expired()) {
        return true;
    } else {
        auto impl = _impl.lock();
        auto rhs_impl = rhs._impl.lock();
        return !impl || !rhs_impl || (impl != rhs_impl && !impl->is_equal(rhs_impl));
    }
}

template <typename T>
T protocol::weak<T>::lock() const {
    T obj{nullptr};
    auto impl = _impl.lock();
    if (impl) {
        obj.set_impl_ptr(impl);
    }
    return obj;
}

template <typename T>
void protocol::weak<T>::lock(std::function<void(T &)> const &func) const {
    if (auto obj = lock()) {
        func(obj);
    }
}

template <typename T>
void protocol::weak<T>::reset() {
    _impl.reset();
}
}  // namespace yas
