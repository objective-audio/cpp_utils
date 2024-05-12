//
//  endable.h
//

#pragma once

#include <vector>

#include "canceller.h"

namespace yas::observing {
class syncable;

struct endable final {
    endable();
    explicit endable(std::function<canceller_ptr(void)> &&);

    endable(endable &&) = default;
    endable &operator=(endable &&) = default;

    [[nodiscard]] cancellable_ptr end();

    void merge(endable &&);

   private:
    std::vector<std::function<canceller_ptr(void)>> _handlers;

    endable(endable const &) = delete;
    endable &operator=(endable const &) = delete;

    friend syncable;
};
}  // namespace yas::observing
