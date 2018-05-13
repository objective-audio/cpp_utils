//
//  yas_state_machine_private.h
//

#pragma once

namespace yas {
template <typename State, typename Method>
state_machine<State, Method>::context::context(state_machine machine, any const &value)
    : _weak_machine(to_weak(machine)), value(value) {
}

template <typename State, typename Method>
void state_machine<State, Method>::context::change(State const &state) const {
    if (auto machine = this->_weak_machine.lock()) {
        machine.change(state);
    }
}

template <typename State, typename Method>
void state_machine<State, Method>::context::change(State const &state, any const &value) const {
    if (auto machine = this->_weak_machine.lock()) {
        machine.change(state, value);
    }
}

template <typename State, typename Method>
State const &state_machine<State, Method>::context::current() const {
    if (auto machine = this->_weak_machine.lock()) {
        return machine.current_state();
    }

    throw std::runtime_error("state_machine lock failed.");
}

template <typename State, typename Method>
struct state_machine<State, Method>::impl : base::impl {
    std::unordered_map<State, entered_handler_f> entered_handlers;
    std::unordered_map<State, std::unordered_map<Method, returned_handler_f>> method_handlers;
    State current;

    impl(State const &state) : current(state) {
    }

    void set_entered(State const &state, entered_handler_f &&handler) {
        if (this->entered_handlers.count(state) > 0) {
            throw std::invalid_argument("key is already exists.");
        }

        this->entered_handlers.emplace(state, std::move(handler));
    }

    void set_returned(State const &state, Method const &method, returned_handler_f handler) {
        if (this->method_handlers.count(state) == 0) {
            this->method_handlers.emplace(state, std::unordered_map<Method, returned_handler_f>());
        }

        auto &handlers = this->method_handlers.at(state);
        if (handlers.count(method) > 0) {
            throw std::invalid_argument("method is already exists.");
        }

        handlers.emplace(method, std::move(handler));
    }

    void change(state_machine &machine, State const &state, any const &value) {
        if (this->current == state) {
            return;
        }

        this->current = state;

        auto &handlers = this->entered_handlers;
        if (handlers.count(state) > 0) {
            handlers.at(state)(context(machine, value));
        }
    }

    any perform(state_machine &machine, Method const &method, any const &value) {
        if (this->method_handlers.count(this->current) == 0) {
            return any::null();
        }

        auto &handlers = this->method_handlers.at(this->current);

        if (handlers.count(method) == 0) {
            return any::null();
        }

        auto &handler = handlers.at(method);

        return handler(context(machine, value));
    }
};

template <typename State, typename Method>
state_machine<State, Method>::state_machine() : base(std::make_shared<impl>(State{})) {
}

template <typename State, typename Method>
state_machine<State, Method>::state_machine(State const &state) : base(std::make_shared<impl>(state)) {
}

template <typename State, typename Method>
state_machine<State, Method>::state_machine(std::nullptr_t) : base(nullptr) {
}

template <typename State, typename Method>
void state_machine<State, Method>::set_entered(State const &state, entered_handler_f handler) {
    impl_ptr<impl>()->set_entered(state, std::move(handler));
}

template <typename State, typename Method>
void state_machine<State, Method>::set_returned(State const &state, Method const &method, returned_handler_f handler) {
    impl_ptr<impl>()->set_returned(state, method, std::move(handler));
}

template <typename State, typename Method>
void state_machine<State, Method>::set_unreturned(State const &state, Method const &method,
                                                  unreturned_handler_f handler) {
    this->set_returned(state, method, [handler](auto const &context) {
        handler(context);
        return any::null();
    });
}

template <typename State, typename Method>
void state_machine<State, Method>::change(State const &state) {
    this->change(state, any::null());
}

template <typename State, typename Method>
void state_machine<State, Method>::change(State const &state, any const &value) {
    impl_ptr<impl>()->change(*this, state, value);
}

template <typename State, typename Method>
any state_machine<State, Method>::perform(Method const &method) {
    return this->perform(method, any::null());
}

template <typename State, typename Method>
any state_machine<State, Method>::perform(Method const &method, any const &value) {
    return impl_ptr<impl>()->perform(*this, method, value);
}

template <typename State, typename Method>
State const &state_machine<State, Method>::current_state() const {
    return impl_ptr<impl>()->current;
}
}  // namespace yas
