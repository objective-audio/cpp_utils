//
//  value_holder.h
//

#pragma once

#include "syncable.h"

namespace yas::observing::value {
template <typename T>
class holder;

template <typename T>
using holder_ptr = std::shared_ptr<holder<T>>;

template <typename T>
struct holder final {
    void set_value(T &&);
    void set_value(T const &);

    [[nodiscard]] T const &value() const;

    [[nodiscard]] syncable observe(typename caller<T>::handler_f &&);
    [[nodiscard]] syncable observe(std::size_t const order, typename caller<T>::handler_f &&);

    [[nodiscard]] static holder_ptr<T> make_shared(T const &);
    [[nodiscard]] static holder_ptr<T> make_shared(T &&);

   private:
    T _value;
    caller_ptr<T> _caller = nullptr;

    holder(T &&);
};
}  // namespace yas::observing::value

#include "value_holder_private.h"
