//
//  yas_flow_graph.h
//

#pragma once

#include "yas_flow.h"

namespace yas::flow {
template <typename State, typename Signal>
struct graph : base {
    class impl;

    graph(State);
    graph(std::nullptr_t);

    State const &state() const;

    void add_state(State, std::function<std::pair<State, bool>(Signal const &)>);
    void add_break_state(State, std::function<State(Signal)>);
    void add_continue_state(State, std::function<State(Signal)>);

    void send_signal(Signal const &);
};
}

#include "yas_flow_graph_private.h"
