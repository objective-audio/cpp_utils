//
//  yas_flow_graph_private.h
//

#pragma once

#include <unordered_map>

namespace yas {
template <typename State, typename Signal>
struct flow::graph<State, Signal>::impl : base::impl {
    std::unordered_map<State, flow::observer<State>> observers;
};

template <typename State, typename Signal>
flow::graph<State, Signal>::graph() : base(std::make_shared<impl>()) {
}

template <typename State, typename Signal>
flow::graph<State, Signal>::graph(std::nullptr_t) : base(nullptr) {
}

template <typename State, typename Signal>
flow::node<State, State, State> flow::graph<State, Signal>::begin_flow() {
    return flow::sender<State>{}.begin_flow();
}

template <typename State, typename Signal>
void flow::graph<State, Signal>::add_state(State state, flow::observer<State> observer) {
    impl_ptr<impl>()->observers.emplace(std::move(state), std::move(observer));
}
}
