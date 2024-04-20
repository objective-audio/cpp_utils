//
//  yas_index_range.cpp
//

#include "yas_index_range.h"

using namespace yas;

bool index_range::operator==(index_range const &rhs) const {
    return this->index == rhs.index && this->length == rhs.length;
}

bool index_range::operator!=(index_range const &rhs) const {
    return !(*this == rhs);
}

bool index_range::contains(std::size_t const idx) const {
    return this->index <= idx && idx < this->next();
}

std::size_t index_range::next() const {
    return this->index + this->length;
}

index_range const &index_range::zero() {
    static index_range const _zero{.index = 0, .length = 0};
    return _zero;
}

std::string yas::to_string(index_range const &range) {
    return "{index:" + std::to_string(range.index) + ", length:" + std::to_string(range.length) + "}";
}

std::ostream &operator<<(std::ostream &os, yas::index_range const &value) {
    os << to_string(value);
    return os;
}
