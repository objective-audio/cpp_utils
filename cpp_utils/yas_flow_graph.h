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
}
}

#include "yas_flow_graph.private.h"
