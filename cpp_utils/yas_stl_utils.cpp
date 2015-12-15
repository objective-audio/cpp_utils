//
//  yas_stl_utils.cpp
//

#include "yas_stl_utils.h"

#include <iostream>

std::string yas::to_lower(const std::string &string) {
    std::string lower_string = string;
    std::transform(lower_string.begin(), lower_string.end(), lower_string.begin(), ::tolower);
    return lower_string;
}
