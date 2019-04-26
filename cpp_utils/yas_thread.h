//
//  yas_thread.h
//

#pragma once

namespace yas {
struct thread {
    static bool is_main();
    static void sleep_for_timeinterval(double const);
};
}  // namespace yas
