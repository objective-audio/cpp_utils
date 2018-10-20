//
//  yas_flow_graph_private.h
//

#pragma once

#include <unordered_map>
#include "yas_chaining.h"

namespace yas::flow {
#pragma mark - state

template <typename Waiting, typename Running>
state<Waiting, Running>::state(Waiting waiting) : _waiting(std::move(waiting)) {
}

template <typename Waiting, typename Running>
state<Waiting, Running>::state(Running running) : _running(std::move(running)) {
}

template <typename Waiting, typename Running>
state_kind state<Waiting, Running>::kind() const {
    if (this->_waiting) {
        return state_kind::waiting;
    } else if (this->_running) {
        return state_kind::running;
    } else {
        throw std::runtime_error("");
    }
}

template <typename Waiting, typename Running>
Waiting const &state<Waiting, Running>::waiting() const {
    return *this->_waiting;
}

template <typename Waiting, typename Running>
Running const &state<Waiting, Running>::running() const {
    return *this->_running;
}

#pragma mark - out_base

struct out_impl_base : base::impl {};

template <typename T>
struct out_impl : out_impl_base {
    T value;

    out_impl(T &&value) : value(std::move(value)) {
    }
};

#pragma mark - waiting_out

template <typename Waiting>
waiting_out::waiting_out(flow::wait<Waiting> value)
    : base(std::make_shared<out_impl<flow::wait<Waiting>>>(std::move(value))) {
}

template <typename Running, typename Event>
waiting_out::waiting_out(flow::run<Running, Event> value)
    : base(std::make_shared<out_impl<flow::run<Running, Event>>>(std::move(value))) {
}

waiting_out::waiting_out(flow::stay value) : base(std::make_shared<out_impl<flow::stay>>(std::move(value))) {
}

waiting_out::waiting_out(std::nullptr_t) : base(nullptr) {
}

template <typename Waiting, typename Running, typename Event>
enum waiting_out::kind waiting_out::kind() const {
    if (impl_ptr<out_impl<flow::wait<Waiting>>>()) {
        return kind::wait;
    } else if (impl_ptr<out_impl<flow::run<Running, Event>>>()) {
        return kind::run;
    } else if (impl_ptr<out_impl<flow::stay>>()) {
        return kind::stay;
    } else {
        throw std::runtime_error("");
    }
}

template <typename Waiting>
wait<Waiting> waiting_out::wait() const {
    return impl_ptr<out_impl<flow::wait<Waiting>>>()->value;
}

template <typename Running, typename Event>
run<Running, Event> waiting_out::run() const {
    return impl_ptr<out_impl<flow::run<Running, Event>>>()->value;
}

#pragma mark - running_out

template <typename Waiting>
running_out::running_out(flow::wait<Waiting> value)
    : base(std::make_shared<out_impl<flow::wait<Waiting>>>(std::move(value))) {
}

template <typename Running, typename Event>
running_out::running_out(flow::run<Running, Event> value)
    : base(std::make_shared<out_impl<flow::run<Running, Event>>>(std::move(value))) {
}

running_out::running_out(std::nullptr_t) : base(nullptr) {
}

template <typename Waiting, typename Running, typename Event>
enum running_out::kind running_out::kind() const {
    if (impl_ptr<out_impl<flow::wait<Waiting>>>()) {
        return kind::wait;
    } else if (impl_ptr<out_impl<flow::run<Running, Event>>>()) {
        return kind::run;
    } else {
        throw std::runtime_error("");
    }
}

template <typename Waiting>
wait<Waiting> running_out::wait() const {
    return impl_ptr<out_impl<flow::wait<Waiting>>>()->value;
}

template <typename Running, typename Event>
run<Running, Event> running_out::run() const {
    return impl_ptr<out_impl<flow::run<Running, Event>>>()->value;
}

#pragma mark - graph

template <typename Waiting, typename Running, typename Event>
struct graph<Waiting, Running, Event>::impl : base::impl {
    state<Waiting, Running> _current;
    std::unordered_map<Waiting, waiting_handler_f> _waiting_handlers;
    std::unordered_map<Running, running_handler_f> _running_handlers;
    bool _performing = false;

    impl(Waiting &&waiting) : _current(std::move(waiting)) {
    }

