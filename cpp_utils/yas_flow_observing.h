//
//  yas_flow_observing.h
//

#pragma once

#include "yas_flow.h"
#include "yas_observing.h"

namespace yas {
template <typename Key, typename T>
[[nodiscard]] flow::node<T, T, T> begin_flow(subject<Key, T> &subject, Key const &key);
}

#include "yas_flow_observing_private.h"
