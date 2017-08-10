//
//  yas_timer.h
//

#pragma once

#include "yas_base.h"
#include <functional>

namespace yas {
class timer : public base {
    class impl;

   public:
    timer(double const time_interval, bool const repeats, std::function<void(void)> handler);
    timer(std::nullptr_t);

    void invalidate();
};
}
