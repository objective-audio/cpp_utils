//
//  yas_task_protocol.h
//

#pragma once

#include <memory>

namespace yas {
struct controllable_task {
    virtual ~controllable_task() = default;

    virtual void execute() = 0;
    virtual void cancel() = 0;

    static std::shared_ptr<controllable_task> cast(std::shared_ptr<controllable_task> const &task) {
        return task;
    }
};

using task_priority_t = uint32_t;

class task_cancel_id;
using task_cancel_id_ptr = std::shared_ptr<task_cancel_id>;

struct task_cancel_id {
    virtual ~task_cancel_id() = default;
    virtual bool is_equal(std::shared_ptr<task_cancel_id> const &) const = 0;

    static task_cancel_id_ptr cast(task_cancel_id_ptr const &cancel_id) {
        return cancel_id;
    }
};

struct task_option_t {
    task_priority_t priority = 0;
    task_cancel_id_ptr cancel_id = nullptr;
    task_cancel_id_ptr push_cancel_id = nullptr;
};
}  // namespace yas
