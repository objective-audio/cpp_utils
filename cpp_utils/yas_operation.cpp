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
    operation_option_t option;

    impl(execution_f const &exe, operation_option_t &&option)
        : canceled(false), execution(exe), option(std::move(option)) {
    }

    impl(execution_f &&exe, operation_option_t &&option)
        : canceled(false), execution(std::move(exe)), option(std::move(option)) {
    }
};

operation::operation(execution_f const &exe, operation_option_t option)
    : super_class(std::make_unique<impl>(exe, std::move(option))) {
}

operation::operation(execution_f &&exe, operation_option_t opt)
    : super_class(std::make_unique<impl>(std::move(exe), std::move(opt))) {
}

operation::operation(std::nullptr_t) : super_class(nullptr) {
}

void operation::cancel() {
    _cancel();
}

bool operation::is_canceled() const {
    return impl_ptr<impl>()->canceled;
}

operation_option_t const &operation::option() const {
    return impl_ptr<impl>()->option;
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
        cancel();
    }

    void push_back(operation &&op) {
        std::lock_guard<std::recursive_mutex> lock(_mutex);

        auto &dq = _operations.at(op.option().priority);
        dq.emplace_back(std::move(op));

        _start_next_operation_if_needed();
    }

    void push_front(operation &&op) {
        std::lock_guard<std::recursive_mutex> lock(_mutex);

        auto &dq = _operations.at(op.option().priority);
        dq.emplace_front(std::move(op));

        _start_next_operation_if_needed();
    }

    void cancel(operation const &operation) {
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

    void cancel() {
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

void operation_queue::push_back(operation op) {
    impl_ptr<impl>()->push_back(std::move(op));
}

void operation_queue::push_front(operation op) {
    impl_ptr<impl>()->push_front(std::move(op));
}

void operation_queue::cancel(operation const &op) {
    impl_ptr<impl>()->cancel(op);
}

void operation_queue::cancel() {
    impl_ptr<impl>()->cancel();
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
