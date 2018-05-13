//
//  yas_delaying_caller.h
//

#pragma once

#include <functional>

namespace yas {
class delaying_caller {
   public:
    using handler_f = std::function<void(void)>;

    delaying_caller();

    void request(handler_f);
    void cancel();

    void push();
    void pop();

   private:
    handler_f _handler;
    std::size_t _push_count;
};
}  // namespace yas
