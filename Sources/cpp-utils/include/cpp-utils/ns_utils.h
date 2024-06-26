//
//  ns_utils.h
//

#pragma once

#include <cpp-utils/objc_ptr.h>
#include <string>

@class NSString;

namespace yas {
objc_ptr<NSString *> to_ns_object(std::string const &);
}
