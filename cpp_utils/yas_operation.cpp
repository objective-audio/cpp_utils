//
//  yas_operation.cpp
//

#include <atomic>
#include <deque>
#include <mutex>
#include <thread>
#include <vector>
#include "yas_operation.h"

using namespace yas;

#pragma mark - operation

class operation::impl : public base::impl {
   public:
    std::atomic<bool> canceled;
    execution_f execution;

    impl(execution_f const &exe) : canceled(false), execution(exe) {
    }

    impl(execution_f &&exe) : canceled(false), execution(std::move(exe)) {
    }
};

operation::operation(execution_f const &exe) : super_class(std::make_unique<impl>(exe)) {
}

operation::operation(execution_f &&exe) : super_class(std::make_unique<impl>(std::move(exe))) {
}

operation::operation(std::nullptr_t) : super_class(nullptr) {
}

void operation::cancel() {
    _cancel();
}

bool operation::is_canceled() const {
    return impl_ptr<impl>()->canceled;
}

void operation::_execute() {
    if (auto &exe = impl_ptr<impl>()->execution) {
        if (!is_canceled()) {
            exe(*this);
        }
    }
}

void operation::_cancel() {
    impl_ptr<impl>()->canceled = true;
}

#pragma mark - queue

class operation_queue::impl : public base::impl {
   public:
    impl(size_t const count) : _operations(count) {
    }

    ~impl() {
        cancel_all_operations();
    }

    void add_operation(operation &&op, priority_t const priority) {
        std::lock_guard<std::recursive_mutex> lock(_mutex);

        auto &dq = _operations.at(priority);
        dq.emplace_back(std::move(op));

        _start_next_operation_if_needed();
    }

    void insert_operation_to_top(operation &&op, priority_t const priority) {
        std::lock_guard<std::recursive_mutex> lock(_mutex);

        auto &dq = _operations.at(priority);
        dq.emplace_front(std::move(op));

        _start_next_operation_if_needed();
    }

    void cancel_operation(operation const &operation) {
        std::lock_guard<std::recursive_mutex> lock(_mutex);

        for (auto &dq : _operations) {
            for (auto &op : dq) {
                if (operation == op) {
                    op.cancel();
                }
            }
        }

        if (_current_operation) {
            if (_current_operation == operation) {
                _current_operation.cancel();
            }
        }
    }

    void cancel_all_operations() {
        std::lock_guard<std::recursive_mutex> lock(_mutex);

        for (auto &dq : _operations) {
            for (auto &op : dq) {
                op.cancel();
            }
            dq.clear();
        }

        if (_current_operation) {
            _current_operation.cancel();
        }
    }

    void wait_until_all_operations_are_finished() {
        while (true) {
            std::lock_guard<std::recursive_mutex> lock(_mutex);

            bool op_exists = _current_operation != nullptr;
            if (!op_exists) {
                for (auto &dq : _operations) {
                    if (dq.size() > 0) {
                        op_exists = true;
                    }
                }
            }

            if (op_exists) {
                if (_suspended) {
                    throw "operation_queue is suspended.";
                }
                std::this_thread::yield();
            } else {
                break;
            }
        }
    }

    void suspend() {
        std::lock_guard<std::recursive_mutex> lock(_mutex);

        _suspended = true;
    }

    void resume() {
        std::lock_guard<std::recursive_mutex> lock(_mutex);

        if (_suspended) {
            _suspended = false;
            _start_next_operation_if_needed();
        }
    }

   private:
    operation _current_operation = nullptr;
    std::vector<std::deque<operation>> _operations;
    bool _suspended = false;
    mutable std::recursive_mutex _mutex;

    void _start_next_operation_if_needed() {
        std::lock_guard<std::recursive_mutex> lock(_mutex);

        if (!_current_operation && !_suspended) {
            operation op{nullptr};

            for (auto &dq : _operations) {
                if (!dq.empty()) {
                    op = dq.front();
                    dq.pop_front();
                    break;
                }
            }

            if (op) {
                _current_operation = op;

                auto weak_ope = to_weak(op);
                auto weak_queue = to_weak(cast<operation_queue>());

                std::thread thread{[weak_ope, weak_queue]() {
                    auto ope = weak_ope.lock();
                    if (ope) {
                        auto &ope_for_queue = static_cast<operation_controllable &>(ope);
                        ope_for_queue._execute();
                        if (auto queue = weak_queue.lock()) {
                            queue.impl_ptr<impl>()->_operation_did_finish(ope);
                        }
                    }
                }};

                thread.detach();
            }
        }
    }

    void _operation_did_finish(operation const &prev_op) {
        std::lock_guard<std::recursive_mutex> lock(_mutex);

        if (_current_operation == prev_op) {
            _current_operation = nullptr;
        }

        _start_next_operation_if_needed();
    }
};

operation_queue::operation_queue(size_t const count) : super_class(std::make_unique<impl>(count)) {
}

operation_queue::operation_queue(std::nullptr_t) : super_class(nullptr) {
}

void operation_queue::add_operation(operation op, priority_t const pr) {
    impl_ptr<impl>()->add_operation(std::move(op), pr);
}

void operation_queue::insert_operation_to_top(operation op, priority_t const pr) {
    impl_ptr<impl>()->insert_operation_to_top(std::move(op), pr);
}

void operation_queue::cancel_operation(operation const &op) {
    impl_ptr<impl>()->cancel_operation(op);
}

void operation_queue::cancel_all_operations() {
    impl_ptr<impl>()->cancel_all_operations();
}

void operation_queue::wait_until_all_operations_are_finished() {
    impl_ptr<impl>()->wait_until_all_operations_are_finished();
}

void operation_queue::suspend() {
    impl_ptr<impl>()->suspend();
}

void operation_queue::resume() {
    impl_ptr<impl>()->resume();
}
