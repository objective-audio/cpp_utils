//
//  yas_worker.h
//

#pragma once

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

   private:
    class resource;

    std::multimap<uint32_t, task_f> _tasks;
    std::shared_ptr<resource> _resource = nullptr;

    worker();
};
}  // namespace yas
