//
//  yas_flow_graph_private.h
//

#pragma once

#include <unordered_map>

namespace yas {

#pragma mark - flow::graph_receiver

template <typename State>
struct flow::graph_receiver<State>::impl : base::impl, flow::receivable<State>::impl {
    void receive_value(State const &) override {
#warning todo
    }
};

template <typename State>
flow::graph_receiver<State>::graph_receiver() : base(std::make_shared<impl>()) {
}

template <typename State>
flow::graph_receiver<State>::graph_receiver(std::nullptr_t) : base(nullptr) {
}

template <typename State>
flow::receivable<State> flow::graph_receiver<State>::receivable() {
    return flow::receivable<State>{impl_ptr<typename flow::receivable<State>::impl>()};
}

#pragma mark - flow::graph

template <typename State, typename Signal>
struct flow::graph<State, Signal>::impl : base::impl {
    State state;
    std::unordered_map<State, flow::observer<Signal>> observers;
    flow::graph_receiver<State> pause_receiver;

    impl(State &&state) : state(std::move(state)) {
    }
};

template <typename State, typename Signal>
flow::graph<State, Signal>::graph(State state) : base(std::make_shared<impl>(std::move(state))) {
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
flow::receivable<State> flow::graph<State, Signal>::pause_receivable() {
    return impl_ptr<impl>()->pause_receiver.receivable();
}
}
