//
//  yas_operation.h
//

#pragma once

#include <MacTypes.h>
#include <functional>
#include <memory>
#include "yas_base.h"
#include "yas_operation_protocol.h"

namespace yas {
class operation;

class operation : public base, public operation_controllable {
    using super_class = base;

   public:
    using execution_f = std::function<void(operation const &)>;

    explicit operation(execution_f const &, operation_option_t opt = {.priority = 0});
    explicit operation(execution_f &&, operation_option_t opt = {.priority = 0});
    operation(std::nullptr_t);

    void cancel();
    bool is_canceled() const;

    operation_option_t const &option() const;

   private:
    class impl;

    void _execute() override;
    void _cancel() override;
};

class operation_queue : public base {
    using super_class = base;

   public:
    class impl;

    explicit operation_queue(size_t const priority_count = 1);
    operation_queue(std::nullptr_t);

    void push_back(operation);
    void push_front(operation);
    void cancel(operation const &);
    void cancel();
    void wait_until_all_operations_are_finished();

    void suspend();
    void resume();
};
}
