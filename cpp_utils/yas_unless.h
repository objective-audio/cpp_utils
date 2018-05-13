//
//  yas_unless.h
//

#pragma once

#include <ios>

namespace yas {
namespace internal {
    template <typename T>
    struct unless {
        explicit unless(T &&value) : value(std::move(value)) {
        }

        explicit operator bool() const {
            return !value;
        }

        T value;
    };
}  // namespace internal

template <typename T>
internal::unless<T> unless(T &&value) {
    return internal::unless<T>{std::move(value)};
}
}  // namespace yas
