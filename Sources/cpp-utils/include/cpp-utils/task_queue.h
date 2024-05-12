//
//  task_queue.h
//

#pragma once

#include <deque>
#include <functional>
#include <mutex>
#include <optional>
#include <vector>

namespace yas {
template <typename Canceller>
class task;

template <typename Canceller>
using task_execution_f = std::function<void(task<Canceller> const &)>;
using task_priority_t = uint32_t;

template <typename Canceller>
struct task_option_t {
    task_priority_t priority = 0;
    std::optional<Canceller> canceller;
};

template <typename Canceller>
struct task final {
    void cancel();
    bool is_canceled() const;

    task_option_t<Canceller> const &option() const;

    void execute();

    static std::shared_ptr<task> make_shared(task_execution_f<Canceller> &&, task_option_t<Canceller> &&option = {});

   private:
    std::atomic<bool> _canceled;
    task_option_t<Canceller> const _option;
    task_execution_f<Canceller> const _execution;

    task(task_execution_f<Canceller> &&, task_option_t<Canceller> &&);
};

template <typename Canceller>
struct task_queue final {
    using cancellation_f = std::function<bool(Canceller const &)>;

    ~task_queue();

    void push_back(std::shared_ptr<task<Canceller>> const &);
    void push_front(std::shared_ptr<task<Canceller>> const &);
    void cancel(std::shared_ptr<task<Canceller>> const &);
    void cancel(cancellation_f const &);
    void cancel_all();
    void wait_until_all_tasks_are_finished();

    void suspend();
    void resume();

    std::size_t priority_count() const;
    bool is_suspended() const;
    bool is_operating() const;

    static std::shared_ptr<task_queue> make_shared(std::size_t const priority_count = 1);

   private:
    std::weak_ptr<task_queue> _weak_queue;
    std::shared_ptr<task<Canceller>> _current_task = nullptr;
    std::vector<std::deque<std::shared_ptr<task<Canceller>>>> _tasks;
    bool _suspended = false;
    mutable std::recursive_mutex _mutex;

    task_queue(std::size_t const priority_count);

    std::shared_ptr<task<Canceller>> _pop_task();
    void _begin_next_task_if_needed();
    void _task_did_finish_on_bg(std::shared_ptr<task<Canceller>> const &pre_task);
};
}  // namespace yas

#include "task_queue_private.h"
