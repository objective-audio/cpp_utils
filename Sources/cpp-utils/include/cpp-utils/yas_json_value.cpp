//
//  yas_json.cpp
//

#include "yas_json_value.h"

using namespace yas;

json_value::json_value(std::nullopt_t const &) {
}

json_value::json_value(int64_t const value) : integer(value) {
}

json_value::json_value(double const value) : real(value) {
}

json_value::json_value(std::string const &value) : string(value) {
}

json_value::json_value(json_map &&value) : map(std::move(value)) {
}

json_value::json_value(json_vector &&value) : vector(std::move(value)) {
}

bool json_value::is_empty() const {
    auto const kinds = {json_value_kind::integer, json_value_kind::real, json_value_kind::string, json_value_kind::map,
                        json_value_kind::vector};
    for (auto const &kind : kinds) {
        if (this->has_value(kind)) {
            return false;
        }
    }
    return true;
}

bool json_value::has_any_value() const {
    return !this->is_empty();
}

bool json_value::has_value(json_value_kind const kind) const {
    switch (kind) {
        case json_value_kind::integer:
            return this->integer.has_value();
        case json_value_kind::real:
            return this->real.has_value();
        case json_value_kind::string:
            return this->string.has_value();
        case json_value_kind::map:
            return this->map.has_value();
        case json_value_kind::vector:
            return this->vector.has_value();
    }
}
