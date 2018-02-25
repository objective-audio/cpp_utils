//
//  yas_base.cpp
//

#include "yas_base.h"

using namespace yas;

#pragma mark - base::impl

base::impl::impl() = default;
base::impl::~impl() = default;

bool base::impl::is_equal(std::shared_ptr<impl> const &rhs) const {
    return this->identifier() == rhs->identifier();
}

uintptr_t base::impl::identifier() const {
    return reinterpret_cast<uintptr_t>(this);
}

#pragma mark - base

base::base(std::nullptr_t) : _impl(nullptr) {
}

base::base(std::shared_ptr<base::impl> const &impl) : _impl(impl) {
}

base::base(std::shared_ptr<base::impl> &&impl) : _impl(std::move(impl)) {
}

base::~base() = default;

base::base(base const &) = default;
base::base(base &&) = default;
base &base::operator=(base const &) = default;
base &base::operator=(base &&) = default;

bool base::operator==(base const &rhs) const {
    return _impl && rhs._impl && (_impl == rhs._impl || _impl->is_equal(rhs._impl));
}

bool base::operator!=(base const &rhs) const {
    return !_impl || !rhs._impl || (_impl != rhs._impl && !_impl->is_equal(rhs._impl));
}

bool base::operator==(std::nullptr_t) const {
    return _impl == nullptr;
}

bool base::operator!=(std::nullptr_t) const {
    return _impl != nullptr;
}

bool base::operator<(base const &rhs) const {
    if (_impl && rhs._impl) {
        return _impl < rhs._impl;
    }
    return false;
}

base::operator bool() const {
    return _impl != nullptr;
}

bool base::expired() const {
    return !_impl;
}

uintptr_t base::identifier() const {
    return _impl->identifier();
}

std::shared_ptr<base::impl> &base::impl_ptr() {
    return _impl;
}

void base::set_impl_ptr(std::shared_ptr<impl> const &impl) {
    _impl = impl;
}

void base::set_impl_ptr(std::shared_ptr<impl> &&impl) {
    _impl = std::move(impl);
}

bool yas::is_same(base const &lhs, base const &rhs) {
    return (!lhs && !rhs) || (lhs == rhs);
}
