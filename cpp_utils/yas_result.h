//
//  yas_result.h
//

#pragma once

#include <memory>
#include <optional>
#include <string>

namespace yas {
template <typename T, typename U>
class result {
   public:
    explicit result(T const &value);
    explicit result(U const &error);
    explicit result(T &&value);
    explicit result(U &&error);

    ~result();

    result(result<T, U> const &);
    result(result<T, U> &&);

    result<T, U> &operator=(result<T, U> const &);
    result<T, U> &operator=(result<T, U> &&);

    explicit operator bool() const;

    bool is_success() const;
    bool is_error() const;

    T const &value() const;
    T &value();
    U const &error() const;
    U &error();

    std::optional<T> value_opt() const;
    std::optional<U> error_opt() const;

   private:
    std::optional<T> _value;
    std::optional<U> _error;
};

template <typename... Args>
result<std::tuple<Args...>, std::nullptr_t> where(Args &&... args);
}  // namespace yas

#include "yas_result_private.h"
