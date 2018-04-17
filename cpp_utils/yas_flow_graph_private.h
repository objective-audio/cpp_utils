//
//  yas_flow_graph_private.h
//

#pragma once

namespace yas {
template <typename State, typename Signal>
struct flow::graph<State, Signal>::impl : base::impl {};

template <typename State, typename Signal>
flow::graph<State, Signal>::graph() : baes(std::make_shared<impl>()) {
}

template <typename State, typename Signal>
flow::graph<State, Signal>::graph(std::nullptr_t) : base(nullptr) {
}
}
