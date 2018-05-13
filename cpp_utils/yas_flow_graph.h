//
//  yas_flow_graph.h
//

#pragma once

#include "yas_flow.h"

namespace yas::flow {
template <typename State>
struct state_out {
    State state;
    bool is_continue;
};

template <typename State>
state_out<State> wait(State state);
template <typename State>
state_out<State> run(State state);

template <typename State, typename Signal>
struct graph : base {
    class impl;

    graph(State);
    graph(std::nullptr_t);

    State const &state() const;

    void add(State, std::function<state_out<State>(Signal const &)>);

    void run(Signal const &);

    bool contains(State const &);
};
}  // namespace yas::flow

#include "yas_flow_graph_private.h"
