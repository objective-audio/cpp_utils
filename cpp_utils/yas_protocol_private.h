//
//  yas_protocol_private.h
//

#pragma once

namespace yas {
template <typename T>
std::shared_ptr<T> protocol::impl_ptr() const {
    return std::static_pointer_cast<T>(_impl);
}
}
