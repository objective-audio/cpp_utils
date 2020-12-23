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

struct workable {
    virtual ~workable() = default;

    enum class task_result {
        processed,
        unprocessed,
        completed,
    };

    using task_f = std::function<task_result(void)>;

    virtual void add_task(uint32_t const priority, task_f &&) = 0;
    virtual void start() = 0;
    virtual void stop() = 0;

   protected:
    class resource;
};

using workable_ptr = std::shared_ptr<workable>;

struct worker final : workable {
    ~worker();

    void add_task(uint32_t const priority, task_f &&) override;
    void start() override;
    void stop() override;

    static worker_ptr make_shared();
    static worker_ptr make_shared(std::chrono::milliseconds const &);

   private:
    std::multimap<uint32_t, task_f> _tasks;
    std::shared_ptr<resource> _resource = nullptr;
    std::chrono::milliseconds _sleep_duration;

    worker(std::chrono::milliseconds const &);
};
}  // namespace yas
