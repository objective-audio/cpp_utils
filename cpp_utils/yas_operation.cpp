//
//  yas_operation.cpp
//

#include "yas_operation.h"
#include <atomic>
#include <deque>
#include <mutex>
#include <thread>
#include <vector>
#include "yas_stl_utils.h"

using namespace yas;

#pragma mark - operation

class operation::impl : public base::impl, public controllable_operation::impl {
   public:
    std::atomic<bool> _canceled;
    operation_option_t _option;

    impl(execution_f const &exe, operation_option_t &&option)
        : _canceled(false), _execution(exe), _option(std::move(option)) {
    }

    impl(execution_f &&exe, operation_option_t &&option)
        : _canceled(false), _execution(std::move(exe)), _option(std::move(option)) {
    }

    void execute() {
        if (this->_execution) {
            if (!this->_canceled) {
                this->_execution(cast<operation>());
            }
        }
    }

    void cancel() {
        this->_canceled = true;
    }

   private:
    execution_f _execution;
};

operation::operation(execution_f const &exe, operation_option_t option)
    : base(std::make_unique<impl>(exe, std::move(option))) {
}

operation::operation(execution_f &&exe, operation_option_t opt)
    : base(std::make_unique<impl>(std::move(exe), std::move(opt))) {
}

operation::operation(std::nullptr_t) : base(nullptr) {
}

void operation::cancel() {
    impl_ptr<impl>()->cancel();
}

bool operation::is_canceled() const {
    return impl_ptr<impl>()->_canceled;
}

operation_option_t const &operation::option() const {
    return impl_ptr<impl>()->_option;
}

controllable_operation operation::controllable() const {
    return controllable_operation{impl_ptr<controllable_operation::impl>()};
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
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        auto &cancel_id = op.option().push_cancel_id;

        for (auto &dq : _operations) {
            erase_if(dq, [&cancel_id](auto const &value) { return value.option().push_cancel_id == cancel_id; });
        }

        if (this->_current_operation) {
            if (this->_current_operation.option().push_cancel_id == cancel_id) {
                this->_current_operation.cancel();
            }
        }

        auto &dq = this->_operations.at(op.option().priority);
        dq.emplace_back(std::move(op));

        this->_start_next_operation_if_needed();
    }

    void push_front(operation &&op) {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        auto &cancel_id = op.option().push_cancel_id;

        for (auto &dq : this->_operations) {
            erase_if(dq, [&cancel_id](auto const &value) { return value.option().push_cancel_id == cancel_id; });
        }

        if (this->_current_operation) {
            if (this->_current_operation.option().push_cancel_id == cancel_id) {
                this->_current_operation.cancel();
            }
        }

        auto &dq = this->_operations.at(op.option().priority);
        dq.emplace_front(std::move(op));

        this->_start_next_operation_if_needed();
    }

    void cancel(operation const &operation) {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        for (auto &dq : this->_operations) {
            for (auto &op : dq) {
                if (operation == op) {
                    op.cancel();
                }
            }
        }

        if (this->_current_operation) {
            if (this->_current_operation == operation) {
                this->_current_operation.cancel();
            }
        }
    }

    void cancel() {
        std::lock_guard<std::recursive_mutex> lock(this->_mutex);

        for (auto &dq : this->_operations) {
            for (auto &op : dq) {
                op.cancel();
            }
            dq.clear();
        }

        if (this->_current_operation) {
            this->_current_operation.cancel();
        }
    }

    void wait_until_all_operations_are_finished() {
        while (true) {
            std::lock_guard<std::recursive_mutex> lock(this->_mutex);

            bool op_exists = this->_current_operation != nullptr;
            if (!op_exists) {
                for (auto &dq : this->_operations) {
                    if (dq.size() > 0) {
                        op_exists = true;
                    }
                }
            }

            if (op_exists) {
                if (this->_suspended) {
                    throw "operation_queue is suspended.";
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
            this->_start_next_operation_if_needed();
        }
    }

    bool is_suspended() const {
        return _suspended;
    }

    bool is_operating() {
        std::lock_guard<std::recursive_mutex> lock(_mutex);

        if (_current_operation) {
            return true;
        }

        for (auto const &dq : _operations) {
            if (dq.size() > 0) {
                return true;
            }
        }

        return false;
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
                        ope.controllable().execute();

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

operation_queue::operation_queue(size_t const count) : base(std::make_unique<impl>(count)) {
}

operation_queue::operation_queue(std::nullptr_t) : base(nullptr) {
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

bool operation_queue::is_suspended() const {
    return impl_ptr<impl>()->is_suspended();
}

bool operation_queue::is_operating() const {
    return impl_ptr<impl>()->is_operating();
}
