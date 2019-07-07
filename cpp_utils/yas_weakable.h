//
//  yas_weakable.h
//

#pragma once

#include <memory>
#include <optional>

namespace yas {
struct weakable_impl {
    virtual ~weakable_impl() = default;
};

template <typename T>
struct weakable {
    virtual std::shared_ptr<weakable_impl> weakable_impl_ptr() const = 0;
};

template <typename T>
struct weak_ref {
    weak_ref(weakable<T> const &weakable) : _impl(weakable.weakable_impl_ptr()) {
    }

    weak_ref(weak_ref const &) = default;
    weak_ref &operator=(weak_ref const &) = default;

    std::optional<T> lock() const {
        if (auto shared = this->_impl.lock()) {
            if (auto casted = std::dynamic_pointer_cast<typename T::impl>(shared)) {
                return std::make_optional<T>(std::move(casted));
            }
        }
        return std::nullopt;
    }

   private:
    std::weak_ptr<weakable_impl> _impl;

    weak_ref(weak_ref &&) = delete;
    weak_ref &operator=(weak_ref &&) = delete;
};

template <typename T>
weak_ref<T> to_weak(weakable<T> const &obj) {
    return weak_ref<T>{obj};
}
}  // namespace yas
