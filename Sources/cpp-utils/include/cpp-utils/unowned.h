//
//  unowned.h
//

#pragma once

#include <objc-utils/unowned.h>

namespace yas {
template <typename T>
YASUnownedObject<T> *_Nonnull make_unowned(T _Nullable object) {
    return [[YASUnownedObject<T> alloc] initWithObject:object];
}
}  // namespace yas
