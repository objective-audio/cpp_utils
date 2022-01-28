//
//  yas_index_range.h
//

#pragma once

#include <string>

namespace yas {
struct index_range {
    std::size_t index;
    std::size_t length;

    [[nodiscard]] bool operator==(index_range const &) const;
    [[nodiscard]] bool operator!=(index_range const &) const;

    [[nodiscard]] bool contains(std::size_t const index) const;

    [[nodiscard]] std::size_t next() const;

    [[nodiscard]] static index_range const &zero();
};
}  // namespace yas

namespace yas {
std::string to_string(index_range const &);
}

std::ostream &operator<<(std::ostream &os, yas::index_range const &);
