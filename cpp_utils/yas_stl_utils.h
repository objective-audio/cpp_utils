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
std::experimental::optional<T> min_empty_key(const std::map<T, U> &map);

template <typename T, typename P>
T filter(const T &collection, P predicate);

template <typename R, typename T, typename F>
auto map(T collection, F function) -> std::vector<R>;

template <typename T, typename P>
void erase_if(T &collection, P predicate);

template <typename T, typename F>
void enumerate(T &collection, F function);

template <typename T>
std::vector<T> to_vector(std::unordered_set<T> &set);

std::string to_lower(std::string const &);
std::string replaced(std::string const &source, std::string const &target, std::string const &replacement);
std::string joined(std::vector<std::string> const &components, std::string const &separator);
}

#include "yas_stl_utils_private.h"
