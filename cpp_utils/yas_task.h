//
//  yas_task.h
//

#pragma once

#include <functional>
#include "yas_task_protocol.h"

namespace yas {
struct task final : controllable_task, std::enable_shared_from_this<task> {
    class impl;

    using execution_f = std::function<void(task const &)>;

    void cancel() override;
    bool is_canceled() const;

    task_option_t const &option() const;

    std::shared_ptr<controllable_task> controllable();

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
    static std::shared_ptr<task> make_shared(task::execution_f const &, task_option_t opt = {});
    static std::shared_ptr<task> make_shared(task::execution_f &&, task_option_t opt = {});
};

struct task_queue final {
    class impl;

    using cancellation_f = std::function<bool(std::shared_ptr<task_cancel_id> const &)>;

    explicit task_queue(std::size_t const priority_count = 1);

    void push_back(task &);
    void push_front(task &);
    void cancel(task &);
    void cancel_for_id(std::shared_ptr<task_cancel_id> const &cancel_id);
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
