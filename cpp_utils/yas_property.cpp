//
//  yas_property.cpp
//

#include "yas_property.h"

std::string yas::to_string(yas::property_method const method) {
    switch (method) {
        case yas::property_method::will_change:
            return "will_change";
        case yas::property_method::did_change:
            return "did_change";
    }
}
