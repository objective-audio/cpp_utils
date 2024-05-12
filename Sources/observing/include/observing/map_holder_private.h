//
//  map_holder_private.h
//

#pragma once

#include <cpp-utils/stl_utils.h>

namespace yas::observing::map {
template <typename Key, typename Element>
holder<Key, Element>::holder(std::map<Key, Element> const &value) : _raw(value) {
}

template <typename Key, typename Element>
holder<Key, Element>::holder(std::map<Key, Element> &&value) : _raw(std::move(value)) {
}

template <typename Key, typename Element>
std::map<Key, Element> const &holder<Key, Element>::elements() const {
    return this->_raw;
}

template <typename Key, typename Element>
Element const &holder<Key, Element>::at(Key const &key) const {
    return this->_raw.at(key);
}

template <typename Key, typename Element>
bool holder<Key, Element>::contains(Key const &key) const {
    return this->_raw.count(key) > 0;
}

template <typename Key, typename Element>
std::size_t holder<Key, Element>::size() const {
    return this->_raw.size();
}

template <typename Key, typename Element>
void holder<Key, Element>::replace(std::map<Key, Element> const &map) {
    this->_raw = map;
    this->_call_any();
}

template <typename Key, typename Element>
void holder<Key, Element>::replace(std::map<Key, Element> &&map) {
    this->_raw = std::move(map);
    this->_call_any();
}

template <typename Key, typename Element>
void holder<Key, Element>::insert_or_replace(Key const &key, Element const &element) {
    std::map<Key, Element> erased;

    if (this->_raw.count(key) > 0) {
        erased.emplace(key, std::move(this->_raw.at(key)));
        this->_raw.erase(key);
    }

    this->_raw.emplace(key, element);

    if (!erased.empty()) {
        this->_call_replaced(&erased.at(key), key);
    } else {
        this->_call_inserted(key);
    }
}

template <typename Key, typename Element>
std::map<Key, Element> holder<Key, Element>::erase(Key const &key) {
    std::map<Key, Element> erased;

    if (this->_raw.count(key) > 0) {
        erased.emplace(key, std::move(this->_raw.at(key)));
        this->_raw.erase(key);
        this->_call_erased(&erased.at(key), key);
    }

    return erased;
}

template <typename Key, typename Element>
void holder<Key, Element>::clear() {
    if (this->_raw.size() > 0) {
        this->_raw.clear();
        this->_call_any();
    }
}

template <typename Key, typename Element>
syncable holder<Key, Element>::observe(typename caller<event>::handler_f &&handler) {
    return this->observe(0, std::move(handler));
}

template <typename Key, typename Element>
syncable holder<Key, Element>::observe(std::size_t const order, typename caller<event>::handler_f &&handler) {
    if (!this->_caller) {
        this->_caller = caller<event>::make_shared();
    }

    return syncable{[this, order, handler = std::move(handler)](bool const sync) mutable {
        if (sync) {
            handler(event{.type = event_type::any, .elements = this->_raw});
        }
        return this->_caller->add(order, std::move(handler));
    }};
}

template <typename Key, typename Element>
holder_ptr<Key, Element> holder<Key, Element>::make_shared() {
    return make_shared({});
}

template <typename Key, typename Element>
holder_ptr<Key, Element> holder<Key, Element>::make_shared(std::map<Key, Element> &&map) {
    return holder_ptr<Key, Element>(new holder<Key, Element>{std::move(map)});
}

template <typename Key, typename Element>
holder_ptr<Key, Element> holder<Key, Element>::make_shared(std::map<Key, Element> const &map) {
    return holder_ptr<Key, Element>(new holder<Key, Element>{map});
}

template <typename Key, typename Element>
void holder<Key, Element>::_call_any() {
    if (auto const &caller = this->_caller) {
        caller->call(event{.type = event_type::any, .elements = this->_raw});
    }
}

template <typename Key, typename Element>
void holder<Key, Element>::_call_replaced(Element const *erased, std::optional<Key> const &key) {
    if (auto const &caller = this->_caller) {
        caller->call(event{.type = event_type::replaced,
                           .elements = this->_raw,
                           .inserted = &this->_raw.at(*key),
                           .erased = erased,
                           .key = key});
    }
}

template <typename Key, typename Element>
void holder<Key, Element>::_call_inserted(std::optional<Key> const &key) {
    if (auto const &caller = this->_caller) {
        caller->call(
            event{.type = event_type::inserted, .elements = this->_raw, .inserted = &this->_raw.at(*key), .key = key});
    }
}

template <typename Key, typename Element>
void holder<Key, Element>::_call_erased(Element const *erased, std::optional<Key> const &key) {
    if (auto const &caller = this->_caller) {
        caller->call(event{.type = event_type::erased, .elements = this->_raw, .erased = erased, .key = key});
    }
}
}  // namespace yas::observing::map
