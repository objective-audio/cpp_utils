//
//  yas_observing_syncable.cpp.h
//

#include "yas_observing_syncable.h"

#include <cpp-utils/yas_stl_utils.h>

#include "yas_observing_canceller_pool.h"

using namespace yas;
using namespace yas::observing;

syncable::syncable() {
}

syncable::syncable(std::function<canceller_ptr(bool const)> &&handler) {
    if (handler) {
        this->_sync_handlers.emplace_back(std::move(handler));
    }
}

cancellable_ptr syncable::sync() {
    return this->_call_handlers(true);
}

cancellable_ptr syncable::end() {
    return this->_call_handlers(false);
}

void syncable::merge(syncable &&other) {
    move_back_insert(this->_sync_handlers, std::move(other._sync_handlers));
    move_back_insert(this->_end_handlers, std::move(other._end_handlers));
    other._sync_handlers.clear();
    other._end_handlers.clear();
}

void syncable::merge(endable &&other) {
    move_back_insert(this->_end_handlers, std::move(other._handlers));
    other._handlers.clear();
}

endable syncable::to_endable() {
    endable result;

    if (this->_sync_handlers.size() > 0) {
        for (auto const &handler : this->_sync_handlers) {
            result._handlers.emplace_back([handler] { return handler(false); });
        }
        this->_sync_handlers.clear();
    }

    move_back_insert(result._handlers, std::move(this->_end_handlers));
    this->_end_handlers.clear();

    return result;
}

cancellable_ptr syncable::_call_handlers(bool const sync) {
    auto const handler_count = this->_sync_handlers.size() + this->_end_handlers.size();

    if (handler_count > 1) {
        auto pool = canceller_pool::make_shared();

        for (auto const &handler : this->_sync_handlers) {
            pool->add_canceller(handler(sync));
        }

        for (auto const &handler : this->_end_handlers) {
            pool->add_canceller(handler());
        }

        this->_sync_handlers.clear();
        this->_end_handlers.clear();

        return pool;
    } else if (handler_count == 1) {
        if (this->_sync_handlers.size() > 0) {
            auto canceller = this->_sync_handlers.at(0)(sync);
            this->_sync_handlers.clear();
            return canceller;
        } else if (this->_end_handlers.size() > 0) {
            auto canceller = this->_end_handlers.at(0)();
            this->_end_handlers.clear();
            return canceller;
        } else {
            throw std::runtime_error("unreachable");
        }
    } else {
        return empty_canceller::make_shared();
    }
}
