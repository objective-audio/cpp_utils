//
//  yas_flow_graph_private.h
//

#pragma once

#include <unordered_map>

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

#pragma mark - waiting_out

template <typename Waiting, typename Running, typename Event>
waiting_out<Waiting, Running, Event>::waiting_out(flow::wait<Waiting> value)
    : _impl(std::make_shared<out_impl<flow::wait<Waiting>>>(std::move(value))) {
}

template <typename Waiting, typename Running, typename Event>
waiting_out<Waiting, Running, Event>::waiting_out(flow::run<Running, Event> value)
    : _impl(std::make_shared<out_impl<flow::run<Running, Event>>>(std::move(value))) {
}

template <typename Waiting, typename Running, typename Event>
waiting_out<Waiting, Running, Event>::waiting_out(flow::stay value)
    : _impl(std::make_shared<out_impl<flow::stay>>(std::move(value))) {
}

template <typename Waiting, typename Running, typename Event>
waiting_out<Waiting, Running, Event>::waiting_out(std::nullptr_t) : _impl(nullptr) {
}

template <typename Waiting, typename Running, typename Event>
waiting_out_kind waiting_out<Waiting, Running, Event>::kind() const {
    if (std::dynamic_pointer_cast<out_impl<flow::wait<Waiting>>>(this->_impl)) {
        return waiting_out_kind::wait;
    } else if (std::dynamic_pointer_cast<out_impl<flow::run<Running, Event>>>(this->_impl)) {
        return waiting_out_kind::run;
    } else if (std::dynamic_pointer_cast<out_impl<flow::stay>>(this->_impl)) {
        return waiting_out_kind::stay;
    } else {
        throw std::runtime_error("");
    }
}

template <typename Waiting, typename Running, typename Event>
wait<Waiting> waiting_out<Waiting, Running, Event>::wait() const {
    return std::dynamic_pointer_cast<out_impl<flow::wait<Waiting>>>(this->_impl)->value;
}

template <typename Waiting, typename Running, typename Event>
run<Running, Event> waiting_out<Waiting, Running, Event>::run() const {
    return std::dynamic_pointer_cast<out_impl<flow::run<Running, Event>>>(this->_impl)->value;
}

#pragma mark - running_out

template <typename Waiting>
running_out::running_out(flow::wait<Waiting> value)
    : _impl(std::make_shared<out_impl<flow::wait<Waiting>>>(std::move(value))) {
}

template <typename Running, typename Event>
running_out::running_out(flow::run<Running, Event> value)
    : _impl(std::make_shared<out_impl<flow::run<Running, Event>>>(std::move(value))) {
}

template <typename Waiting, typename Running, typename Event>
enum running_out::kind running_out::kind() const {
    if (std::dynamic_pointer_cast<out_impl<flow::wait<Waiting>>>(this->_impl)) {
        return kind::wait;
    } else if (std::dynamic_pointer_cast<out_impl<flow::run<Running, Event>>>(this->_impl)) {
        return kind::run;
    } else {
        throw std::runtime_error("");
    }
}

template <typename Waiting>
wait<Waiting> running_out::wait() const {
    return std::dynamic_pointer_cast<out_impl<flow::wait<Waiting>>>(this->_impl)->value;
}

template <typename Running, typename Event>
run<Running, Event> running_out::run() const {
    return std::dynamic_pointer_cast<out_impl<flow::run<Running, Event>>>(this->_impl)->value;
}

#pragma mark - graph

template <typename Waiting, typename Running, typename Event>
struct graph<Waiting, Running, Event>::impl {
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

        switch (state_out.kind()) {
            case waiting_out_kind::wait: {
                this->_current = state_out.wait().waiting;
            } break;

            case waiting_out_kind::run: {
                flow::run<Running, Event> run_out = state_out.run();
                this->_current = run_out.running;
                this->_run(run_out.event);
            } break;

            case waiting_out_kind::stay:
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
graph<Waiting, Running, Event>::graph(Waiting &&waiting) : _impl(std::make_unique<impl>(std::move(waiting))) {
}

template <typename Waiting, typename Running, typename Event>
void graph<Waiting, Running, Event>::add_waiting(Waiting waiting, waiting_handler_f handler) {
    this->_impl->addWaiting(std::move(waiting), std::move(handler));
}

template <typename Waiting, typename Running, typename Event>
void graph<Waiting, Running, Event>::add_running(Running running, running_handler_f handler) {
    this->_impl->addRunning(std::move(running), std::move(handler));
}

template <typename Waiting, typename Running, typename Event>
void graph<Waiting, Running, Event>::run(Event const &event) {
    this->_impl->run(event);
}

template <typename Waiting, typename Running, typename Event>
state<Waiting, Running> const &graph<Waiting, Running, Event>::current() const {
    return this->_impl->_current;
}

template <typename Waiting, typename Running, typename Event>
bool graph<Waiting, Running, Event>::contains(state<Waiting, Running> const &state) const {
    return this->_impl->contains(state);
}

template <typename Waiting, typename Running, typename Event>
std::shared_ptr<graph<Waiting, Running, Event>> graph<Waiting, Running, Event>::make_shared(Waiting waiting) {
    return std::shared_ptr<graph<Waiting, Running, Event>>(new graph<Waiting, Running, Event>{std::move(waiting)});
}
}  // namespace yas::flow
