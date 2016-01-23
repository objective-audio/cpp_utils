//
//  yas_stl_utils_private.h
//

#pragma once

#include <sstream>
#include "yas_types.h"

namespace yas {
template <typename T, typename U>
std::experimental::optional<T> min_empty_key(std::map<T, U> const &map) {
    auto map_size = map.size();

    if (map_size == 0) {
        return 0;
    }

    if (map_size >= std::numeric_limits<T>::max()) {
        return nullopt;
    }

    T next = map.rbegin()->first + 1;
    if (next == map.size()) {
        return next;
    }

    next = 0;
    while (map.count(next) > 0) {
        ++next;
    }
    return next;
}

template <typename T, typename P>
T filter(T const &collection, P predicate) {
    T filtered;

    for (auto &obj : collection) {
        if (predicate(obj)) {
            filtered.insert(filtered.end(), obj);
        }
    }

    return filtered;
}

template <typename R, typename T, typename F>
std::vector<R> map(T const &collection, F function) {
    std::vector<R> mapped;

    for (auto &obj : collection) {
        mapped.emplace_back(function(obj));
    }

    return mapped;
}

template <typename T, typename P>
void erase_if(T &collection, P predicate) {
    auto it = collection.begin();

    while (it != collection.end()) {
        if (predicate(*it)) {
            it = collection.erase(it);
        } else {
            ++it;
        }
    }
}

template <typename T, typename F>
void enumerate(T &collection, F function) {
    auto it = collection.begin();

    while (it != collection.end()) {
        it = function(it);
    }
}

template <typename T>
std::vector<T> to_vector(std::unordered_set<T> &set) {
    return std::vector<T>{set.begin(), set.end()};
}

template <typename T, typename F>
std::string joined(T const &collection, std::string const &separator, F function) {
    std::ostringstream stream;
    bool is_first = true;
    for (auto const &component : collection) {
        if (is_first) {
            is_first = false;
        } else {
            stream << separator;
        }
        stream << function(component);
    }
    return stream.str();
}
}
