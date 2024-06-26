//
//  stl_utils.h
//

#pragma once

#include <array>
#include <map>
#include <memory>
#include <optional>
#include <set>
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

namespace yas {
template <typename T, typename U>
std::optional<T> min_empty_key(std::map<T, U> const &map);

template <typename T, typename F>
std::optional<std::size_t> index(std::vector<T> const &vector, F function);

template <typename T>
std::optional<std::size_t> index(std::vector<T> const &vector, T const &value);

template <typename T>
bool contains(std::vector<T> const &vector, T const &value);

template <typename T, typename F>
bool contains_if(std::vector<T> const &vector, F function);

template <typename T, typename P>
T filter(T const &collection, P predicate);

template <typename T, typename P>
std::optional<typename T::value_type> first(T const &collection, P predicate);

template <typename T>
void reverse(std::vector<T> &vector);

template <typename T>
void erase_at(std::vector<T> &vector, std::size_t const idx);

template <typename T, typename U>
void erase_if_exists(std::unordered_map<T, U> &map, T const &key);

template <typename T, typename F>
void for_each(T &collection, F function);

template <typename T>
std::vector<T> connect(std::vector<T> vec_a, std::vector<T> vec_b);

template <typename T>
void move_back_insert(std::vector<T> &a, std::vector<T> b);

template <typename T>
void move_insert(T &a, T b);

template <typename T, typename K>
void move_insert(T &a, T &b, K const &k);

template <typename T, typename U>
U pull(std::unordered_map<T, U> &map, T const &key);

template <typename T, typename U>
void replace(std::unordered_map<T, U> &map, T const &key, U value);

template <typename R, typename T, typename F>
std::vector<R> to_vector(T const &collection, F function);

template <typename T>
std::vector<T> to_vector(std::unordered_set<T> &&set);
template <typename T>
std::vector<T> to_vector(std::unordered_set<T> const &set);

template <typename R, typename T, typename F>
std::vector<R> map(T const &collection, F function);

template <typename R, typename T, typename F>
std::vector<R> filter_map(T const &collection, F function);

template <typename T>
std::unordered_set<T> to_unordered_set(std::vector<T> &&vector);
template <typename T>
std::unordered_set<T> to_unordered_set(std::vector<T> const &vector);

template <typename K, typename T, typename F>
std::unordered_map<K, T> to_unordered_map(std::vector<T> &&vector, F function);
template <typename K, typename T, typename F>
std::unordered_map<K, T> to_unordered_map(std::vector<T> const &vector, F function);
template <typename K, typename T, typename F>
std::map<K, T> to_map(std::vector<T> &&vector, F function);
template <typename K, typename T, typename F>
std::map<K, T> to_map(std::vector<T> const &vector, F function);

template <typename E, typename T, typename F>
std::set<E> to_set(T const &collection, F function);

std::string to_lower(std::string);
std::string replaced(std::string source, std::string const &target, std::string const &replacement);
std::string joined(std::vector<std::string> const &components, std::string const &separator);
std::vector<std::string> split(std::string const &text, char const separator);

template <typename T, typename F>
std::string joined(T const &collection, std::string const &separator, F function);

template <typename T>
std::weak_ptr<T> to_weak(std::shared_ptr<T> const &shared);
template <typename T>
std::weak_ptr<T> to_weak(std::shared_ptr<T> &&shared);

template <typename T, std::size_t N>
auto to_tuple(std::array<T, N> const &);

template <typename T, std::size_t N>
auto to_tuple(std::vector<T> const &);

template <typename K, typename T>
std::map<K, std::shared_ptr<T>> lock_values(std::map<K, std::weak_ptr<T>> const &map);

template <typename T>
bool equal(std::vector<T> const &, std::vector<T> const &);
}  // namespace yas

#include "stl_utils_private.h"
