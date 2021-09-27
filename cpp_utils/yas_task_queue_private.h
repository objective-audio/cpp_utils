//
//  yas_task_queue_private.h
//

#pragma once

#include <cpp_utils/yas_stl_utils.h>

#include <thread>

#pragma mark - task

namespace yas {
template <typename Canceller>
task<Canceller>::task(task_execution_f<Canceller> &&execution, task_option_t<Canceller> &&option)
    : _canceled(false), _execution(std::move(execution)), _option(std::move(option)) {
}

template <typename Canceller>
void task<Canceller>::cancel() {
    this->_canceled = true;
}

template <typename Canceller>
bool task<Canceller>::is_canceled() const {
    return this->_canceled;
}

template <typename Canceller>
task_option_t<Canceller> const &task<Canceller>::option() const {
    return this->_option;
}

template <typename Canceller>
void task<Canceller>::execute() {
    if (!this->is_canceled()) {
        if (auto const &execution = this->_execution) {
            execution(*this);
        }
    }
}

template <typename Canceller>
std::shared_ptr<task<Canceller>> task<Canceller>::make_shared(task_execution_f<Canceller> &&execution,
                                                              task_option_t<Canceller> &&option) {
    return std::shared_ptr<task>(new task{std::move(execution), std::move(option)});
}

#pragma mark - task_queue

template <typename Canceller>
task_queue<Canceller>::task_queue(std::size_t const priority_count) : _tasks(priority_count) {
}

template <typename Canceller>
task_queue<Canceller>::~task_queue() {
    this->cancel_all();
}

template <typename Canceller>
void task_queue<Canceller>::push_back(std::shared_ptr<task<Canceller>> const &task) {
    std::lock_guard<std::recursive_mutex> lock(this->_mutex);

    this->_tasks.at(task->option().priority).emplace_back(task);
    this->_begin_next_task_if_needed();
}

template <typename Canceller>
void task_queue<Canceller>::push_front(std::shared_ptr<task<Canceller>> const &task) {
    std::lock_guard<std::recursive_mutex> lock(this->_mutex);

    this->_tasks.at(task->option().priority).emplace_front(task);
    this->_begin_next_task_if_needed();
}

template <typename Canceller>
void task_queue<Canceller>::cancel(std::shared_ptr<task<Canceller>> const &canceling_task) {
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

template <typename Canceller>
void task_queue<Canceller>::cancel(cancellation_f const &cancellation) {
    std::lock_guard<std::recursive_mutex> lock(this->_mutex);

    for (auto &deque : this->_tasks) {
        erase_if(deque, [&cancellation](auto const &task) {
            auto const &canceller = task->option().canceller;
            return canceller.has_value() && cancellation(canceller.value());
        });
    }

    if (this->_current_task) {
        auto const &canceller = this->_current_task->option().canceller;
        if (canceller.has_value() && cancellation(canceller.value())) {
            this->_current_task->cancel();
        }
    }
}

template <typename Canceller>
void task_queue<Canceller>::cancel_all() {
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

template <typename Canceller>
void task_queue<Canceller>::wait_until_all_tasks_are_finished() {
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
                throw std::runtime_error("task_queue is suspended.");
            }
            std::this_thread::yield();
        } else {
            break;
        }
    }
}

template <typename Canceller>
void task_queue<Canceller>::suspend() {
    std::lock_guard<std::recursive_mutex> lock(this->_mutex);

    this->_suspended = true;
}

template <typename Canceller>
void task_queue<Canceller>::resume() {
    std::lock_guard<std::recursive_mutex> lock(this->_mutex);

    if (this->_suspended) {
        this->_suspended = false;
        this->_begin_next_task_if_needed();
    }
}

template <typename Canceller>
std::size_t task_queue<Canceller>::priority_count() const {
    return this->_tasks.size();
}

template <typename Canceller>
bool task_queue<Canceller>::is_suspended() const {
    return this->_suspended;
}

template <typename Canceller>
bool task_queue<Canceller>::is_operating() const {
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

template <typename Canceller>
std::shared_ptr<task<Canceller>> task_queue<Canceller>::_pop_task() {
    std::lock_guard<std::recursive_mutex> lock(this->_mutex);

    for (auto &deque : this->_tasks) {
        if (!deque.empty()) {
            auto task = deque.front();
            deque.pop_front();
            return task;
        }
    }
    return nullptr;
}

template <typename Canceller>
void task_queue<Canceller>::_begin_next_task_if_needed() {
    std::lock_guard<std::recursive_mutex> lock(this->_mutex);

    if (!this->_current_task && !this->_suspended) {
        if (auto const task = this->_pop_task()) {
            this->_current_task = task;

            std::thread thread{[weak_task = to_weak(task), weak_queue = this->_weak_queue]() {
                if (auto const task = weak_task.lock()) {
                    task->execute();

                    if (auto const queue = weak_queue.lock()) {
                        queue->_task_did_finish_on_bg(task);
                    }
                }
            }};

            thread.detach();
        }
    }
}

template <typename Canceller>
void task_queue<Canceller>::_task_did_finish_on_bg(std::shared_ptr<task<Canceller>> const &pre_task) {
    std::lock_guard<std::recursive_mutex> lock(this->_mutex);

    if (this->_current_task == pre_task) {
        this->_current_task = nullptr;
    }

    this->_begin_next_task_if_needed();
}

template <typename Canceller>
std::shared_ptr<task_queue<Canceller>> task_queue<Canceller>::make_shared(std::size_t const priority_count) {
    auto shared = std::shared_ptr<task_queue>(new task_queue{priority_count});
    shared->_weak_queue = shared;
    return shared;
}
}  // namespace yas
