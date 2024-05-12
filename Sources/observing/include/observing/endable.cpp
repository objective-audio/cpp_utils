//
//  observing_endable.cpp
//

#include "endable.h"

#include <cpp-utils/stl_utils.h>

#include "canceller_pool.h"

using namespace yas;
using namespace yas::observing;

endable::endable() {
}

endable::endable(std::function<canceller_ptr(void)> &&handler) {
    if (handler) {
        this->_handlers.emplace_back(std::move(handler));
    }
}

cancellable_ptr endable::end() {
    if (this->_handlers.size() > 1) {
        auto pool = canceller_pool::make_shared();

        for (auto const &handler : this->_handlers) {
            pool->add_canceller(handler());
        }

        this->_handlers.clear();

        return pool;
    } else if (this->_handlers.size() == 1) {
        auto canceller = this->_handlers.at(0)();
        this->_handlers.clear();
        return canceller;
    } else {
        return empty_canceller::make_shared();
    }
}

void endable::merge(endable &&other) {
    move_back_insert(this->_handlers, std::move(other._handlers));
    other._handlers.clear();
}
