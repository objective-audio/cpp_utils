//
//  json_utils.h
//

#pragma once

#include <cpp-utils/json_value.h>

namespace yas::json_utils {
json_value to_json_value(id object);
id to_json_object(json_value const &value);
}  // namespace yas::json_utils
