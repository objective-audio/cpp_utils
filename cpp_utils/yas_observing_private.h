//
//  yas_observing_private.h
//

#pragma once

#include <experimental/optional>
#include <unordered_map>
#include <unordered_set>
#include "yas_stl_utils.h"
#include "yas_types.h"

namespace yas {

#pragma mark - observer::impl

template <typename Key, typename T>
class observer<Key, T>::impl : public base::impl {
   public:
    class handler_holder {
        std::unordered_map<opt_t<Key>, handler_f const> functions;

       public:
        void add_handler(opt_t<Key> const &key, handler_f &&handler) {
            functions.insert(std::make_pair(key, std::move(handler)));
        }

        void remove_handler(opt_t<Key> const &key) {
            if (functions.count(key) > 0) {
                functions.erase(key);
            }
        }

        void call_handler(Key const &key, T const &input) const {
            if (functions.count(key) > 0) {
                functions.at(key)(observer<Key, T>::change_context{.key = key, .value = input});
            }
        }

        void call_wild_card_handler(Key const &key, T const &input) const {
            if (functions.count(nullopt) > 0) {
                functions.at(nullopt)(observer<Key, T>::change_context{.key = key, .value = input});
            }
        }

        size_t size() const {
            return functions.size();
        }
    };

    std::unordered_map<subject<Key, T> const *, handler_holder> handlers;

    void call_handler(subject<Key, T> const &subject, Key const &key, T const &object) {
        if (handlers.count(&subject) > 0) {
            handlers.at(&subject).call_handler(key, object);
        }
    }

    void call_wild_card_handler(subject<Key, T> const &subject, Key const &key, T const &object) {
        if (handlers.count(&subject) > 0) {
            handlers.at(&subject).call_wild_card_handler(key, object);
        }
    }
};

#pragma mark - subject::impl

template <typename Key, typename T>
class subject<Key, T>::impl {
   public:
    using observer_set_t = std::unordered_set<weak<observer<Key, T>>>;
    using observers_t = std::unordered_map<std::experimental::optional<Key>, observer_set_t>;
    observers_t observers;
    flow::sender<flow_context_t> sender = nullptr;

    void add_observer(observer<Key, T> const &obs, std::experimental::optional<Key> const &key) {
        if (observers.count(key) == 0) {
            observers.insert(std::make_pair(key, observer_set_t()));
        }

        auto &set = observers.at(key);
        set.insert(weak<observer<Key, T>>(obs));
    }

    void remove_observer(observer<Key, T> const &observer, std::experimental::optional<Key> const &key) {
        if (observers.count(key) > 0) {
            auto &set = observers.at(key);

            erase_if(set, [&observer](auto const &weak_observer) {
                if (auto locked_observer = weak_observer.lock()) {
                    if (observer == locked_observer) {
                        return true;
                    }
                }
                return false;
            });

            if (set.size() == 0) {
                observers.erase(key);
            }
        }
    }

    void remove_observer(uintptr_t const observer_key) {
        erase_if(observers, [&observer_key](auto &pair) {
            auto &set = pair.second;

            erase_if(set, [&observer_key](auto const &weak_observer) {
                if (auto strong_observer = weak_observer.lock()) {
                    if (strong_observer.identifier() == observer_key) {
                        return true;
                    }
                } else {
                    return true;
                }
                return false;
            });

            return set.size() == 0;
        });
    }

    bool has_observer() {
        return observers.size() > 0;
    }

    flow::node<T, flow_context_t, flow_context_t, false> begin_flow(subject<Key, T> &subject, Key const &key) {
        return this->begin_flow(subject)
            .filter([key](flow_context_t const &context) { return context.key == key; })
            .map([](flow_context_t const &context) { return context.value; });
    }

