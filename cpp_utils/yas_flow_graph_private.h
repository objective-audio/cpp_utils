//
//  yas_flow_graph_private.h
//

#pragma once

#include <unordered_map>
#include "yas_types.h"

namespace yas::flow {
template <typename State>
state_out<State> wait(State state) {
    return state_out<State>{.state = std::move(state)};
}

template <typename State>
state_out<State> run(State state) {
    return state_out<State>{.state = std::move(state), .is_continue = true};
}

template <typename State, typename Signal>
struct graph_next {
    State state;
    opt_t<Signal> signal = nullopt;
};
}  // namespace yas::flow

namespace yas {

#pragma mark - flow::graph

template <typename State, typename Signal>
struct flow::graph<State, Signal>::impl : base::impl {
    State state;
    bool is_running = false;
    flow::receiver<graph_next<State, Signal>> receiver = nullptr;
    std::unordered_map<State, flow::typed_observer<Signal>> observers;

    impl(State &&state) : state(std::move(state)) {
    }

    void prepare(flow::graph<State, Signal> &graph) {
        this->receiver = flow::receiver<graph_next<State, Signal>>(
            [weak_graph = to_weak(graph)](graph_next<State, Signal> const &next) {
                if (flow::graph<State, Signal> graph = weak_graph.lock()) {
                    graph.impl_ptr<impl>()->_receive_value(next);
                }
            });
    }

    void add(flow::graph<State, Signal> &graph, State &&state,
             std::function<state_out<State>(Signal const &)> &&handler) {
        if (this->observers.count(state) > 0) {
            throw std::runtime_error("observer state exists.");
        }

        flow::sender<Signal> sender;

        auto observer =
            sender.begin()
                .map([handler = std::move(handler), weak_graph = to_weak(graph)](Signal const &signal) {
                    state_out<State> state_out = handler(signal);
                    return graph_next<State, Signal>{.state = state_out.state,
                                                     .signal = state_out.is_continue ? opt_t<Signal>(signal) : nullopt};
                })
                .end(this->receiver);

        this->observers.emplace(std::move(state), std::move(observer));
    }

    void run(Signal const &signal) {
        if (this->is_running) {
            throw std::runtime_error("graph is running.");
        }

        this->is_running = true;

        auto &input = this->observers.at(this->state).input();
        input.input_value(signal);
    }

   private:
    void _receive_value(graph_next<State, Signal> const &next) {
        this->state = next.state;
        this->is_running = false;

        if (next.signal) {
            this->run(*next.signal);
        }
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
void flow::graph<State, Signal>::add(State state, std::function<state_out<State>(Signal const &)> handler) {
    impl_ptr<impl>()->add(*this, std::move(state), std::move(handler));
}

template <typename State, typename Signal>
void flow::graph<State, Signal>::run(Signal const &signal) {
    impl_ptr<impl>()->run(signal);
}

template <typename State, typename Signal>
bool flow::graph<State, Signal>::contains(State const &state) {
    return impl_ptr<impl>()->observers.count(state) > 0;
}
}  // namespace yas
