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

struct task_cancel_id {
    virtual ~task_cancel_id() = default;
    virtual bool is_equal(std::shared_ptr<task_cancel_id> const &) const = 0;
};

struct task_option_t {
    task_priority_t priority = 0;
    std::shared_ptr<task_cancel_id> cancel_id = nullptr;
    std::shared_ptr<task_cancel_id> push_cancel_id = nullptr;
};
}  // namespace yas
