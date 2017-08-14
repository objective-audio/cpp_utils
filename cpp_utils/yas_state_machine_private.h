//
//  yas_state_machine_private.h
//

#pragma once

#include <unordered_map>

namespace yas {
template <typename T>
void state_machine<T>::changer::change(T const &key) const {
    if (auto machine = weak_machine.lock()) {
        machine.change_state(key);
    }
}

template <typename T>
struct state_machine<T>::impl : base::impl {
    std::unordered_map<T, handler_f> handlers;
    changer changer;

    void prepare(state_machine &machine) {
        this->changer.weak_machine = to_weak(machine);
    }

    void register_state(T &&key, handler_f &&handler) {
        if (this->handlers.count(key) > 0) {
            throw std::invalid_argument("key is already exists.");
        }

        this->handlers.emplace(std::move(key), std::move(handler));
    }

    void change_state(T &&key) {
        auto &handlers = this->handlers;
        if (handlers.count(key) > 0) {
            handlers.at(key)(this->changer);
        } else {
            throw std::invalid_argument("handler not found.");
        }
    }
};

template <typename T>
state_machine<T>::state_machine() : base(std::make_shared<impl>()) {
    impl_ptr<impl>()->prepare(*this);
}

template <typename T>
state_machine<T>::state_machine(std::nullptr_t) : base(nullptr) {
}

template <typename T>
void state_machine<T>::register_state(T key, handler_f handler) {
    impl_ptr<impl>()->register_state(std::move(key), std::move(handler));
}

template <typename T>
void state_machine<T>::change_state(T key) {
    impl_ptr<impl>()->change_state(std::move(key));
}
}
