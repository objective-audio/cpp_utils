//
//  yas_flow_graph.h
//

#pragma once

#include "yas_flow.h"

namespace yas::flow {
template <typename State>
struct graph_receiver : base {
    struct impl;

    graph_receiver();
    graph_receiver(std::nullptr_t);

    flow::receivable<State> receivable();
};

template <typename State, typename Signal>
struct graph : base {
    class impl;

    graph(State);
    graph(std::nullptr_t);

    State const &state() const;

    flow::node<Signal, Signal, Signal> begin_flow();
    void add_state(State, flow::observer<Signal>);

    flow::receivable<State> pause_receivable();
};
}

#include "yas_flow_graph_private.h"
