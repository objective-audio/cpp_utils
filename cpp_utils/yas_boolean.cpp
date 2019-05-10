//
//  yas_boolean.cpp
//

#include "yas_boolean.h"
#include <utility>

using namespace yas;

boolean::boolean() : _value(false) {
}

boolean::boolean(boolean const &rhs) : _value(rhs._value) {
}

boolean::boolean(boolean &&rhs) noexcept : _value(std::move(rhs._value)) {
}

boolean::boolean(bool const &b) : _value(b) {
}

boolean::boolean(bool &&b) noexcept : _value(std::move(b)) {
}

boolean &boolean::operator=(boolean const &rhs) {
    this->_value = rhs._value;
    return *this;
}

boolean &boolean::operator=(boolean &&rhs) {
    this->_value = std::move(rhs._value);
    return *this;
}

bool boolean::operator==(boolean const &rhs) const {
    return this->_value == rhs._value;
}

bool boolean::operator!=(boolean const &rhs) const {
    return this->_value != rhs._value;
}

bool boolean::operator<(boolean const &rhs) const {
    return this->_value < rhs._value;
}

bool boolean::operator<=(boolean const &rhs) const {
    return this->_value <= rhs._value;
}

bool boolean::operator>(boolean const &rhs) const {
    return this->_value > rhs._value;
}

bool boolean::operator>=(boolean const &rhs) const {
    return this->_value >= rhs._value;
}

boolean::operator bool() const {
    return this->_value;
}

bool const &boolean::raw() const {
    return this->_value;
}

std::string yas::to_string(boolean const &boolean) {
    return boolean != false ? "true" : "false";
}
