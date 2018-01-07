//
//  yas_state.h
//

#pragma once

#include "yas_base.h"
#include <functional>
#include <unordered_map>
#include <string>
#include "yas_any.h"

namespace yas {
template <typename State = std::string, typename Method = std::string>
class state_machine : public base {
    struct impl;

   public:
    struct context {
        context(state_machine, any const &);

        any const value;

        void change(State const &) const;
        State const &current() const;

       private:
        weak<state_machine> _weak_machine;
    };

    using entered_handler_f = std::function<void(context const &)>;
    using method_handler_f = std::function<any(context const &)>;
    using unreturned_handler_f = std::function<void(context const &)>;

    state_machine();
    state_machine(std::nullptr_t);

    void register_entered(State const &, entered_handler_f);
    void register_returned(State const &, Method const &, method_handler_f);
    void register_unreturned(State const &, Method const &, unreturned_handler_f);

    void change(State const &);
    void change(State const &, any const &);
    any perform(Method const &);
    any perform(Method const &, any const &);

    State const &current_state() const;
};
}

#include "yas_state_machine_private.h"
