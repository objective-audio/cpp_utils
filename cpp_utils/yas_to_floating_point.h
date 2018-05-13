//
//  yas_to_floating_point.h
//

#pragma once

#include <limits.h>
#include <string>

namespace yas {
float to_float(std::string const &str) {
    try {
        return stof(str);
    } catch (...) {
        return 0.0f;
    }
}

double to_double(std::string const &str) {
    try {
        return stod(str);
    } catch (...) {
        return 0.0;
    }
}
}
