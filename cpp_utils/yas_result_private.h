//
//  yas_result_private.h
//

#pragma once

#include "yas_exception.h"
#include "yas_types.h"

namespace yas {
template <typename T, typename U>
result<T, U>::result(T const &value) : _value(std::experimental::make_optional<T>(T(value))), _error(nullopt) {
}

template <typename T, typename U>
result<T, U>::result(U const &error) : _value(nullopt), _error(std::experimental::make_optional<U>(U(error))) {
}

template <typename T, typename U>
result<T, U>::result(T &&value) : _value(std::experimental::make_optional<T>(std::move(value))), _error(nullopt) {
}

template <typename T, typename U>
result<T, U>::result(U &&error) : _value(nullopt), _error(std::experimental::make_optional<U>(std::move(error))) {
}

template <typename T, typename U>
result<T, U>::~result() = default;

template <typename T, typename U>
result<T, U>::result(result<T, U> const &other) : _value(other._value), _error(other._error) {
}

template <typename T, typename U>
result<T, U>::result(result<T, U> &&other) : _value(std::move(other._value)), _error(std::move(other._error)) {
}

template <typename T, typename U>
result<T, U> &result<T, U>::operator=(result<T, U> const &rhs) {
    this->_value = rhs._value;
    this->_error = rhs._error;

    return *this;
}

template <typename T, typename U>
result<T, U> &result<T, U>::operator=(result<T, U> &&rhs) {
    this->_value = std::move(rhs._value);
    this->_error = std::move(rhs._error);

    return *this;
}

template <typename T, typename U>
result<T, U>::operator bool() const {
    return is_success();
}

template <typename T, typename U>
bool result<T, U>::is_success() const {
    if (_value) {
        return true;
    } else if (_error) {
        return false;
    } else {
        throw std::logic_error(std::string(__PRETTY_FUNCTION__) + " : value or error are not found.");
        return false;
    }
}

template <typename T, typename U>
T const &result<T, U>::value() const {
    return *_value;
}

template <typename T, typename U>
T &result<T, U>::value() {
    return *_value;
}

template <typename T, typename U>
U const &result<T, U>::error() const {
    return *_error;
}

template <typename T, typename U>
U &result<T, U>::error() {
    return *_error;
}

template <typename T, typename U>
std::experimental::optional<T> result<T, U>::value_opt() const {
    return _value;
}

template <typename T, typename U>
std::experimental::optional<U> result<T, U>::error_opt() const {
    return _error;
}
}
