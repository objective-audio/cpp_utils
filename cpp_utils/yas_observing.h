//
//  yas_observing.h
//

#pragma once

#include <functional>
#include <initializer_list>
#include <string>
#include "yas_base.h"

namespace yas {
template <typename Key, typename T>
class subject;

template <typename Key = std::string, typename T = std::nullptr_t>
class observer : public base {
    class impl;

   public:
    struct change_context {
        Key const &key;
        T const &value;
    };

    using subject_t = subject<Key, T>;
    using handler_f = std::function<void(change_context const &)>;

    observer();
    observer(std::nullptr_t);
    ~observer();

    observer(observer const &) = default;
    observer(observer &&) = default;
    observer &operator=(observer const &) = default;
    observer &operator=(observer &&) = default;

    void add_handler(subject<Key, T> &subject, Key const &key, handler_f handler);
    void remove_handler(subject<Key, T> &subject, Key const &key);

    void add_wild_card_handler(subject<Key, T> &subject, handler_f handler);
    void remove_wild_card_handler(subject<Key, T> &subject);

    void clear();

    friend subject_t;
};

template <typename Key = std::string, typename T = std::nullptr_t>
class subject {
   public:
    using observer_t = observer<Key, T>;

    subject();
    ~subject();

    bool operator==(subject const &) const;
    bool operator!=(subject const &) const;

    bool has_observer() const;

    void notify(Key const &key) const;
    void notify(Key const &key, T const &object) const;

    [[nodiscard]] observer<Key, T> make_observer(Key const &key, typename observer<Key, T>::handler_f const &handler);
    [[nodiscard]] observer<Key, T> make_wild_card_observer(typename observer<Key, T>::handler_f const &handler);

   private:
    class impl;
    std::unique_ptr<impl> _impl;

    subject(subject const &) = delete;
    subject(subject &&) = delete;
    subject &operator=(subject const &) = delete;
    subject &operator=(subject &&) = delete;

    friend observer_t;
};

template <typename Key, typename T>
observer<Key, T> make_subject_dispatcher(subject<Key, T> const &source_subject,
                                         std::initializer_list<subject<Key, T> *> const &destination_subjects);
}

template <typename T, typename Key>
struct std::hash<yas::observer<Key, T>> {
    std::size_t operator()(yas::observer<Key, T> const &key) const {
        return std::hash<uintptr_t>()(key.identifier());
    }
};

template <typename T, typename Key>
struct std::hash<yas::weak<yas::observer<Key, T>>> {
    std::size_t operator()(yas::weak<yas::observer<Key, T>> const &weak_key) const {
        auto key = weak_key.lock();
        return std::hash<uintptr_t>()(key.identifier());
    }
};

#include "yas_observing_private.h"
