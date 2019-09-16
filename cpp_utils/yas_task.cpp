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

task::task(execution_f &&execution, task_option_t &&option)
    : _canceled(false), _execution(std::move(execution)), _option(std::move(option)) {
}

void task::cancel() {
    this->_canceled = true;
}

bool task::is_canceled() const {
    return this->_canceled;
}

task_option_t const &task::option() const {
    return this->_option;
}

void task::execute() {
    if (!this->is_canceled()) {
        if (auto &execution = this->_execution) {
            execution(*this);
        }
    }
}

task_ptr task::make_shared(task::execution_f const &execution, task_option_t opt) {
    auto copied_execution = execution;
    return task::make_shared(std::move(copied_execution), std::move(opt));
}

task_ptr task::make_shared(task::execution_f &&execution, task_option_t opt) {
    return task_ptr(new task{std::move(execution), std::move(opt)});
}

#pragma mark - queue

struct task_queue::impl {
    impl(std::size_t const count) : _tasks(count) {
    }

    ~impl() {
        this->cancel();
    }

    void prepare(std::shared_ptr<impl> const &shared_impl) {
        this->_weak_impl = shared_impl;
    }

    void push_back(task_ptr const &task) {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        auto &cancel_id = task->option().push_cancel_id;

        if (cancel_id) {
            for (auto &deque : this->_tasks) {
                erase_if(deque, [&cancel_id](auto const &value) {
                    if (auto const &push_cancel_id = value->option().push_cancel_id) {
                        return push_cancel_id->is_equal(cancel_id);
                    } else {
                        return false;
                    }
                });
            }
        }

        if (this->_current_task) {
            if (auto const &push_cancel_id = this->_current_task->option().push_cancel_id) {
                if (push_cancel_id->is_equal(cancel_id)) {
                    this->_current_task->cancel();
                }
            }
        }

        auto &deque = this->_tasks.at(task->option().priority);
        deque.emplace_back(task);

        this->_start_next_task_if_needed();
    }

    void push_front(task_ptr const &task) {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        auto &cancel_id = task->option().push_cancel_id;

        if (cancel_id) {
            for (auto &deque : this->_tasks) {
                erase_if(deque, [&cancel_id](auto const &value) {
                    if (auto const &push_cancel_id = value->option().push_cancel_id) {
                        return push_cancel_id->is_equal(cancel_id);
                    } else {
                        return false;
                    }
                });
            }
        }

        if (this->_current_task) {
            if (auto const &push_cancel_id = this->_current_task->option().push_cancel_id) {
                if (push_cancel_id->is_equal(cancel_id)) {
                    this->_current_task->cancel();
                }
            }
        }

        auto &deque = this->_tasks.at(task->option().priority);
        deque.emplace_front(task);

        this->_start_next_task_if_needed();
    }

    void cancel(task_ptr const &canceling_task) {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        for (auto &deque : this->_tasks) {
            for (auto &task : deque) {
                if (canceling_task == task) {
                    task->cancel();
                }
            }
        }

        if (this->_current_task) {
            if (this->_current_task == canceling_task) {
                this->_current_task->cancel();
            }
        }
    }

    void cancel_for_id(std::shared_ptr<task_cancel_id> const &cancel_id) {
        if (cancel_id) {
            this->cancel([&cancel_id](auto const &target_cancel_id) {
                if (target_cancel_id) {
                    return cancel_id->is_equal(target_cancel_id);
                } else {
                    return false;
                }
            });
        }
    }

    void cancel(cancellation_f const &cancellation) {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        for (auto &deque : this->_tasks) {
            erase_if(deque, [&cancellation](auto const &value) { return cancellation(value->option().cancel_id); });
        }

        if (this->_current_task) {
            if (cancellation(this->_current_task->option().cancel_id)) {
                this->_current_task->cancel();
            }
        }
    }

    void cancel() {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        for (auto &deque : this->_tasks) {
            for (auto &task : deque) {
                task->cancel();
            }
            deque.clear();
        }

        if (this->_current_task) {
            this->_current_task->cancel();
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
    std::weak_ptr<impl> _weak_impl;
    task_ptr _current_task = nullptr;
    std::vector<std::deque<task_ptr>> _tasks;
    bool _suspended = false;
    mutable std::recursive_mutex _mutex;

    void _start_next_task_if_needed() {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        if (!this->_current_task && !this->_suspended) {
            task_ptr task{nullptr};

            for (auto &deque : this->_tasks) {
                if (!deque.empty()) {
                    task = deque.front();
                    deque.pop_front();
                    break;
                }
            }

            if (task) {
                this->_current_task = task;

                std::thread thread{[weak_task = to_weak(task), weak_queue_impl = this->_weak_impl]() {
                    auto task = weak_task.lock();
                    if (task) {
                        controllable_task::cast(task)->execute();

                        if (auto queue_impl = weak_queue_impl.lock()) {
                            queue_impl->_task_did_finish(task);
                        }
                    }
                }};

                thread.detach();
            }
        }
    }

    void _task_did_finish(task_ptr const &pre_task) {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        if (this->_current_task == pre_task) {
            this->_current_task = nullptr;
        }

        this->_start_next_task_if_needed();
    }
};

task_queue::task_queue(std::size_t const count) : _impl(std::make_unique<impl>(count)) {
    this->_impl->prepare(this->_impl);
}

void task_queue::push_back(task_ptr const &task) {
    this->_impl->push_back(task);
}

void task_queue::push_front(task_ptr const &task) {
    this->_impl->push_front(task);
}

void task_queue::cancel(task_ptr const &task) {
    this->_impl->cancel(task);
}

void task_queue::cancel_for_id(task_cancel_id_ptr const &identifier) {
    this->_impl->cancel_for_id(identifier);
}

void task_queue::cancel(cancellation_f const &cancellation) {
    this->_impl->cancel(cancellation);
}

void task_queue::cancel_all() {
    this->_impl->cancel();
}

void task_queue::wait_until_all_tasks_are_finished() {
    this->_impl->wait_until_all_tasks_are_finished();
}

void task_queue::suspend() {
    this->_impl->suspend();
}

void task_queue::resume() {
    this->_impl->resume();
}

std::size_t task_queue::priority_count() const {
    return this->_impl->priority_count();
}

bool task_queue::is_suspended() const {
    return this->_impl->is_suspended();
}

bool task_queue::is_operating() const {
    return this->_impl->is_operating();
}
