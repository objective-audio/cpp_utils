//
//  yas_state.h
//

#pragma once

#include "yas_base.h"
#include <functional>
#include <unordered_map>

namespace yas {
template <typename S, typename M = int, typename R = std::nullptr_t>
class state_machine : public base {
    struct impl;

   public:
    struct changer {
        weak<state_machine> weak_machine;

        void change(S const &) const;

        S const &current() const;
    };

    using entered_handler_f = std::function<void(changer const &)>;
    using entered_handlers_t = std::unordered_map<S, typename state_machine<S, M, R>::entered_handler_f>;

    state_machine();
    state_machine(S initial_state, entered_handlers_t handlers);
    state_machine(std::nullptr_t);

    void register_state(S state, entered_handler_f handler);

    void change_state(S state);

    S const &current_state() const;
};

template <typename S, typename M, typename R = std::nullptr_t>
state_machine<S, M, R> make_state_machine(S initial, typename state_machine<S, M, R>::entered_handlers_t handlers);
}

#include "yas_state_machine_private.h"
