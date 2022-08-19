//
//  yas_delaying_caller.h
//

#pragma once

#include <functional>
#include <optional>

namespace yas {
class delaying_caller {
   public:
    using handler_f = std::function<void(void)>;

    delaying_caller();

    void request(handler_f);
    void cancel();

    void push();
    void pop();

    [[nodiscard]] bool is_suspending() const;

   private:
    std::optional<handler_f> _handler;
    std::size_t _push_count;
};
}  // namespace yas
