//
//  yas_stl_utils.h
//

#pragma once

#include <experimental/optional>
#include <map>
#include <memory>
#include <string>
#include <unordered_set>
#include <vector>

namespace yas {
template <typename T, typename U>
std::experimental::optional<T> min_empty_key(std::map<T, U> const &map);

template <typename T, typename P>
T filter(T const &collection, P predicate);

template <typename R, typename T, typename F>
std::vector<R> map(T const &collection, F function);

template <typename T, typename P>
void erase_if(T &collection, P predicate);

template <typename T, typename F>
void enumerate(T &collection, F function);

template <typename T>
std::vector<T> connect(std::vector<T> vec_a, std::vector<T> vec_b);

template <typename T>
std::vector<T> to_vector(std::unordered_set<T> set);

std::string to_lower(std::string);
std::string replaced(std::string source, std::string const &target, std::string const &replacement);
std::string joined(std::vector<std::string> const &components, std::string const &separator);

template <typename T, typename F>
std::string joined(T const &collection, std::string const &separator, F function);
}

#include "yas_stl_utils_private.h"
