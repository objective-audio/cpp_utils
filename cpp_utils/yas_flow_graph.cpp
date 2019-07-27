//
//  yas_flow_graph.cpp
//

#include "yas_flow_graph.h"

using namespace yas;
using namespace yas::flow;

out_impl_base::~out_impl_base() = default;

waiting_out::waiting_out(flow::stay value) : _impl(std::make_shared<out_impl<flow::stay>>(std::move(value))) {
}

waiting_out::waiting_out(std::nullptr_t) : _impl(nullptr) {
}

running_out::running_out(std::nullptr_t) : _impl(nullptr) {
}
