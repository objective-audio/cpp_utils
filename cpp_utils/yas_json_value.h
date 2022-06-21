//
//  yas_json_value.h
//

#pragma once

#include <cstdint>
#include <map>
#include <optional>
#include <string>
#include <vector>

namespace yas {
enum class json_value_kind {
    integer,
    real,
    string,
    map,
    vector,
};

struct json_value;

using json_vector = std::vector<json_value>;
using json_map = std::map<std::string, json_value>;

struct json_value final {
    std::optional<int64_t> integer;
    std::optional<double> real;
    std::optional<std::string> string;
    std::optional<json_map> map;
    std::optional<json_vector> vector;

    json_value(std::nullopt_t const &);
    explicit json_value(int64_t const);
    explicit json_value(double const);
    explicit json_value(std::string const &);
    explicit json_value(json_map &&);
    explicit json_value(json_vector &&);

    bool is_empty() const;
    bool has_any_value() const;
    bool has_value(json_value_kind const) const;
};
}  // namespace yas
