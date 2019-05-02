//
//  yas_task_protocol.h
//

#pragma once

#include "yas_base.h"
#include "yas_protocol.h"

namespace yas {
class controllable_task : public protocol {
   public:
    class impl : public protocol::impl {
       public:
        virtual void execute() = 0;
        virtual void cancel() = 0;
    };

    controllable_task(std::shared_ptr<impl> const &impl) : protocol(impl) {
    }

    void execute() {
        impl_ptr<impl>()->execute();
    }

    void cancel() {
        impl_ptr<impl>()->cancel();
    }
};

using task_priority_t = uint32_t;

struct task_option_t {
    task_priority_t priority = 0;
    base cancel_id = nullptr;
    base push_cancel_id = nullptr;
};
}  // namespace yas
