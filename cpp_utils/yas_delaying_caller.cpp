//
//  yas_delaying_caller.cpp
//

#include "yas_delaying_caller.h"

using namespace yas;

delaying_caller::delaying_caller() : _handler(nullptr), _push_count(0) {
}

void delaying_caller::request(handler_f handler) {
    if (!handler) {
        throw "argument is null.";
    }

    if (_push_count == 0) {
        if (_handler) {
            throw "_handler always exists";
        }

        handler();
    } else {
        _handler = std::move(handler);
    }
}

void delaying_caller::push() {
    ++_push_count;
}

void delaying_caller::pop() {
    if (_push_count == 0) {
        throw "_push_count decrease failed";
    }

    --_push_count;

    if (_push_count == 0 && _handler) {
        _handler();
        _handler = nullptr;
    }
}