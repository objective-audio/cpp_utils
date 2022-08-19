//
//  yas_delaying_caller.cpp
//

#include "yas_delaying_caller.h"

using namespace yas;

delaying_caller::delaying_caller() : _handler(std::nullopt), _push_count(0) {
}

void delaying_caller::request(handler_f handler) {
    if (!handler) {
        throw std::invalid_argument("argument is null.");
    }

    if (this->_push_count == 0) {
        if (this->_handler) {
            throw std::runtime_error("_handler always exists.");
        }

        handler();
    } else {
        this->_handler = std::move(handler);
    }
}

void delaying_caller::cancel() {
    this->_handler = std::nullopt;
}

void delaying_caller::push() {
    ++this->_push_count;
}

void delaying_caller::pop() {
    if (this->_push_count == 0) {
        throw std::runtime_error("_push_count decrease failed");
    }

    --this->_push_count;

    if (this->_push_count == 0 && this->_handler) {
        this->_handler.value()();
        this->_handler = std::nullopt;
    }
}

bool delaying_caller::is_suspending() const {
    return this->_push_count > 0;
}
