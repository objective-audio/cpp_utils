//
//  observing_caller_index.cpp
//

#include "caller_index.hpp"

using namespace yas;
using namespace yas::observing;

bool caller_index::operator<(caller_index const &rhs) const {
    if (this->order != rhs.order) {
        return this->order < rhs.order;
    }

    return this->identifier < rhs.identifier;
}
