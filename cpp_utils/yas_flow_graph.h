//
//  yas_flow_graph.h
//

#pragma once

#include "yas_flow.h"

namespace yas::flow {
template <typename State, typename Signal>
struct graph : base {
    class impl;

    graph();
    graph(std::nullptr_t);

    flow::node<State, State, State> begin_flow();
    void add_state(State, flow::observer<State>);
};
}

#include "yas_flow_graph_private.h"
