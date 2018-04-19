//
//  yas_flow_graph_private.h
//

#pragma once

#include <unordered_map>
#include <experimental/optional>

namespace yas::flow {
template <typename State, typename Signal>
struct graph_next {
    State state;
    std::experimental::optional<Signal> signal = std::experimental::nullopt;
};
}

namespace yas {

#pragma mark - flow::graph

template <typename State, typename Signal>
struct flow::graph<State, Signal>::impl : base::impl, receivable<graph_next<State, Signal>>::impl {
    State state;
    bool is_running = false;
    std::unordered_map<State, flow::sender<Signal>> senders;
    std::unordered_map<State, flow::observer<Signal>> observers;
    std::experimental::optional<Signal> continue_signal;

    impl(State &&state) : state(std::move(state)) {
    }

    void add_state(State state, flow::sender<Signal> sender, flow::observer<Signal> observer) {
    }

    void add_state(flow::graph<State, Signal> &graph, State &&state,
                   std::function<std::pair<State, bool>(Signal const &)> &&handler) {
        if (this->senders.count(state) > 0) {
            throw std::runtime_error("sender state exists.");
        }

        if (this->observers.count(state) > 0) {
            throw std::runtime_error("observer state exists.");
        }

        flow::sender<Signal> sender;

        flow::receivable<graph_next<State, Signal>> receivable = flow::receivable<graph_next<State, Signal>>{
            graph.impl_ptr<typename flow::receivable<graph_next<State, Signal>>::impl>()};

        auto observer = sender.begin_flow()
                            .template convert<graph_next<State, Signal>>(
                                [handler = std::move(handler), weak_graph = to_weak(graph)](Signal const &signal) {
                                    std::pair<State, bool> pair = handler(signal);
                                    return graph_next<State, Signal>{
                                        .state = pair.first,
                                        .signal = pair.second ? std::experimental::optional<Signal>(signal) :
                                                                std::experimental::nullopt};
                                })
                            .end(std::move(receivable));

        this->senders.emplace(state, std::move(sender));
        this->observers.emplace(std::move(state), std::move(observer));
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

    void receive_value(graph_next<State, Signal> const &next) override {
        this->set_state(next.state, false);
        if (next.signal) {
            this->send_signal(*next.signal, true);
        }
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
void flow::graph<State, Signal>::add_state(State state, std::function<std::pair<State, bool>(Signal const &)> handler) {
    impl_ptr<impl>()->add_state(*this, std::move(state), std::move(handler));
}

template <typename State, typename Signal>
void flow::graph<State, Signal>::send_signal(Signal const &signal) {
    impl_ptr<impl>()->send_signal(signal, false);
}
}
