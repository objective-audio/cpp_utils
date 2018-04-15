//
//  yas_flow_observing.h
//

#pragma once

#include "yas_flow.h"
#include "yas_observing.h"

namespace yas {
template <typename Key, typename T>
flow::node<T, T, T> begin_flow(subject<Key, T> &subject, Key const &key) {
    flow::sender<T> sender;

    auto observer = subject.make_value_observer(key, [weak_sender = to_weak(sender)](T const &value) mutable {
        if (auto sender = weak_sender.lock()) {
            sender.send_value(value);
        }
    });

    sender.set_can_send_handler([weak_subject = to_weak(subject)]() { return !!weak_subject; });

    sender.set_send_handler([weak_subject = to_weak(subject), key, observer]() {
        if (yas::subject<Key, T> subj = weak_subject.lock()) {
            return subj.object(key);
        } else {
            throw std::runtime_error("subject is null.");
        }
    });

    return sender.begin_flow();
}
}
