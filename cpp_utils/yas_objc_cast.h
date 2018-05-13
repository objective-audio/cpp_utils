//
//  yas_objc_cast.h
//

#pragma once

#include <objc/NSObject.h>

namespace yas {
template <typename T>
T *objc_cast(id const objc_obj) {
    if ([objc_obj isKindOfClass:[T class]]) {
        return (T *)objc_obj;
    }
    return nil;
}
}  // namespace yas
