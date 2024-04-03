//
//  yas_to_floating_point.cpp
//

#include "yas_to_floating_point.h"

float yas::to_float(std::string const &str) {
    try {
        return stof(str);
    } catch (...) {
        return 0.0f;
    }
}

double yas::to_double(std::string const &str) {
    try {
        return stod(str);
    } catch (...) {
        return 0.0;
    }
}
