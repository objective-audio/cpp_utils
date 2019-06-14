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

protocol::operator bool() const {
    return _impl != nullptr;
}

uintptr_t protocol::identifier() const {
    return reinterpret_cast<uintptr_t>(_impl.get());
}
