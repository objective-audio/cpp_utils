//
//  thread.h
//

#pragma once

#include <functional>

namespace yas {
struct thread {
    static bool is_main();
    static void sleep_for_timeinterval(double const);

    static void perform_async_on_main(std::function<void(void)> &&);
    static void perform_sync_on_main(std::function<void(void)> &&);
};
}  // namespace yas
