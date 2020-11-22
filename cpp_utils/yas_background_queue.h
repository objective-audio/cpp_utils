//
//  yas_playing_background_queue.h
//

#pragma once

#include <functional>
#include <map>

namespace yas {
class background_queue;
using background_queue_ptr = std::shared_ptr<background_queue>;

struct background_queue final {
    enum class task_result {
        processed,
        unprocessed,
    };

    using task_f = std::function<task_result(void)>;

    ~background_queue();

    void add_task(uint32_t const priority, task_f &&);
    void start();
    void stop();

    static background_queue_ptr make_shared();

   private:
    class context;

    std::multimap<uint32_t, task_f> _tasks;
    std::shared_ptr<context> _context = nullptr;

    background_queue();
};
}  // namespace yas
