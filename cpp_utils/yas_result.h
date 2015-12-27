//
//  yas_result.h
//

#pragma once

#include <experimental/optional>
#include <memory>
#include <string>

namespace yas {
template <typename T, typename U>
class result {
   public:
    explicit result(const T &value);
    explicit result(const U &error);
    explicit result(T &&value);
    explicit result(U &&error);

    ~result();

    result(const result<T, U> &);
    result(result<T, U> &&);

    result<T, U> &operator=(const result<T, U> &);
    result<T, U> &operator=(result<T, U> &&);

    explicit operator bool() const;

    bool is_success() const;

    const T &value() const;
    T &value();
    const U &error() const;
    U &error();

    std::experimental::optional<T> value_opt() const;
    std::experimental::optional<U> error_opt() const;

   private:
    std::experimental::optional<T> _value;
    std::experimental::optional<U> _error;
};
}

#include "yas_result_private.h"
