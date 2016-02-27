//
//  yas_operation_protocol.h
//

#pragma once

#include "yas_base.h"

namespace yas {
class operation_controllable {
   public:
    virtual void _execute() = 0;
    virtual void _cancel() = 0;
};

using operation_priority_t = UInt32;

struct operation_option_t {
    operation_priority_t priority = 0;
    base push_cancel_id = nullptr;
};
}
