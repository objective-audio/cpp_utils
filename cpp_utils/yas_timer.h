//
//  yas_timer.h
//

#pragma once

#include <functional>
#include "yas_base.h"

namespace yas {
struct timer final {
    class impl;

    timer(double const time_interval, bool const repeats, std::function<void(void)> handler);

    timer(timer &&) = default;
    timer &operator=(timer &&) = default;

    void invalidate();

   private:
    std::shared_ptr<impl> _impl;

    timer(timer const &) = delete;
    timer &operator=(timer const &) = delete;
};
}  // namespace yas
