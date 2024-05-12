//
//  notifier.h
//

#pragma once

#include "syncable.h"

namespace yas::observing {
template <typename T>
class notifier;

template <typename T>
using notifier_ptr = std::shared_ptr<notifier<T>>;

template <typename T>
struct notifier final {
    void notify(T const &);
    void notify();

    [[nodiscard]] endable observe(typename caller<T>::handler_f &&);
    [[nodiscard]] endable observe(std::size_t const order, typename caller<T>::handler_f &&);

    [[nodiscard]] static notifier_ptr<T> make_shared();

   private:
    caller_ptr<T> _caller = nullptr;

    notifier();
};
}  // namespace yas::observing

#include "notifier_private.h"
