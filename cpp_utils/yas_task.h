//
//  yas_task.h
//

#pragma once

#include <functional>
#include "yas_task_protocol.h"

namespace yas {
class task;

using task_ptr = std::shared_ptr<task>;

struct task final : controllable_task {
    class impl;

    using execution_f = std::function<void(task const &)>;

    void cancel() override;
    bool is_canceled() const;

    task_option_t const &option() const;

   private:
    std::atomic<bool> _canceled;
    task_option_t _option;
    execution_f _execution;

    explicit task(execution_f &&, task_option_t &&);

    task(task const &) = delete;
    task(task &&) = delete;
    task &operator=(task const &) = delete;
    task &operator=(task &&) = delete;

    void execute() override;

   public:
    static task_ptr make_shared(task::execution_f const &, task_option_t opt = {});
    static task_ptr make_shared(task::execution_f &&, task_option_t opt = {});
};

struct task_queue final {
    class impl;

    using cancellation_f = std::function<bool(std::shared_ptr<task_cancel_id> const &)>;

    explicit task_queue(std::size_t const priority_count = 1);

    void push_back(task_ptr const &);
    void push_front(task_ptr const &);
    void cancel(task_ptr const &);
    void cancel_for_id(task_cancel_id_ptr const &cancel_id);
    void cancel(cancellation_f const &);
    void cancel_all();
    void wait_until_all_tasks_are_finished();

    void suspend();
    void resume();

    std::size_t priority_count() const;
    bool is_suspended() const;
    bool is_operating() const;

   private:
    std::shared_ptr<impl> _impl;
};
}  // namespace yas
