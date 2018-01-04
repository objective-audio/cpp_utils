//
//  yas_state_machine_private.h
//

#pragma once

namespace yas {
template <typename State, typename Method, typename Return>
void state_machine<State, Method, Return>::changer::change(State const &key) const {
    if (auto machine = weak_machine.lock()) {
        machine.change(key);
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
    std::unordered_map<State, entered_handler_f> entered_handlers;
    std::unordered_map<State, std::unordered_map<Method, method_handler_f>> method_handlers;
    std::unordered_map<State, std::unordered_map<Method, returned_handler_f>> returned_handlers;
    changer changer;
    State current;

    void prepare(state_machine &machine) {
        this->changer.weak_machine = to_weak(machine);
    }

    void register_state(State const &state, entered_handler_f &&handler) {
        if (this->entered_handlers.count(state) > 0) {
            throw std::invalid_argument("key is already exists.");
        }

        this->entered_handlers.emplace(state, std::move(handler));
    }

    void register_method(State const &state, Method const &method, method_handler_f handler) {
        if (this->method_handlers.count(state) == 0) {
            this->method_handlers.emplace(state, std::unordered_map<Method, method_handler_f>());
        }

        auto &handlers = this->method_handlers.at(state);
        if (handlers.count(method) > 0) {
            throw std::invalid_argument("method is already exists.");
        }

        handlers.emplace(method, std::move(handler));
    }

    void register_returned_method(State const &state, Method const &method, returned_handler_f handler) {
        if (this->returned_handlers.count(state) == 0) {
            this->returned_handlers.emplace(state, std::unordered_map<Method, returned_handler_f>());
        }

        auto &handlers = this->returned_handlers.at(state);
        if (handlers.count(method) > 0) {
            throw std::invalid_argument("method is already exists.");
        }

        handlers.emplace(method, std::move(handler));
    }

    void change(State const &state) {
        auto &handlers = this->entered_handlers;
        if (handlers.count(state) > 0) {
            this->current = state;
            handlers.at(state)(this->changer);
        } else {
            throw std::invalid_argument("handler not found.");
        }
    }

    void perform(Method const &method) {
        if (this->method_handlers.count(this->current) == 0) {
            return;
        }

        auto &handlers = this->method_handlers.at(this->current);

        if (handlers.count(method) == 0) {
            return;
        }

        auto &handler = handlers.at(method);

        handler(this->changer);
    }

    Return perform_returned(Method const &method) {
        if (this->returned_handlers.count(this->current) == 0) {
            throw std::runtime_error("handler not found.");
        }

        auto &handlers = this->returned_handlers.at(this->current);

        if (handlers.count(method) == 0) {
            throw std::runtime_error("handler not found.");
        }

        auto &handler = handlers.at(method);

        return handler();
    }
};

template <typename State, typename Method, typename Return>
state_machine<State, Method, Return>::state_machine() : base(std::make_shared<impl>()) {
    impl_ptr<impl>()->prepare(*this);
}

template <typename State, typename Method, typename Return>
state_machine<State, Method, Return>::state_machine(std::nullptr_t) : base(nullptr) {
}

template <typename State, typename Method, typename Return>
void state_machine<State, Method, Return>::register_state(State const &state, entered_handler_f handler) {
    impl_ptr<impl>()->register_state(state, std::move(handler));
}

template <typename State, typename Method, typename Return>
void state_machine<State, Method, Return>::register_method(State const &state, Method const &method,
                                                           method_handler_f handler) {
    impl_ptr<impl>()->register_method(state, method, std::move(handler));
}

template <typename State, typename Method, typename Return>
void state_machine<State, Method, Return>::register_returned_method(State const &state, Method const &method,
                                                                    returned_handler_f handler) {
    impl_ptr<impl>()->register_returned_method(state, method, std::move(handler));
}

template <typename State, typename Method, typename Return>
void state_machine<State, Method, Return>::change(State const &state) {
    impl_ptr<impl>()->change(state);
}

template <typename State, typename Method, typename Return>
void state_machine<State, Method, Return>::perform(Method const &method) {
    impl_ptr<impl>()->perform(method);
}

template <typename State, typename Method, typename Return>
Return state_machine<State, Method, Return>::perform_returned(Method const &method) {
    return impl_ptr<impl>()->perform_returned(method);
}

template <typename State, typename Method, typename Return>
State const &state_machine<State, Method, Return>::current_state() const {
    return impl_ptr<impl>()->current;
}
}
