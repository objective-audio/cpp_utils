//
//  worker.cpp
//

#include "worker.h"

#include <atomic>
#include <thread>

#include "stl_utils.h"

using namespace yas;

namespace yas::worker_utils {
bool process(std::vector<workable::task_f> &tasks) {
    bool processed = false;
    std::vector<std::size_t> completed;
    std::size_t idx = 0;

    for (auto const &task : tasks) {
        auto const result = task();

        if (result == workable::task_result::processed) {
            processed = true;
            std::this_thread::yield();
            break;
        } else if (result == workable::task_result::completed) {
            completed.emplace_back(idx);
        }

        ++idx;
    }

    if (completed.size() > 0) {
        std::reverse(completed.begin(), completed.end());
        for (auto const &idx : completed) {
            erase_at(tasks, idx);
        }
    }

    return processed;
}
}  // namespace yas::worker_utils

#pragma mark - resource

struct workable::resource {
    std::vector<task_f> tasks;
    std::atomic<bool> is_continue{true};

    resource(std::vector<task_f> &&tasks) : tasks(std::move(tasks)) {
    }
};

#pragma mark - worker

worker::worker(std::chrono::milliseconds const &duration) : _sleep_duration(duration) {
}

worker::~worker() {
    this->stop();
}

void worker::add_task(uint32_t const priority, task_f &&task) {
    if (this->_resource) {
        throw std::runtime_error("worker add_task() - already started.");
    }

    this->_tasks.emplace(priority, std::move(task));
}

void worker::start() {
    if (this->_resource) {
        throw std::runtime_error("worker start() - already started.");
    }

    if (this->_tasks.size() == 0) {
        throw std::runtime_error("worker start() - task is empty.");
    }

    auto tasks = to_vector<task_f>(this->_tasks, [](auto const &pair) { return pair.second; });

    this->_resource = std::make_shared<resource>(std::move(tasks));

    std::thread thread{[resource = this->_resource, sleep_duration = this->_sleep_duration] {
        while (resource->is_continue) {
            while (resource->is_continue) {
                if (!worker_utils::process(resource->tasks)) {
                    break;
                }
            }
            std::this_thread::sleep_for(sleep_duration);
        }
    }};

    thread.detach();
}

void worker::stop() {
    if (this->_resource) {
        this->_resource->is_continue = false;
        this->_resource = nullptr;
    }
}

worker_ptr worker::make_shared() {
    return worker::make_shared(std::chrono::milliseconds{10});
}

worker_ptr worker::make_shared(std::chrono::milliseconds const &duration) {
    return worker_ptr(new worker{duration});
}

#pragma mark - worker_stub

worker_stub::worker_stub() {
}

void worker_stub::add_task(uint32_t const priority, task_f &&task) {
    if (this->_resource) {
        throw std::runtime_error("worker add_task() - already started.");
    }

    this->_tasks.emplace(priority, std::move(task));
};

void worker_stub::start() {
    if (this->_resource) {
        throw std::runtime_error("worker start() - already started.");
    }

    if (this->_tasks.size() == 0) {
        throw std::runtime_error("worker start() - task is empty.");
    }

    auto tasks = to_vector<task_f>(this->_tasks, [](auto const &pair) { return pair.second; });

    this->_resource = std::make_shared<resource>(std::move(tasks));
}

void worker_stub::stop() {
    if (this->_resource) {
        this->_resource->is_continue = false;
        this->_resource = nullptr;
    }
}

std::vector<workable::task_f> worker_stub::resource_tasks() const {
    return this->_resource->tasks;
}

bool worker_stub::is_started() const {
    return this->_resource != nullptr;
}

void worker_stub::process() {
    worker_utils::process(this->_resource->tasks);
}

worker_stub_ptr worker_stub::make_shared() {
    return worker_stub_ptr(new worker_stub{});
}
