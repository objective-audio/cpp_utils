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
        
        T const &current() const;
    };

    using handler_f = std::function<void(changer const &)>;
    using handlers_t = std::unordered_map<T, typename state_machine<T>::handler_f>;

    state_machine();
    state_machine(T initial, std::unordered_map<T, handler_f> handlers);
    state_machine(std::nullptr_t);

    void register_state(T key, handler_f handler);

    void change_state(T key);

    T const &current_state() const;
};

template <typename T>
state_machine<T> make_state_machine(T initial, typename state_machine<T>::handlers_t handlers);
}

#include "yas_state_machine_private.h"
