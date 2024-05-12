//
//  caller_index.hpp
//

#pragma once

#include <cstddef>
#include <cstdint>

namespace yas::observing {
struct caller_index {
    uintptr_t identifier;
    std::size_t order;

    bool operator<(caller_index const &) const;
};
}  // namespace yas::observing
