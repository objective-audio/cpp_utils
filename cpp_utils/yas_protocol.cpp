//
//  yas_protocol.cpp
//

#include "yas_protocol.h"

using namespace yas;

protocol::impl::impl() = default;
protocol::impl::~impl() = default;

protocol::protocol(protocol const &) = default;
protocol::protocol(protocol &&) = default;
protocol &protocol::operator=(protocol const &) = default;
protocol &protocol::operator=(protocol &&) = default;

protocol::protocol(std::shared_ptr<impl> const &impl) : _impl(impl) {
}

protocol::protocol(std::shared_ptr<impl> &&impl) : _impl(std::move(impl)) {
}

protocol::~protocol() = default;

bool protocol::operator==(protocol const &rhs) const {
    return _impl && rhs._impl && (_impl == rhs._impl);
}

bool protocol::operator!=(protocol const &rhs) const {
    return !_impl || !rhs._impl || (_impl != rhs._impl);
}

bool protocol::operator==(std::nullptr_t) const {
    return _impl == nullptr;
}

bool protocol::operator!=(std::nullptr_t) const {
    return _impl != nullptr;
}

bool protocol::operator<(protocol const &rhs) const {
    if (_impl && rhs._impl) {
        return _impl < rhs._impl;
    }
    return false;
}

protocol::operator bool() const {
    return _impl != nullptr;
}

uintptr_t protocol::identifier() const {
    return reinterpret_cast<uintptr_t>(_impl.get());
}

std::shared_ptr<protocol::impl> &protocol::impl_ptr() {
    return _impl;
}

void protocol::set_impl_ptr(std::shared_ptr<impl> const &impl) {
    _impl = impl;
}

void protocol::set_impl_ptr(std::shared_ptr<impl> &&impl) {
    _impl = std::move(impl);
}
