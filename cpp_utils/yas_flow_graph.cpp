//
//  yas_flow_graph.cpp
//

#include "yas_flow_graph.h"

using namespace yas;
using namespace yas::flow;

waiting_out::waiting_out(flow::stay value) : base(std::make_shared<out_impl<flow::stay>>(std::move(value))) {
}

waiting_out::waiting_out(std::nullptr_t) : base(nullptr) {
}

running_out::running_out(std::nullptr_t) : base(nullptr) {
}
