//
//  yas_playing_background_queue.cpp
//

#include "yas_background_queue.h"

#include <atomic>
#include <chrono>
#include <thread>

#include "yas_stl_utils.h"

using namespace yas;

struct background_queue::context {
    std::vector<task_f> const tasks;
    std::atomic<bool> is_continue{true};

    context(std::vector<task_f> &&tasks) : tasks(std::move(tasks)) {
    }
};

background_queue::background_queue() {
}

background_queue::~background_queue() {
    this->stop();
}

void background_queue::add_task(uint32_t const priority, task_f &&task) {
    if (this->_context) {
        throw std::runtime_error("background_queue add_task() - already started.");
    }

    this->_tasks.emplace(priority, std::move(task));
}

void background_queue::start() {
    if (this->_context) {
        throw std::runtime_error("background_queue start() - already started.");
    }

    if (this->_tasks.size() == 0) {
        throw std::runtime_error("background_queue start() - task is empty.");
    }

    auto tasks = to_vector<task_f>(this->_tasks, [](auto const &pair) { return pair.second; });

    this->_context = std::make_shared<context>(std::move(tasks));

    std::thread thread{[context = this->_context] {
        while (context->is_continue) {
            while (context->is_continue) {
                bool processed = false;

                for (auto const &task : context->tasks) {
                    auto const result = task();

                    if (result == task_result::processed) {
                        processed = true;
                        std::this_thread::yield();
                        break;
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

void background_queue::stop() {
    if (this->_context) {
        this->_context->is_continue = false;
        this->_context = nullptr;
    }
}

background_queue_ptr background_queue::make_shared() {
    return background_queue_ptr(new background_queue{});
}
