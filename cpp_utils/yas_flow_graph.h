//
//  yas_flow_graph.h
//

#pragma once

#include "yas_flow.h"

namespace yas::flow {
template <typename State>
struct graph_out {
    State state;
    bool is_continue;
};

template <typename State>
graph_out<State> break_next(State state);
template <typename State>
graph_out<State> continue_next(State state);

template <typename State, typename Signal>
struct graph : base {
    class impl;

    graph(State);
    graph(std::nullptr_t);

    State const &state() const;

    void add_state(State, std::function<graph_out<State>(Signal const &)>);

    void send_signal(Signal const &);
};
}

#include "yas_flow_graph_private.h"
