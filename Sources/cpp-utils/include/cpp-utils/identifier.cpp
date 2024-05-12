//
//  identifier.cpp
//

#include "identifier.h"

using namespace yas;

identifier::identifier() : _raw(std::make_shared<std::nullptr_t>(nullptr)) {
}

identifier::~identifier() {
    this->_raw = nullptr;
}

identifier::identifier(identifier const &other) {
    this->_raw = other._raw;
}

identifier::identifier(identifier &&other) {
    this->_raw = std::move(other._raw);
    other._raw = nullptr;
}

identifier &identifier::operator=(identifier const &rhs) {
    this->_raw = rhs._raw;
    return *this;
}

identifier &identifier::operator=(identifier &&rhs) {
    this->_raw = std::move(rhs._raw);
    rhs._raw = nullptr;
    return *this;
}

bool identifier::operator==(identifier const &rhs) const {
    if (this->_raw && rhs._raw) {
        return this->_raw == rhs._raw;
    } else {
        return false;
    }
}

bool identifier::operator!=(identifier const &rhs) const {
    return !(*this == rhs);
}

bool identifier::operator<(identifier const &rhs) const {
    return this->raw_value() < rhs.raw_value();
}

uintptr_t identifier::raw_value() const {
    if (this->_raw) {
        return reinterpret_cast<uintptr_t>(this->_raw.get());
    } else {
        return 0;
    }
}

std::string yas::to_string(identifier const &identifier) {
    return std::to_string(identifier.raw_value());
}

std::ostream &operator<<(std::ostream &os, yas::identifier const &value) {
    os << yas::to_string(value);
    return os;
}
