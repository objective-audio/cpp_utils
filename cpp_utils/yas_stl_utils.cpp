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

std::string yas::replaced(const std::string &source, const std::string &target, const std::string &replacement) {
    std::string destination = source;
    std::string::size_type pos = 0;
    while (pos = destination.find(target, pos), pos != std::string::npos) {
        destination.replace(pos, target.length(), replacement);
        pos += replacement.length();
    }
    return destination;
}
