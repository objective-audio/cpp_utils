//
//  yas_exception.cpp
//

#include "yas_exception.h"

#include <CoreFoundation/CoreFoundation.h>

#include <exception>

using namespace yas;

void yas::raise_with_reason(std::string const &reason) {
    throw std::runtime_error(reason);
}

void yas::raise_if_main_thread() {
    if (CFEqual(CFRunLoopGetCurrent(), CFRunLoopGetMain())) {
        throw std::runtime_error("invalid call on main thread.");
    }
}

void yas::raise_if_sub_thread() {
    if (!CFEqual(CFRunLoopGetCurrent(), CFRunLoopGetMain())) {
        throw std::runtime_error("invalid call on sub thread.");
    }
}
