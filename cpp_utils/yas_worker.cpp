//
//  yas_worker.cpp
//

#include "yas_worker.h"

#include <atomic>
#include <chrono>
#include <thread>

#include "yas_stl_utils.h"

using namespace yas;

struct worker::resource {
    std::vector<task_f> tasks;
    std::atomic<bool> is_continue{true};

    resource(std::vector<task_f> &&tasks) : tasks(std::move(tasks)) {
    }
};

worker::worker() = default;

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

    std::thread thread{[resource = this->_resource] {
        while (resource->is_continue) {
            while (resource->is_continue) {
                bool processed = false;
                std::vector<std::size_t> completed;
                std::size_t idx = 0;

                for (auto const &task : resource->tasks) {
                    auto const result = task();

                    if (result == task_result::processed) {
                        processed = true;
                        std::this_thread::yield();
                        break;
                    } else if (result == task_result::completed) {
                        completed.emplace_back(idx);
                    }

                    ++idx;
                }

                if (completed.size() > 0) {
                    std::reverse(completed.begin(), completed.end());
                    for (auto const &idx : completed) {
                        erase_at(resource->tasks, idx);
                    }
                }

                if (!processed) {
                    break;
                }
            }
            std::this_thread::sleep_for(std::chrono::milliseconds{10});
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
    return worker_ptr(new worker{});
}
