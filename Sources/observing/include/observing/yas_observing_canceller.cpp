//
//  yas_observing_canceller.cpp
//

#include "yas_observing_canceller.h"

#include "yas_observing_canceller_pool.h"

using namespace yas;
using namespace yas::observing;

#pragma mark - canceller

canceller::canceller(remover_f &&handler) : _handler(std::move(handler)) {
}

canceller::~canceller() {
    if (!this->_cancelled) {
        this->_handler(this->identifier());
    }
}

void canceller::cancel() {
    if (!this->_cancelled) {
        this->_handler(this->identifier());
        this->_cancelled = true;
    }
}

void canceller::ignore() {
    this->_cancelled = true;
}

bool canceller::has_cancellable() const {
    return !this->_cancelled;
}

void canceller::add_to(canceller_pool &pool) {
    pool.add_canceller(this->_weak_canceller.lock());
}

void canceller::set_to(cancellable_ptr &canceller) {
    canceller = this->_weak_canceller.lock();
}

uintptr_t canceller::identifier() const {
    return reinterpret_cast<uintptr_t>(this);
}

std::shared_ptr<canceller> canceller::make_shared(remover_f &&handler) {
    auto shared = canceller_ptr(new canceller{std::move(handler)});
    shared->_weak_canceller = shared;
    return shared;
}

#pragma mark - empty_canceller

std::shared_ptr<empty_canceller> empty_canceller::make_shared() {
    return std::shared_ptr<empty_canceller>(new empty_canceller{});
}

empty_canceller::empty_canceller() {
}

void empty_canceller::cancel() {
}

bool empty_canceller::has_cancellable() const {
    return false;
}

void empty_canceller::add_to(canceller_pool &) {
}

void empty_canceller::set_to(cancellable_ptr &) {
}
