//
//  yas_state.h
//

#pragma once

#include "yas_base.h"
#include <functional>
#include <unordered_map>

namespace yas {
template <typename T>
class state_machine : public base {
    struct impl;

   public:
    struct changer {
        weak<state_machine> weak_machine;

        void change(T const &key) const;
    };

    using handler_f = std::function<void(changer const &)>;

    state_machine();
    explicit state_machine(T initial, std::unordered_map<T, handler_f> handlers);
    state_machine(std::nullptr_t);

    void register_state(T key, handler_f handler);

    void change_state(T key);

    T const &current_state() const;
};
}

#include "yas_state_machine_private.h"
