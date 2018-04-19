//
//  yas_flow_graph.h
//

#pragma once

#include "yas_flow.h"
#include <experimental/optional>

namespace yas::flow {
template <typename State, typename Signal>
struct graph : base {
    class impl;
    
#warning todo implに隠す？
    struct next {
        State state;
        std::experimental::optional<Signal> signal = std::experimental::nullopt;
    };

    graph(State);
    graph(std::nullptr_t);

    State const &state() const;

    void add_break_state(State, std::function<State(Signal)>);
    void add_continue_state(State, std::function<State(Signal)>);

    void send_signal(Signal const &);
};
}

#include "yas_flow_graph_private.h"
