//
//  yas_task_protocol.h
//

#pragma once

#include "yas_base.h"
#include "yas_protocol.h"

namespace yas {
struct controllable_task {
    virtual ~controllable_task() = default;

    virtual void execute() = 0;
    virtual void cancel() = 0;
};

using task_priority_t = uint32_t;

struct task_option_t {
    task_priority_t priority = 0;
    base cancel_id = nullptr;
    base push_cancel_id = nullptr;
};
}  // namespace yas
