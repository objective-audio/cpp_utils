//
//  yas_observing.h
//

#pragma once

#include <functional>
#include <initializer_list>
#include <string>
#include "yas_base.h"

namespace yas {
template <typename T, typename Key>
class subject;

template <typename T = std::nullptr_t, typename Key = std::string>
class observer : public base {
    class impl;

   public:
    using handler_f = std::function<void(Key const &, const T &)>;

    observer();
    observer(std::nullptr_t);
    ~observer();

    observer(observer const &) = default;
    observer(observer &&) = default;
    observer &operator=(observer const &) = default;
    observer &operator=(observer &&) = default;

    void add_handler(subject<T, Key> &subject, Key const &key, handler_f handler);
    void remove_handler(subject<T, Key> &subject, Key const &key);

    void add_wild_card_handler(subject<T, Key> &subject, handler_f handler);
    void remove_wild_card_handler(subject<T, Key> &subject);

    void clear();

    friend subject<T, Key>;
};

template <typename T = std::nullptr_t, typename Key = std::string>
class subject {
   public:
    subject();
    ~subject();

    bool operator==(subject const &) const;
    bool operator!=(subject const &) const;

    bool has_observer() const;

    void notify(Key const &key) const;
    void notify(Key const &key, const T &object) const;

    observer<T, Key> make_observer(Key const &key, typename observer<T, Key>::handler_f const &handler);
    observer<T, Key> make_wild_card_observer(typename observer<T, Key>::handler_f const &handler);

   private:
    class impl;
    std::unique_ptr<impl> _impl;

    subject(subject const &) = delete;
    subject(subject &&) = delete;
    subject &operator=(subject const &) = delete;
    subject &operator=(subject &&) = delete;

    friend observer<T, Key>;
};

template <typename T, typename Key>
observer<T, Key> make_subject_dispatcher(subject<T, Key> const &source_subject,
                                         std::initializer_list<subject<T, Key> *> const &destination_subjects);
}

template <typename T, typename Key>
struct std::hash<yas::observer<T, Key>> {
    std::size_t operator()(yas::observer<T, Key> const &key) const {
        return std::hash<uintptr_t>()(key.identifier());
    }
};

template <typename T, typename Key>
struct std::hash<yas::weak<yas::observer<T, Key>>> {
    std::size_t operator()(yas::weak<yas::observer<T, Key>> const &weak_key) const {
        auto key = weak_key.lock();
        return std::hash<uintptr_t>()(key.identifier());
    }
};

#include "yas_observing_private.h"
