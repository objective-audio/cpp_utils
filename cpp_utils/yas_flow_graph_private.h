//
//  yas_flow_graph_private.h
//

#pragma once

#include <unordered_map>
#include <experimental/optional>

namespace yas {

#pragma mark - flow::graph

template <typename State, typename Signal>
struct flow::graph<State, Signal>::impl : base::impl {
    State state;
    bool is_running = false;
    std::unordered_map<State, flow::sender<Signal>> senders;
    std::unordered_map<State, flow::observer<Signal>> observers;
    flow::receiver<State> pause_receiver = nullptr;
    flow::receiver<State> continue_receiver = nullptr;
    std::experimental::optional<Signal> continue_signal;

    impl(State &&state) : state(std::move(state)) {
    }

    void prepare(flow::graph<State, Signal> &graph) {
        auto weak_graph = to_weak(graph);

        this->pause_receiver = {[weak_graph](State const &state) {
            if (auto graph = weak_graph.lock()) {
                graph.template impl_ptr<impl>()->set_state(state, false);
            }
        }};

        this->continue_receiver = {[weak_graph](State const &state) {
            if (auto graph = weak_graph.lock()) {
                auto imp = graph.template impl_ptr<impl>();
                imp->set_state(state, false);

                if (!imp->continue_signal) {
                    throw std::runtime_error("continue_signal is null.");
                }

                auto signal = std::move(imp->continue_signal);
                imp->continue_signal = std::experimental::nullopt;
                imp->send_signal(*signal, true);
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
void flow::graph<State, Signal>::add_state(State state, flow::sender<Signal> signal, flow::observer<Signal> observer) {
    auto imp = impl_ptr<impl>();
    if (imp->senders.count(state) > 0) {
        throw std::runtime_error("sender state exists.");
    }

    if (imp->observers.count(state) > 0) {
        throw std::runtime_error("observer state exists.");
    }

    imp->senders.emplace(state, std::move(signal));
    imp->observers.emplace(std::move(state), std::move(observer));
}

template <typename State, typename Signal>
void flow::graph<State, Signal>::add_break_state(State state, std::function<State(Signal)> handler) {
    flow::sender<Signal> sender;

    flow::receivable<State> receivable = impl_ptr<impl>()->pause_receiver.receivable();

    auto flow =
        sender.begin_flow()
            .template convert<State>([handler = std::move(handler)](Signal const &signal) { return handler(signal); })
            .end(std::move(receivable));

    this->add_state(std::move(state), std::move(sender), std::move(flow));
}

template <typename State, typename Signal>
void flow::graph<State, Signal>::add_continue_state(State state,
                                                    std::function<State(Signal)> handler) {
    flow::sender<Signal> sender;
    flow::receivable<State> receivable = impl_ptr<impl>()->continue_receiver.receivable();

    auto flow =
        sender.begin_flow()
            .template convert<State>([handler = std::move(handler), weak_graph = to_weak(*this)](Signal const &signal) {
                State state = handler(signal);
                if (auto graph = weak_graph.lock()) {
                    graph.template impl_ptr<impl>()->continue_signal = signal;
                }
                return state;
            })
            .end(std::move(receivable));

    this->add_state(std::move(state), std::move(sender), std::move(flow));
}

template <typename State, typename Signal>
void flow::graph<State, Signal>::send_signal(Signal const &signal) {
    impl_ptr<impl>()->send_signal(signal, false);
}
}
