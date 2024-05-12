//
//  worker.h
//

#pragma once

#include <chrono>
#include <functional>
#include <map>

namespace yas {
class worker;
using worker_ptr = std::shared_ptr<worker>;
class worker_stub;
using worker_stub_ptr = std::shared_ptr<worker_stub>;

enum class worker_task_result {
    processed,
    unprocessed,
    completed,
};

struct workable {
    virtual ~workable() = default;

    using task_result = worker_task_result;
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

struct worker_stub final : workable {
    void add_task(uint32_t const priority, task_f &&) override;
    void start() override;
    void stop() override;

    std::vector<task_f> resource_tasks() const;
    bool is_started() const;
    void process();

    static worker_stub_ptr make_shared();

   private:
    std::multimap<uint32_t, task_f> _tasks;
    std::shared_ptr<resource> _resource = nullptr;

    worker_stub();
};
}  // namespace yas
