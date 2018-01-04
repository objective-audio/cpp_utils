//
//  yas_state_machine_private.h
//

#pragma once

namespace yas {
template <typename S, typename M, typename R>
void state_machine<S, M, R>::changer::change(S const &key) const {
    if (auto machine = weak_machine.lock()) {
        machine.change_state(key);
    }
}

template <typename S, typename M, typename R>
S const &state_machine<S, M, R>::changer::current() const {
    if (auto machine = weak_machine.lock()) {
        return machine.current_state();
    }

    throw std::runtime_error("state_machine lock failed.");
}

template <typename S, typename M, typename R>
struct state_machine<S, M, R>::impl : base::impl {
    std::unordered_map<S, entered_handler_f> handlers;
    changer changer;
    S current;

    void prepare(state_machine &machine) {
        this->changer.weak_machine = to_weak(machine);
    }

    void register_state(S const &key, entered_handler_f &&handler) {
        if (this->handlers.count(key) > 0) {
            throw std::invalid_argument("key is already exists.");
        }

        this->handlers.emplace(key, std::move(handler));
    }

    void change_state(S const &state) {
        auto &handlers = this->handlers;
        if (handlers.count(state) > 0) {
            this->current = state;
            handlers.at(state)(this->changer);
        } else {
            throw std::invalid_argument("handler not found.");
        }
    }
};

template <typename S, typename M, typename R>
state_machine<S, M, R>::state_machine() : base(std::make_shared<impl>()) {
    impl_ptr<impl>()->prepare(*this);
}

template <typename S, typename M, typename R>
state_machine<S, M, R>::state_machine(S initial, std::unordered_map<S, entered_handler_f> handlers)
    : base(std::make_shared<impl>()) {
    auto imp = impl_ptr<impl>();
    imp->prepare(*this);
    imp->handlers = std::move(handlers);
    imp->change_state(std::move(initial));
}

template <typename S, typename M, typename R>
state_machine<S, M, R>::state_machine(std::nullptr_t) : base(nullptr) {
}

template <typename S, typename M, typename R>
void state_machine<S, M, R>::register_state(S const &state, entered_handler_f handler) {
    impl_ptr<impl>()->register_state(state, std::move(handler));
}

template <typename S, typename M, typename R>
void state_machine<S, M, R>::change_state(S const &state) {
    impl_ptr<impl>()->change_state(state);
}

template <typename S, typename M, typename R>
S const &state_machine<S, M, R>::current_state() const {
    return impl_ptr<impl>()->current;
}

template <typename S, typename M, typename R>
state_machine<S, M, R> make_state_machine(S initial, typename state_machine<S, M, R>::entered_handlers_t handlers) {
    return state_machine<S, M, R>{std::move(initial), std::move(handlers)};
}
}
