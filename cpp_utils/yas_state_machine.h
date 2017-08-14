//
//  yas_state.h
//

#pragma once

#include "yas_base.h"
#include <functional>

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
    state_machine(std::nullptr_t);

    void register_state(T key, handler_f handler);

    void change_state(T key);
};
}

#include "yas_state_machine_private.h"
