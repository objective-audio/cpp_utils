//
//  stl_utils_private.h
//

#pragma once

#include <algorithm>
#include <iterator>
#include <sstream>
#include <tuple>

namespace yas {
template <typename T, typename U>
std::optional<T> min_empty_key(std::map<T, U> const &map) {
    auto map_size = map.size();

    if (map_size == 0) {
        return 0;
    }

    if (map_size >= std::numeric_limits<T>::max()) {
        return std::nullopt;
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

template <typename T, typename F>
std::optional<std::size_t> index(std::vector<T> const &vector, F function) {
    auto it = std::find_if(vector.begin(), vector.end(), function);

    if (it != vector.end()) {
        return std::distance(vector.begin(), it);
    } else {
        return std::nullopt;
    }
}

template <typename T>
std::optional<std::size_t> index(std::vector<T> const &vector, T const &target) {
    return index(vector, [&target](auto const &value) { return target == value; });
}

template <typename T>
bool contains(std::vector<T> const &vector, T const &value) {
    return std::find(vector.begin(), vector.end(), value) != vector.end();
}

template <typename T, typename F>
bool contains_if(std::vector<T> const &vector, F function) {
    return std::find_if(vector.begin(), vector.end(), function) != vector.end();
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
std::optional<typename T::value_type> first(T const &collection, P predicate) {
    for (auto &obj : collection) {
        if (predicate(obj)) {
            return obj;
        }
    }
    return std::nullopt;
}

template <typename T>
void reverse(std::vector<T> &vector) {
    std::reverse(vector.begin(), vector.end());
}

template <typename T>
void erase_at(std::vector<T> &vector, std::size_t const idx) {
    vector.erase(vector.begin() + idx);
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
std::vector<R> to_vector(T const &collection, F function) {
    std::vector<R> vector;
    vector.reserve(collection.size());

    for (auto &obj : collection) {
        vector.emplace_back(function(obj));
    }

    return vector;
}

template <typename T>
std::vector<T> to_vector(std::unordered_set<T> &&set) {
    std::vector<T> vector;
    vector.reserve(set.size());
    std::move(set.begin(), set.end(), std::back_inserter(vector));
    set.clear();
    return vector;
}

template <typename T>
std::vector<T> to_vector(std::unordered_set<T> const &set) {
    std::vector<T> vector;
    vector.reserve(set.size());
    std::copy(set.begin(), set.end(), std::back_inserter(vector));
    return vector;
}

template <typename R, typename T, typename F>
std::vector<R> map(T const &collection, F function) {
    std::vector<R> vector;
    vector.reserve(collection.size());

    for (auto const &obj : collection) {
        vector.emplace_back(function(obj));
    }

    return vector;
}

template <typename R, typename T, typename F>
std::vector<R> filter_map(T const &collection, F function) {
    std::vector<R> vector;

    for (auto const &obj : collection) {
        if (auto opt_value = function(obj); opt_value.has_value()) {
            vector.emplace_back(opt_value.value());
        }
    }

    return vector;
}

template <typename T>
std::unordered_set<T> to_unordered_set(std::vector<T> &&vector) {
    std::unordered_set<T> set;
    std::move(vector.begin(), vector.end(), std::inserter(set, set.end()));
    return set;
}

template <typename T>
std::unordered_set<T> to_unordered_set(std::vector<T> const &vector) {
    std::unordered_set<T> set;
    std::copy(vector.begin(), vector.end(), std::inserter(set, set.end()));
    return set;
}

template <typename K, typename T, typename F>
std::unordered_map<K, T> to_unordered_map(std::vector<T> &&vector, F function) {
    std::unordered_map<K, T> map;

    for (T &value : vector) {
        map.emplace(std::make_pair(function(value), std::move(value)));
    }

    return map;
}

template <typename K, typename T, typename F>
std::unordered_map<K, T> to_unordered_map(std::vector<T> const &vector, F function) {
    std::unordered_map<K, T> map;

    for (T const &value : vector) {
        map.emplace(std::make_pair(function(value), value));
    }

    return map;
}

template <typename K, typename T, typename F>
std::map<K, T> to_map(std::vector<T> &&vector, F function) {
    std::map<K, T> map;

    for (T &value : vector) {
        map.emplace(std::make_pair(function(value), std::move(value)));
    }

    return map;
}

template <typename K, typename T, typename F>
std::map<K, T> to_map(std::vector<T> const &vector, F function) {
    std::map<K, T> map;

    for (T const &value : vector) {
        map.emplace(std::make_pair(function(value), value));
    }

    return map;
}

template <typename E, typename T, typename F>
std::set<E> to_set(T const &collection, F function) {
    std::set<E> set;

    for (auto const &value : collection) {
        set.emplace(function(value));
    }

    return set;
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
std::weak_ptr<T> to_weak(std::shared_ptr<T> const &shared) {
    return std::weak_ptr<T>{shared};
}

template <typename T>
std::weak_ptr<T> to_weak(std::shared_ptr<T> &&shared) {
    auto lvalue_shared = shared;
    return std::weak_ptr<T>{lvalue_shared};
}

template <typename T, std::size_t N, std::size_t... Indices>
auto __to_tuple__(std::array<T, N> const &array, std::index_sequence<Indices...>) {
    return std::make_tuple(array[Indices]...);
}

template <typename T, std::size_t... Indices>
auto __to_tuple__(std::vector<T> const &vector, std::index_sequence<Indices...>) {
    return std::make_tuple(vector[Indices]...);
}

template <typename T, std::size_t N>
auto to_tuple(std::array<T, N> const &array) {
    return __to_tuple__<T, N>(array, std::make_index_sequence<N>());
}

template <typename T, std::size_t N>
auto to_tuple(std::vector<T> const &vector) {
    return __to_tuple__<T>(vector, std::make_index_sequence<N>());
}

template <typename K, typename T>
std::map<K, std::shared_ptr<T>> lock_values(std::map<K, std::weak_ptr<T>> const &map) {
    std::map<K, std::shared_ptr<T>> locked_map;

    for (auto &pair : map) {
        if (std::shared_ptr<T> shared = pair.second.lock()) {
            locked_map.insert(std::make_pair(pair.first, std::move(shared)));
        }
    }

    return locked_map;
}

template <typename T>
bool equal(std::vector<T> const &lhs, std::vector<T> const &rhs) {
    return std::equal(lhs.begin(), lhs.end(), rhs.begin(), rhs.end());
}
}  // namespace yas