    flow::node<flow_context_t, flow_context_t, flow_context_t, false> begin_flow(subject<Key, T> &subject) {
        if (!this->sender) {
            flow::sender<flow_context_t> sender;

            auto observer = subject.make_wild_card_observer([weak_sender = to_weak(sender)](auto const &context) {
                if (auto sender = weak_sender.lock()) {
                    sender.send_value(context);
                }
            });

            sender.set_sync_handler([observer]() { return nullopt; });

            this->sender = std::move(sender);
        }

        return this->sender.begin();
    }
};

#pragma mark - observer

template <typename Key, typename T>
observer<Key, T>::observer() : base(std::make_shared<impl>()) {
}

template <typename Key, typename T>
observer<Key, T>::observer(std::nullptr_t) : base(nullptr) {
}

template <typename Key, typename T>
observer<Key, T>::~observer() {
    if (impl_ptr() && impl_ptr().unique()) {
        clear();
        impl_ptr().reset();
    }
}

template <typename Key, typename T>
void observer<Key, T>::add_handler(subject<Key, T> &subject, Key const &key, handler_f handler) {
    auto imp = impl_ptr<impl>();
    auto subject_ptr = &subject;
    if (imp->handlers.count(subject_ptr) == 0) {
        imp->handlers.insert(std::make_pair(&subject, typename impl::handler_holder{}));
    };
    imp->handlers.at(&subject).add_handler(key, std::move(handler));

    subject._impl->add_observer(*this, key);
}

template <typename Key, typename T>
void observer<Key, T>::remove_handler(subject<Key, T> &subject, Key const &key) {
    auto imp = impl_ptr<impl>();
    if (imp->handlers.count(&subject) > 0) {
        auto &handler_holder = imp->handlers.at(&subject);
        handler_holder.remove_handler(key);
        if (handler_holder.size() == 0) {
            imp->handlers.erase(&subject);
        }
    }
    subject._impl->remove_observer(*this, key);
}

template <typename Key, typename T>
void observer<Key, T>::add_wild_card_handler(subject<Key, T> &subject, handler_f handler) {
    auto imp = impl_ptr<impl>();
    auto subject_ptr = &subject;
    if (imp->handlers.count(subject_ptr) == 0) {
        imp->handlers.insert(std::make_pair(&subject, typename impl::handler_holder{}));
    };
    imp->handlers.at(&subject).add_handler(nullopt, std::move(handler));
    subject._impl->add_observer(*this, nullopt);
}

template <typename Key, typename T>
void observer<Key, T>::remove_wild_card_handler(subject<Key, T> &subject) {
    auto imp = impl_ptr<impl>();
    if (imp->handlers.count(&subject) > 0) {
        auto &handler_holder = imp->handlers.at(&subject);
        handler_holder.remove_handler(nullopt);
        if (handler_holder.size() == 0) {
            imp->handlers.erase(&subject);
        }
    }
    subject._impl->remove_observer(*this, nullopt);
}

template <typename Key, typename T>
void observer<Key, T>::clear() {
    auto id = identifier();
    auto imp = impl_ptr<impl>();
    for (auto &pair : imp->handlers) {
        auto &subject_ptr = pair.first;
        subject_ptr->_impl->remove_observer(id);
    }
    imp->handlers.clear();
}

#pragma mark - subject

template <typename Key, typename T>
subject<Key, T>::subject() : _impl(std::make_unique<impl>()) {
}

template <typename Key, typename T>
subject<Key, T>::~subject() {
    for (auto &pair : _impl->observers) {
        for (auto &weak_observer : pair.second) {
            if (auto obs = weak_observer.lock()) {
                obs.template impl_ptr<typename observer<Key, T>::impl>()->handlers.erase(this);
            }
        }
    }
}

template <typename Key, typename T>
bool subject<Key, T>::operator==(subject const &rhs) const {
    return this == &rhs;
}

template <typename Key, typename T>
bool subject<Key, T>::operator!=(subject const &rhs) const {
    return this != &rhs;
}

template <typename Key, typename T>
bool subject<Key, T>::has_observer() const {
    return _impl->has_observer();
}

template <typename Key, typename T>
void subject<Key, T>::notify(Key const &key) const {
    notify(key, nullptr);
}

template <typename Key, typename T>
void subject<Key, T>::notify(Key const &key, T const &object) const {
    if (!_impl->has_observer()) {
        return;
    }

    if (_impl->observers.count(key) > 0) {
        for (auto &weak_observer : _impl->observers.at(key)) {
            if (observer<Key, T> obs = weak_observer.lock()) {
                obs.template impl_ptr<typename observer<Key, T>::impl>()->call_handler(*this, key, object);
            }
        }
    }
    if (_impl->observers.count(nullopt) > 0) {
        for (auto &weak_observer : _impl->observers.at(nullopt)) {
            if (auto obs = weak_observer.lock()) {
                obs.template impl_ptr<typename observer<Key, T>::impl>()->call_wild_card_handler(*this, key, object);
            }
        }
    }
}

template <typename Key, typename T>
observer<Key, T> subject<Key, T>::make_value_observer(Key const &key, value_handler_f const &handler) {
    observer<Key, T> obs;
    obs.add_handler(*this, key, [handler](auto const &context) { handler(context.value); });
    return obs;
}

template <typename Key, typename T>
observer<Key, T> subject<Key, T>::make_observer(Key const &key, wild_card_handler_f const &handler) {
    observer<Key, T> obs;
    obs.add_handler(*this, key, handler);
    return obs;
}

template <typename Key, typename T>
observer<Key, T> subject<Key, T>::make_wild_card_observer(wild_card_handler_f const &handler) {
    observer<Key, T> obs;
    obs.add_wild_card_handler(*this, handler);
    return obs;
}

template <typename Key, typename T>
flow::node<T, typename subject<Key, T>::flow_context_t, typename subject<Key, T>::flow_context_t, false>
subject<Key, T>::begin_flow(Key const &key) {
    return _impl->begin_flow(*this, key);
}

template <typename Key, typename T>
[[nodiscard]] flow::node<typename subject<Key, T>::flow_context_t, typename subject<Key, T>::flow_context_t,
                         typename subject<Key, T>::flow_context_t, false>
subject<Key, T>::begin_flow() {
    return _impl->begin_flow(*this);
}
}  // namespace yas

template <typename Key, typename T>
yas::observer<Key, T> yas::make_subject_dispatcher(subject<Key, T> const &source,
                                                   std::initializer_list<subject<Key, T> *> const &destinations) {
    observer<Key, T> observer;
    auto handler = [&source](auto const &context) { source.notify(context.key, context.value); };

    for (auto const &destination : destinations) {
        observer.add_wild_card_handler(*destination, handler);
    }

    return observer;
}
