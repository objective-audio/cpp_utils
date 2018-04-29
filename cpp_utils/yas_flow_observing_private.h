//
//  yas_flow_observing_private.h
//

#pragma once

namespace yas::flow {
template <typename Key, typename T>
flow::node<T, T, T> begin(subject<Key, T> &subject, Key const &key) {
    return subject.begin_flow(key);
}
}
