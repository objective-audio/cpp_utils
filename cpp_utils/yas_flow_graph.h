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

    flow::node<Signal, Signal, Signal> begin_flow();

    void add_state(State, flow::observer<Signal>);
    
    void send_signal(Signal const &);

    flow::receivable<State> pause_receivable();
};
}

#include "yas_flow_graph_private.h"
