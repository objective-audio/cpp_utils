//
//  yas_worker.h
//

#pragma once

#include <chrono>
#include <functional>
#include <map>

namespace yas {
class worker;
using worker_ptr = std::shared_ptr<worker>;

struct worker final {
    enum class task_result {
        processed,
        unprocessed,
        completed,
    };

    using task_f = std::function<task_result(void)>;

    ~worker();

    void add_task(uint32_t const priority, task_f &&);
    void start();
    void stop();

    static worker_ptr make_shared();
    static worker_ptr make_shared(std::chrono::milliseconds const &);

   private:
    class resource;

    std::multimap<uint32_t, task_f> _tasks;
    std::shared_ptr<resource> _resource = nullptr;
    std::chrono::milliseconds _sleep_duration;

    worker(std::chrono::milliseconds const &);
};
}  // namespace yas
