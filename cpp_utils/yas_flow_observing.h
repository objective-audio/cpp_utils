//
//  yas_flow_observing.h
//

#pragma once

#include "yas_flow.h"
#include "yas_observing.h"

namespace yas::flow {
template <typename Key, typename T>
[[nodiscard]] flow::node<T, T, T> begin(subject<Key, T> &subject, Key const &key);
}

#include "yas_flow_observing_private.h"
