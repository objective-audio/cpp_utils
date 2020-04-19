//
//  yas_ns_utils.h
//

#pragma once

#include <string>
#include "yas_objc_ptr.h"

@class NSString;

namespace yas {
objc_ptr<NSString *> to_ns_object(std::string const &);
}
