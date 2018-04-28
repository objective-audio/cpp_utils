//
//  yas_flow_observing_private.h
//

#pragma once

namespace yas::flow {
template <typename Key, typename T>
flow::node<T, T, T> begin(subject<Key, T> &subject, Key const &key) {
    flow::input<T> input;

    auto observer = subject.make_value_observer(key, [weak_sender = to_weak(input)](T const &value) mutable {
        if (auto sender = weak_sender.lock()) {
            sender.send_value(value);
        }
    });

    input.set_can_send_handler([observer]() { return false; });

    return input.begin();
}
}
