//
//  yas_task.h
//

#pragma once

#include <functional>
#include "yas_task_protocol.h"

namespace yas {
struct task : base, controllable_task, std::enable_shared_from_this<task> {
    class impl;

    using execution_f = std::function<void(task const &)>;

    void cancel() override;
    bool is_canceled() const;

    task_option_t const &option() const;

    std::shared_ptr<controllable_task> controllable();

   private:
    void execute() override;

    explicit task(execution_f const &, task_option_t &&);
    explicit task(execution_f &&, task_option_t &&);

    task(task const &) = delete;
    task(task &&) = delete;
    task &operator=(task const &) = delete;
    task &operator=(task &&) = delete;

    friend std::shared_ptr<task> make_task(task::execution_f const &, task_option_t);
    friend std::shared_ptr<task> make_task(task::execution_f &&, task_option_t);
};

std::shared_ptr<task> make_task(task::execution_f const &, task_option_t opt = {});
std::shared_ptr<task> make_task(task::execution_f &&, task_option_t opt = {});

struct task_queue : base {
    class impl;

    using cancellation_f = std::function<bool(base const &)>;

    explicit task_queue(std::size_t const priority_count = 1);
    task_queue(std::nullptr_t);

    void push_back(task &);
    void push_front(task &);
    void cancel(task &);
    void cancel_for_id(base const &cancel_id);
    void cancel(cancellation_f const &);
    void cancel_all();
    void wait_until_all_tasks_are_finished();

    void suspend();
    void resume();

    std::size_t priority_count() const;
    bool is_suspended() const;
    bool is_operating() const;
};
}  // namespace yas
