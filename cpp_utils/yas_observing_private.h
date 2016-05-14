//
//  yas_observing_private.h
//

#pragma once

#include <experimental/optional>
#include <unordered_map>
#include <unordered_set>
#include "yas_stl_utils.h"

using namespace std::experimental;

namespace yas {

#pragma mark - impl

template <typename T, typename Key>
class observer<T, Key>::impl : public base::impl {
   public:
    class handler_holder {
        std::unordered_map<optional<Key>, handler_f const> functions;

       public:
        void add_handler(optional<Key> const &key, handler_f &&handler) {
            functions.insert(std::make_pair(key, std::move(handler)));
        }

        void remove_handler(optional<Key> const &key) {
            if (functions.count(key) > 0) {
                functions.erase(key);
            }
        }

        void call_handler(Key const &key, T const &sender) const {
            if (functions.count(key) > 0) {
                functions.at(key)(observer<T, Key>::change_context{.key = key, .value = sender});
            }
        }

        void call_wild_card_handler(Key const &key, T const &sender) const {
            if (functions.count(nullopt) > 0) {
                functions.at(nullopt)(observer<T, Key>::change_context{.key = key, .value = sender});
            }
        }

        size_t size() const {
            return functions.size();
        }
    };

    std::unordered_map<subject<T, Key> const *, handler_holder> handlers;

    void call_handler(subject<T, Key> const &subject, Key const &key, T const &object) {
        if (handlers.count(&subject) > 0) {
            handlers.at(&subject).call_handler(key, object);
        }
    }

    void call_wild_card_handler(subject<T, Key> const &subject, Key const &key, T const &object) {
        if (handlers.count(&subject) > 0) {
            handlers.at(&subject).call_wild_card_handler(key, object);
        }
    }
};

template <typename T, typename Key>
class subject<T, Key>::impl {
   public:
    using observer_set_t = std::unordered_set<weak<observer<T, Key>>>;
    using observers_t = std::unordered_map<optional<Key>, observer_set_t>;
    observers_t observers;

    void add_observer(observer<T, Key> const &obs, optional<Key> const &key) {
        if (observers.count(key) == 0) {
            observers.insert(std::make_pair(key, observer_set_t()));
        }

        auto &set = observers.at(key);
        set.insert(weak<observer<T, Key>>(obs));
    }

    void remove_observer(observer<T, Key> const &observer, optional<Key> const &key) {
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
};

#pragma mark - observer

template <typename T, typename Key>
observer<T, Key>::observer() : base(std::make_shared<impl>()) {
}

template <typename T, typename Key>
observer<T, Key>::observer(std::nullptr_t) : base(nullptr) {
}

template <typename T, typename Key>
observer<T, Key>::~observer() {
    if (impl_ptr() && impl_ptr().unique()) {
        clear();
        impl_ptr().reset();
    }
}

template <typename T, typename Key>
void observer<T, Key>::add_handler(subject<T, Key> &subject, Key const &key, handler_f handler) {
    auto imp = impl_ptr<impl>();
    auto subject_ptr = &subject;
    if (imp->handlers.count(subject_ptr) == 0) {
        imp->handlers.insert(std::make_pair(&subject, typename impl::handler_holder{}));
    };
    imp->handlers.at(&subject).add_handler(key, std::move(handler));

    subject._impl->add_observer(*this, key);
}

template <typename T, typename Key>
void observer<T, Key>::remove_handler(subject<T, Key> &subject, Key const &key) {
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

template <typename T, typename Key>
void observer<T, Key>::add_wild_card_handler(subject<T, Key> &subject, handler_f handler) {
    auto imp = impl_ptr<impl>();
    auto subject_ptr = &subject;
    if (imp->handlers.count(subject_ptr) == 0) {
        imp->handlers.insert(std::make_pair(&subject, typename impl::handler_holder{}));
    };
    imp->handlers.at(&subject).add_handler(nullopt, std::move(handler));
    subject._impl->add_observer(*this, nullopt);
}

template <typename T, typename Key>
void observer<T, Key>::remove_wild_card_handler(subject<T, Key> &subject) {
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

template <typename T, typename Key>
void observer<T, Key>::clear() {
    auto id = identifier();
    auto imp = impl_ptr<impl>();
    for (auto &pair : imp->handlers) {
        auto &subject_ptr = pair.first;
        subject_ptr->_impl->remove_observer(id);
    }
    imp->handlers.clear();
}

#pragma mark - subject

template <typename T, typename Key>
subject<T, Key>::subject() : _impl(std::make_unique<impl>()) {
}

template <typename T, typename Key>
subject<T, Key>::~subject() {
    for (auto &pair : _impl->observers) {
        for (auto &weak_observer : pair.second) {
            if (auto obs = weak_observer.lock()) {
                obs.template impl_ptr<typename observer<T, Key>::impl>()->handlers.erase(this);
            }
        }
    }
}

template <typename T, typename Key>
bool subject<T, Key>::operator==(subject const &rhs) const {
    return this == &rhs;
}

template <typename T, typename Key>
bool subject<T, Key>::operator!=(subject const &rhs) const {
    return this != &rhs;
}

template <typename T, typename Key>
bool subject<T, Key>::has_observer() const {
    return _impl->has_observer();
}

template <typename T, typename Key>
void subject<T, Key>::notify(Key const &key) const {
    notify(key, nullptr);
}

template <typename T, typename Key>
void subject<T, Key>::notify(Key const &key, T const &object) const {
    if (_impl->observers.count(key) > 0) {
        for (auto &weak_observer : _impl->observers.at(key)) {
            if (observer<T, Key> obs = weak_observer.lock()) {
                obs.template impl_ptr<typename observer<T, Key>::impl>()->call_handler(*this, key, object);
            }
        }
    }
    if (_impl->observers.count(nullopt) > 0) {
        for (auto &weak_observer : _impl->observers.at(nullopt)) {
            if (auto obs = weak_observer.lock()) {
                obs.template impl_ptr<typename observer<T, Key>::impl>()->call_wild_card_handler(*this, key, object);
            }
        }
    }
}

template <typename T, typename Key>
observer<T, Key> subject<T, Key>::make_observer(Key const &key, typename observer<T, Key>::handler_f const &handler) {
    observer<T, Key> obs;
    obs.add_handler(*this, key, handler);
    return obs;
}

template <typename T, typename Key>
observer<T, Key> subject<T, Key>::make_wild_card_observer(typename observer<T, Key>::handler_f const &handler) {
    observer<T, Key> obs;
    obs.add_wild_card_handler(*this, handler);
    return obs;
}
}

template <typename T, typename Key>
yas::observer<T, Key> yas::make_subject_dispatcher(subject<T, Key> const &source,
                                                   std::initializer_list<subject<T, Key> *> const &destinations) {
    observer<T, Key> observer;
    auto handler = [&source](auto const &context) { source.notify(context.key, context.value); };

    for (auto const &destination : destinations) {
        observer.add_wild_card_handler(*destination, handler);
    }

    return observer;
}
