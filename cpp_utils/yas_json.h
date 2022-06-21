//
//  yas_json.h
//

#pragma once

#include <cpp_utils/yas_json_value.h>

namespace yas {
std::string to_json_string(json_value const &);
json_value to_json_value(std::string const &);
}  // namespace yas
