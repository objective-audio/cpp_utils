//
//  yas_observing_caller_private.h
//

#pragma once

namespace yas::observing {
template <typename T>
caller<T>::caller() : _member(std::make_shared<member>()) {
}

template <typename T>
caller<T>::~caller() {
    auto const member = this->_member;
    for (auto const &canceller : member->cancellers) {
        if (auto shared = canceller.second.lock()) {
            shared->ignore();
        }
    }
}

template <typename T>
canceller_ptr caller<T>::add(handler_f &&handler) {
    return this->add(0, std::move(handler));
}

template <typename T>
canceller_ptr caller<T>::add(std::size_t const order, handler_f &&handler) {
    auto canceller = canceller::make_shared([this, order](uintptr_t const identifier) {
        auto const member = this->_member;

        caller_index const index{.identifier = identifier, .order = order};
        member->handlers.at(index).enabled = false;
        if (!member->calling) {
            member->handlers.erase(index);
        }
        member->cancellers.erase(identifier);
    });
    auto const identifier = canceller->identifier();
    caller_index const index{.identifier = identifier, .order = order};
    this->_member->handlers.emplace(index, handler_container{.handler = handler});
    this->_member->cancellers.emplace(identifier, canceller);
    return canceller;
}

template <typename T>
void caller<T>::call(T const &value) {
    auto const member = this->_member;

    if (!member->calling) {
        member->calling = true;
        std::vector<caller_index> removed;
        for (auto const &pair : member->handlers) {
            if (pair.second.enabled) {
                pair.second.handler(value);
            }

            if (!pair.second.enabled) {
                removed.emplace_back(pair.first);
            }
        }
        for (auto const &index : removed) {
            member->handlers.erase(index);
        }
        member->calling = false;
    }
}

template <typename T>
caller_ptr<T> caller<T>::make_shared() {
    return caller_ptr<T>(new caller<T>{});
}
}  // namespace yas::observing