    void addWaiting(Waiting &&waiting, waiting_handler_f &&handler) {
        if (this->_waiting_handlers.count(waiting) > 0) {
            throw std::invalid_argument("state exists.");
        }

        this->_waiting_handlers.emplace(std::move(waiting), std::move(handler));
    }

    void addRunning(Running &&running, running_handler_f &&handler) {
        if (this->_running_handlers.count(running) > 0) {
            throw std::invalid_argument("state exists.");
        }

        this->_running_handlers.emplace(std::move(running), std::move(handler));
    }

    void run(Event const &event) {
        if (this->_current.kind() != state_kind::waiting) {
            throw std::runtime_error("state is not waiting.");
        }

        this->_run(event);
    }

    bool contains(state<Waiting, Running> const &state) {
        switch (state.kind()) {
            case state_kind::waiting:
                return this->_waiting_handlers.count(state.waiting()) > 0;
            case state_kind::running:
                return this->_running_handlers.count(state.running()) > 0;
        }
    }

   private:
    void _run(Event const &event) {
        if (this->_performing) {
            throw std::runtime_error("performing.");
        }

        switch (this->_current.kind()) {
            case state_kind::waiting: {
                this->_run_waiting(this->_current.waiting(), event);
            } break;
            case state_kind::running: {
                this->_run_running(this->_current.running(), event);
            } break;
        }
    }

    void _run_waiting(Waiting const &state, Event const &event) {
        if (this->_waiting_handlers.count(state) == 0) {
            throw std::invalid_argument("waiting state not found.");
        }

        waiting_handler_f const &handler = this->_waiting_handlers.at(state);

        waiting_signal_t const signal{.event = event};

        this->_performing = true;

        waiting_out const state_out = handler(signal);

        this->_performing = false;

        switch (state_out.template kind<Waiting, Running, Event>()) {
            case waiting_out::kind::wait: {
                this->_current = state_out.wait<Waiting>().waiting;
            } break;

            case waiting_out::kind::run: {
                flow::run<Running, Event> run_out = state_out.run<Running, Event>();
                this->_current = run_out.running;
                this->_run(run_out.event);
            } break;

            case waiting_out::kind::stay:
                break;
        }
    }

    void _run_running(Running const &state, Event const &event) {
        if (this->_running_handlers.count(state) == 0) {
            throw std::invalid_argument("running state not found.");
        }

        running_handler_f const &handler = this->_running_handlers.at(state);

        running_signal_t const signal{.event = event};

        this->_performing = true;

        running_out const state_out = handler(signal);

        this->_performing = false;

        switch (state_out.template kind<Waiting, Running, Event>()) {
            case running_out::kind::wait: {
                this->_current = state_out.wait<Waiting>().waiting;
            } break;

            case running_out::kind::run: {
                flow::run<Running, Event> run_out = state_out.run<Running, Event>();
                this->_current = run_out.running;
                this->_run(run_out.event);
            } break;
        }
    }
};

template <typename Waiting, typename Running, typename Event>
graph<Waiting, Running, Event>::graph(Waiting waiting) : base(std::make_shared<impl>(std::move(waiting))) {
}

template <typename Waiting, typename Running, typename Event>
graph<Waiting, Running, Event>::graph(std::nullptr_t) : base(nullptr) {
}

template <typename Waiting, typename Running, typename Event>
void graph<Waiting, Running, Event>::add_waiting(Waiting waiting, waiting_handler_f handler) {
    impl_ptr<impl>()->addWaiting(std::move(waiting), std::move(handler));
}

template <typename Waiting, typename Running, typename Event>
void graph<Waiting, Running, Event>::add_running(Running running, running_handler_f handler) {
    impl_ptr<impl>()->addRunning(std::move(running), std::move(handler));
}

template <typename Waiting, typename Running, typename Event>
void graph<Waiting, Running, Event>::run(Event const &event) {
    impl_ptr<impl>()->run(event);
}

template <typename Waiting, typename Running, typename Event>
state<Waiting, Running> const &graph<Waiting, Running, Event>::current() const {
    return impl_ptr<impl>()->_current;
}

template <typename Waiting, typename Running, typename Event>
bool graph<Waiting, Running, Event>::contains(state<Waiting, Running> const &state) const {
    return impl_ptr<impl>()->contains(state);
}
}  // namespace yas::flow
