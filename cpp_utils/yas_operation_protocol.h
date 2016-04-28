//
//  yas_operation_protocol.h
//

#pragma once

#include "yas_base.h"
#include "yas_protocol.h"

namespace yas {
class controllable_operation : public protocol {
   public:
    class impl : public protocol::impl {
       public:
        virtual void execute() = 0;
        virtual void cancel() = 0;
    };

    controllable_operation(std::shared_ptr<impl> const &impl) : protocol(impl) {
    }

    void execute() {
        impl_ptr<impl>()->execute();
    }

    void cancel() {
        impl_ptr<impl>()->cancel();
    }
};

using operation_priority_t = uint32_t;

struct operation_option_t {
    operation_priority_t priority = 0;
    base push_cancel_id = nullptr;
};
}
