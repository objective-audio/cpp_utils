//
//  caller.h
//

#pragma once

#include <map>
#include <vector>

#include "caller_index.hpp"
#include "canceller.h"

namespace yas::observing {
template <typename T>
struct caller;
template <typename T>
using caller_ptr = std::shared_ptr<caller<T>>;

template <typename T>
struct caller {
    using handler_f = std::function<void(T const &)>;

    ~caller();

    [[nodiscard]] canceller_ptr add(handler_f &&);
    [[nodiscard]] canceller_ptr add(std::size_t const order, handler_f &&);
    void call(T const &);

    static caller_ptr<T> make_shared();

   private:
    struct handler_container {
        bool enabled = true;
        handler_f handler;
    };

    struct member {
        std::map<caller_index, handler_container> handlers;
        std::map<uintptr_t, canceller_wptr> cancellers;
        bool calling = false;
    };

    std::shared_ptr<member> const _member;

    caller();
};
}  // namespace yas::observing

#include "caller_private.h"
