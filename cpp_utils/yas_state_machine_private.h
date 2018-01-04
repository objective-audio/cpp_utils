//
//  yas_state_machine_private.h
//

#pragma once

namespace yas {
template <typename State, typename Method, typename Return>
void state_machine<State, Method, Return>::changer::change(State const &key) const {
    if (auto machine = weak_machine.lock()) {
        machine.change_state(key);
    }
}

template <typename State, typename Method, typename Return>
State const &state_machine<State, Method, Return>::changer::current() const {
    if (auto machine = weak_machine.lock()) {
        return machine.current_state();
    }

    throw std::runtime_error("state_machine lock failed.");
}

template <typename State, typename Method, typename Return>
struct state_machine<State, Method, Return>::impl : base::impl {
    std::unordered_map<State, entered_handler_f> handlers;
    changer changer;
    State current;

    void prepare(state_machine &machine) {
        this->changer.weak_machine = to_weak(machine);
    }

    void register_state(State const &key, entered_handler_f &&handler) {
        if (this->handlers.count(key) > 0) {
            throw std::invalid_argument("key is already exists.");
        }

        this->handlers.emplace(key, std::move(handler));
    }

    void change_state(State const &state) {
        auto &handlers = this->handlers;
        if (handlers.count(state) > 0) {
            this->current = state;
            handlers.at(state)(this->changer);
        } else {
            throw std::invalid_argument("handler not found.");
        }
    }
};

template <typename State, typename Method, typename Return>
state_machine<State, Method, Return>::state_machine() : base(std::make_shared<impl>()) {
    impl_ptr<impl>()->prepare(*this);
}

template <typename State, typename Method, typename Return>
state_machine<State, Method, Return>::state_machine(State initial,
                                                    std::unordered_map<State, entered_handler_f> handlers)
    : base(std::make_shared<impl>()) {
    auto imp = impl_ptr<impl>();
    imp->prepare(*this);
    imp->handlers = std::move(handlers);
    imp->change_state(std::move(initial));
}

template <typename State, typename Method, typename Return>
state_machine<State, Method, Return>::state_machine(std::nullptr_t) : base(nullptr) {
}

template <typename State, typename Method, typename Return>
void state_machine<State, Method, Return>::register_state(State const &state, entered_handler_f handler) {
    impl_ptr<impl>()->register_state(state, std::move(handler));
}

template <typename State, typename Method, typename Return>
void state_machine<State, Method, Return>::change_state(State const &state) {
    impl_ptr<impl>()->change_state(state);
}

template <typename State, typename Method, typename Return>
State const &state_machine<State, Method, Return>::current_state() const {
    return impl_ptr<impl>()->current;
}

template <typename State, typename Method, typename Return>
state_machine<State, Method, Return> make_state_machine(
    State initial, typename state_machine<State, Method, Return>::entered_handlers_t handlers) {
    return state_machine<State, Method, Return>{std::move(initial), std::move(handlers)};
}
}
