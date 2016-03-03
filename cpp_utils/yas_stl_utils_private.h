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

template <typename T>
std::experimental::optional<std::size_t> index(std::vector<T> const &vector, T const &target) {
    auto it = std::find_if(vector.begin(), vector.end(), [&target](auto const &value) { return target == value; });

    if (it != vector.end()) {
        return std::distance(vector.begin(), it);
    } else {
        return yas::nullopt;
    }
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

template <typename T, typename U>
void erase_if_exists(std::unordered_map<T, U> &map, T const &key) {
    if (map.count(key) > 0) {
        map.erase(key);
    }
}

template <typename T, typename F>
void for_each(T &collection, F function) {
    auto it = collection.begin();

    while (it != collection.end()) {
        it = function(it);
    }
}

template <typename T>
std::vector<T> connect(std::vector<T> vec_a, std::vector<T> vec_b) {
    vec_a.reserve(vec_a.size() + vec_b.size());
    std::move(vec_b.begin(), vec_b.end(), std::back_inserter(vec_a));
    return std::move(vec_a);
}

template <typename T>
void move_back_insert(std::vector<T> &a, std::vector<T> b) {
    a.reserve(a.size() + b.size());
    std::move(b.begin(), b.end(), std::back_inserter(a));
}

template <typename T>
void move_insert(T &a, T b) {
    a.insert(std::make_move_iterator(b.begin()), std::make_move_iterator(b.end()));
}

template <typename T, typename K>
void move_insert(T &a, T &b, K const &k) {
    a.emplace(*std::make_move_iterator(b.find(k)));
    b.erase(k);
}

template <typename T, typename U>
U pull(std::unordered_map<T, U> &map, T const &key) {
    auto value = std::move(map.at(key));
    map.erase(key);
    return value;
}

template <typename T, typename U>
void replace(std::unordered_map<T, U> &map, T const &key, U value) {
    if (map.count(key) > 0) {
        map.erase(key);
    }
    map.emplace(std::make_pair(key, std::move(value)));
}

template <typename R, typename T, typename F>
std::vector<R> to_vector(T collection, F function) {
    std::vector<R> vector;
    vector.reserve(collection.size());

    for (auto &obj : collection) {
        vector.emplace_back(function(obj));
    }

    return vector;
}

template <typename T>
std::vector<T> to_vector(std::unordered_set<T> set) {
    std::vector<T> vector;
    vector.reserve(set.size());
    std::move(set.begin(), set.end(), std::back_inserter(vector));
    return vector;
}

template <typename K, typename T, typename F>
std::unordered_map<K, T> to_map(std::vector<T> collection, F function) {
    std::unordered_map<K, T> map;

    for (T &value : collection) {
        map.emplace(std::make_pair(function(value), std::move(value)));
    }

    return map;
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

template <typename T>
std::weak_ptr<T> to_weak(std::shared_ptr<T> shared) {
    return shared;
}
}
