//
//  yas_operation.h
//

#pragma once

#include <MacTypes.h>
#include <functional>
#include <memory>
#include "yas_base.h"

namespace yas {
class operation;

class operation_controllable {
   public:
    virtual void _execute() = 0;
    virtual void _cancel() = 0;
};

class operation : public base, public operation_controllable {
    using super_class = base;

   public:
    using execution_f = std::function<void(operation const &)>;

    explicit operation(execution_f const &);
    explicit operation(execution_f &&);
    operation(std::nullptr_t);

    void cancel();
    bool is_canceled() const;

   private:
    class impl;

    void _execute() override;
    void _cancel() override;
};

class operation_queue : public base {
    using super_class = base;

   public:
    class impl;

    using priority_t = UInt32;

    explicit operation_queue(size_t const priority_count = 1);
    operation_queue(std::nullptr_t);

    void add_operation(operation const &, priority_t const pr = 0);
    void insert_operation_to_top(operation const &, priority_t const pr = 0);
    void cancel_operation(operation const &);
    void cancel_all_operations();
    void wait_until_all_operations_are_finished();

    void suspend();
    void resume();
};
}
