//
//  yas_state.h
//

#pragma once

#include "yas_base.h"
#include <functional>
#include <unordered_map>
#include <string>

namespace yas {
template <typename State = std::string, typename Method = std::string, typename Return = std::nullptr_t>
class state_machine : public base {
    struct impl;

   public:
    struct changer {
        weak<state_machine> weak_machine;

        void change(State const &) const;

        State const &current() const;
    };

    using entered_handler_f = std::function<void(changer const &)>;
    using entered_handlers_t =
        std::unordered_map<State, typename state_machine<State, Method, Return>::entered_handler_f>;
    using method_handler_f = std::function<void(changer const &)>;
    using returned_handler_f = std::function<Return(changer const &)>;

    state_machine();
    state_machine(State initial, entered_handlers_t handlers);
    state_machine(std::nullptr_t);

    void register_state(State const &, entered_handler_f);
    void register_method(State const &state, Method const &, method_handler_f);
    void register_returned_method(State const &state, Method const &, returned_handler_f);

    void change(State const &state);
    void perform(Method const &method);
    Return perform_returned(Method const &method);

    State const &current_state() const;
};

template <typename State, typename Method, typename Return = std::nullptr_t>
state_machine<State, Method, Return> make_state_machine(
    State initial, typename state_machine<State, Method, Return>::entered_handlers_t handlers);
}

#include "yas_state_machine_private.h"
