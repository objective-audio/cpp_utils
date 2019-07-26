//
//  yas_task.cpp
//

#include "yas_task.h"
#include <atomic>
#include <deque>
#include <mutex>
#include <thread>
#include <vector>
#include "yas_stl_utils.h"

using namespace yas;

#pragma mark - task

class task::impl : public base::impl, public controllable_task::impl {
   public:
    std::atomic<bool> _canceled;
    task_option_t _option;

    impl(execution_f const &execution, task_option_t &&option)
        : _canceled(false), _execution(execution), _option(std::move(option)) {
    }

    impl(execution_f &&execution, task_option_t &&option)
        : _canceled(false), _execution(std::move(execution)), _option(std::move(option)) {
    }

    void execute() {
        if (this->_execution) {
            if (!this->_canceled) {
                this->_execution(cast<task>());
            }
        }
    }

    void cancel() {
        this->_canceled = true;
    }

   private:
    execution_f _execution;
};

task::task(execution_f const &exe, task_option_t option) : base(std::make_unique<impl>(exe, std::move(option))) {
}

task::task(execution_f &&exe, task_option_t opt) : base(std::make_unique<impl>(std::move(exe), std::move(opt))) {
}

task::task(std::nullptr_t) : base(nullptr) {
}

void task::cancel() {
    impl_ptr<impl>()->cancel();
}

bool task::is_canceled() const {
    return impl_ptr<impl>()->_canceled;
}

task_option_t const &task::option() const {
    return impl_ptr<impl>()->_option;
}

controllable_task task::controllable() const {
    return controllable_task{impl_ptr<controllable_task::impl>()};
}

#pragma mark - queue

class task_queue::impl : public base::impl {
   public:
    impl(std::size_t const count) : _tasks(count) {
    }

    ~impl() {
        this->cancel();
    }

    void push_back(task &&task) {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        auto &cancel_id = task.option().push_cancel_id;

        for (auto &deque : this->_tasks) {
            erase_if(deque, [&cancel_id](auto const &value) { return value.option().push_cancel_id == cancel_id; });
        }

        if (this->_current_task) {
            if (this->_current_task.option().push_cancel_id == cancel_id) {
                this->_current_task.cancel();
            }
        }

        auto &deque = this->_tasks.at(task.option().priority);
        deque.emplace_back(std::move(task));

        this->_start_next_task_if_needed();
    }

    void push_front(task &&task) {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        auto &cancel_id = task.option().push_cancel_id;

        for (auto &deque : this->_tasks) {
            erase_if(deque, [&cancel_id](auto const &value) { return value.option().push_cancel_id == cancel_id; });
        }

        if (this->_current_task) {
            if (this->_current_task.option().push_cancel_id == cancel_id) {
                this->_current_task.cancel();
            }
        }

        auto &deque = this->_tasks.at(task.option().priority);
        deque.emplace_front(std::move(task));

        this->_start_next_task_if_needed();
    }

    void cancel(task const &canceling_task) {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        for (auto &deque : this->_tasks) {
            for (auto &task : deque) {
                if (canceling_task == task) {
                    task.cancel();
                }
            }
        }

        if (this->_current_task) {
            if (this->_current_task == canceling_task) {
                this->_current_task.cancel();
            }
        }
    }

    void cancel_for_id(base const &cancel_id) {
        this->cancel([&cancel_id](base const &target_cancel_id) { return cancel_id == target_cancel_id; });
    }

    void cancel(cancellation_f const &cancellation) {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        for (auto &deque : this->_tasks) {
            erase_if(deque, [&cancellation](auto const &value) { return cancellation(value.option().cancel_id); });
        }

        if (this->_current_task) {
            if (cancellation(this->_current_task.option().cancel_id)) {
                this->_current_task.cancel();
            }
        }
    }

    void cancel() {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        for (auto &deque : this->_tasks) {
            for (auto &task : deque) {
                task.cancel();
            }
            deque.clear();
        }

        if (this->_current_task) {
            this->_current_task.cancel();
        }
    }

    void wait_until_all_tasks_are_finished() {
        while (true) {
            std::lock_guard<std::recursive_mutex> lock(this->_mutex);

            bool task_exists = this->_current_task != nullptr;
            if (!task_exists) {
                for (auto &deque : this->_tasks) {
                    if (deque.size() > 0) {
                        task_exists = true;
                    }
                }
            }

            if (task_exists) {
                if (this->_suspended) {
                    throw "task_queue is suspended.";
                }
                std::this_thread::yield();
            } else {
                break;
            }
        }
    }

    void suspend() {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        this->_suspended = true;
    }

    void resume() {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        if (this->_suspended) {
            this->_suspended = false;
            this->_start_next_task_if_needed();
        }
    }

    std::size_t priority_count() const {
        return this->_tasks.size();
    }

    bool is_suspended() const {
        return this->_suspended;
    }

    bool is_operating() {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        if (this->_current_task) {
            return true;
        }

        for (auto const &deque : this->_tasks) {
            if (deque.size() > 0) {
                return true;
            }
        }

        return false;
    }

   private:
    task _current_task = nullptr;
    std::vector<std::deque<task>> _tasks;
    bool _suspended = false;
    mutable std::recursive_mutex _mutex;

    void _start_next_task_if_needed() {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        if (!this->_current_task && !this->_suspended) {
            task task{nullptr};

            for (auto &deque : this->_tasks) {
                if (!deque.empty()) {
                    task = deque.front();
                    deque.pop_front();
                    break;
                }
            }

            if (task) {
                this->_current_task = task;

                std::thread thread{[weak_task = to_weak(task), weak_queue = to_weak(cast<task_queue>())]() {
                    auto task = weak_task.lock();
                    if (task) {
                        task.controllable().execute();

                        if (auto queue = weak_queue.lock()) {
                            queue.impl_ptr<impl>()->_task_did_finish(task);
                        }
                    }
                }};

                thread.detach();
            }
        }
    }

    void _task_did_finish(task const &pre_task) {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        if (this->_current_task == pre_task) {
            this->_current_task = nullptr;
        }

        this->_start_next_task_if_needed();
    }
};

task_queue::task_queue(std::size_t const count) : base(std::make_unique<impl>(count)) {
}

task_queue::task_queue(std::nullptr_t) : base(nullptr) {
}

void task_queue::push_back(task task) {
    impl_ptr<impl>()->push_back(std::move(task));
}

void task_queue::push_front(task task) {
    impl_ptr<impl>()->push_front(std::move(task));
}

void task_queue::cancel(task const &task) {
    impl_ptr<impl>()->cancel(task);
}

void task_queue::cancel_for_id(base const &identifier) {
    impl_ptr<impl>()->cancel_for_id(identifier);
}

void task_queue::cancel(cancellation_f const &cancellation) {
    impl_ptr<impl>()->cancel(cancellation);
}

void task_queue::cancel_all() {
    impl_ptr<impl>()->cancel();
}

void task_queue::wait_until_all_tasks_are_finished() {
    impl_ptr<impl>()->wait_until_all_tasks_are_finished();
}

void task_queue::suspend() {
    impl_ptr<impl>()->suspend();
}

void task_queue::resume() {
    impl_ptr<impl>()->resume();
}

std::size_t task_queue::priority_count() const {
    return impl_ptr<impl>()->priority_count();
}

bool task_queue::is_suspended() const {
    return impl_ptr<impl>()->is_suspended();
}

bool task_queue::is_operating() const {
    return impl_ptr<impl>()->is_operating();
}