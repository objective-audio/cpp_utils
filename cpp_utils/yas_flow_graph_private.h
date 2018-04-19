//
//  yas_flow_graph_private.h
//

#pragma once

#include <unordered_map>

namespace yas {

#pragma mark - flow::graph

template <typename State, typename Signal>
struct flow::graph<State, Signal>::impl : base::impl, receivable<next>::impl {
    State state;
    bool is_running = false;
    std::unordered_map<State, flow::sender<Signal>> senders;
    std::unordered_map<State, flow::observer<Signal>> observers;
    std::experimental::optional<Signal> continue_signal;

    impl(State &&state) : state(std::move(state)) {
    }

    void add_state(State state, flow::sender<Signal> sender, flow::observer<Signal> observer) {
        if (this->senders.count(state) > 0) {
            throw std::runtime_error("sender state exists.");
        }

        if (this->observers.count(state) > 0) {
            throw std::runtime_error("observer state exists.");
        }

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

    void receive_value(next const &next) override {
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
void flow::graph<State, Signal>::add_break_state(State state, std::function<State(Signal)> handler) {
    flow::sender<Signal> sender;
    auto imp = impl_ptr<impl>();

    flow::receivable<next> receivable = flow::receivable<next>{impl_ptr<typename flow::receivable<next>::impl>()};

    auto flow = sender.begin_flow()
                    .template convert<next>([handler = std::move(handler)](Signal const &signal) {
                        return next{.state = handler(signal)};
                    })
                    .end(std::move(receivable));

    imp->add_state(std::move(state), std::move(sender), std::move(flow));
}

template <typename State, typename Signal>
void flow::graph<State, Signal>::add_continue_state(State state, std::function<State(Signal)> handler) {
    flow::sender<Signal> sender;
    auto imp = impl_ptr<impl>();

    flow::receivable<next> receivable = flow::receivable<next>{impl_ptr<typename flow::receivable<next>::impl>()};

    auto flow = sender.begin_flow()
                    .template convert<next>([handler = std::move(handler), weak_graph = to_weak(*this)](
                        Signal const &signal) { return next{.state = handler(signal), .signal = signal}; })
                    .end(std::move(receivable));

    imp->add_state(std::move(state), std::move(sender), std::move(flow));
}

template <typename State, typename Signal>
void flow::graph<State, Signal>::send_signal(Signal const &signal) {
    impl_ptr<impl>()->send_signal(signal, false);
}
}
