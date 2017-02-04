//
//  yas_boolean.cpp
//

#include "yas_boolean.h"
#include <utility>

using namespace yas;

boolean::boolean() : _value(false) {
}

boolean::boolean(bool const b) : _value(b) {
}

boolean::boolean(boolean const &rhs) : _value(rhs._value) {
}

boolean::boolean(boolean &&rhs) noexcept : _value(std::move(rhs._value)) {
}

boolean &boolean::operator=(boolean const &rhs) {
    _value = rhs._value;
    return *this;
}

boolean &boolean::operator=(boolean &&rhs) {
    _value = std::move(rhs._value);
    return *this;
}

bool boolean::operator==(boolean const &rhs) const {
    return _value == rhs._value;
}

bool boolean::operator!=(boolean const &rhs) const {
    return _value != rhs._value;
}

bool boolean::operator<(boolean const &rhs) const {
    return _value < rhs._value;
}

bool boolean::operator<=(boolean const &rhs) const {
    return _value <= rhs._value;
}

bool boolean::operator>(boolean const &rhs) const {
    return _value > rhs._value;
}

bool boolean::operator>=(boolean const &rhs) const {
    return _value >= rhs._value;
}

boolean::operator bool() const {
    return _value;
}
