//
//  yas_flow_graph_private.h
//

#pragma once

#include <unordered_map>

namespace yas {

#pragma mark - flow::graph

template <typename State, typename Signal>
struct flow::graph<State, Signal>::impl : base::impl {
    State state;
    bool is_running = false;
    std::unordered_map<State, flow::sender<Signal>> senders;
    std::unordered_map<State, flow::observer<Signal>> observers;
    flow::receiver<State> pause_receiver = nullptr;

    impl(State &&state) : state(std::move(state)) {
    }

    void prepare(flow::graph<State, Signal> &graph) {
        auto weak_graph = to_weak(graph);

        this->pause_receiver = {[weak_graph](State const &state) {
            if (auto graph = weak_graph.lock()) {
                graph.template impl_ptr<impl>()->set_state(state, false);
            }
        }};
    }

    void send_signal(Signal const &signal, bool is_continue) {
        if (!is_continue && this->is_running) {
            throw std::runtime_error("");
        }

        this->is_running = true;

        auto &sender = this->senders.at(this->state);
        sender.send_value(signal);
    }

    void set_state(State state, bool is_running) {
        this->state = std::move(state);
        this->is_running = is_running;
    }
};

template <typename State, typename Signal>
flow::graph<State, Signal>::graph(State state) : base(std::make_shared<impl>(std::move(state))) {
    impl_ptr<impl>()->prepare(*this);
}

template <typename State, typename Signal>
flow::graph<State, Signal>::graph(std::nullptr_t) : base(nullptr) {
}

template <typename State, typename Signal>
State const &flow::graph<State, Signal>::state() const {
    return impl_ptr<impl>()->state;
}

template <typename State, typename Signal>
flow::node<Signal, Signal, Signal> flow::graph<State, Signal>::begin_flow() {
    return flow::sender<Signal>{}.begin_flow();
}

template <typename State, typename Signal>
void flow::graph<State, Signal>::add_state(State state, flow::observer<Signal> observer) {
    impl_ptr<impl>()->observers.emplace(std::move(state), std::move(observer));
}

template <typename State, typename Signal>
void flow::graph<State, Signal>::send_signal(Signal const &signal) {
    impl_ptr<impl>()->send_signal(signal, false);
}

template <typename State, typename Signal>
flow::receivable<State> flow::graph<State, Signal>::pause_receivable() {
    return impl_ptr<impl>()->pause_receiver.receivable();
}
}
