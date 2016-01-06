//
//  yas_observing.h
//

#pragma once

#include <functional>
#include <initializer_list>
#include <string>
#include "yas_base.h"

namespace yas {
template <typename T>
class subject;

template <typename T = std::nullptr_t>
class observer : public base {
    using super_class = base;
    class impl;

   public:
    using handler_f = std::function<void(std::string const &, const T &)>;

    observer();
    observer(std::nullptr_t);
    ~observer();

    observer(observer const &) = default;
    observer(observer &&) = default;
    observer &operator=(observer const &) = default;
    observer &operator=(observer &&) = default;

    void add_handler(subject<T> &subject, std::string const &key, handler_f const &handler);
    void remove_handler(subject<T> &subject, std::string const &key);

    void add_wild_card_handler(subject<T> &subject, handler_f const &handler);
    void remove_wild_card_handler(subject<T> &subject);

    void clear();

    friend subject<T>;
};

template <typename T = std::nullptr_t>
class subject {
   public:
    subject();
    ~subject();

    bool operator==(subject const &) const;
    bool operator!=(subject const &) const;

    void notify(std::string const &key) const;
    void notify(std::string const &key, const T &object) const;

    observer<T> make_observer(std::string const &key, typename observer<T>::handler_f const &handler);
    observer<T> make_wild_card_observer(typename observer<T>::handler_f const &handler);

   private:
    class impl;
    std::unique_ptr<impl> _impl;

    subject(subject const &) = delete;
    subject(subject &&) = delete;
    subject &operator=(subject const &) = delete;
    subject &operator=(subject &&) = delete;

    friend observer<T>;
};

template <typename T>
observer<T> make_subject_dispatcher(subject<T> const &source_subject,
                                    std::initializer_list<subject<T> *> const &destination_subjects);
}

template <typename T>
struct std::hash<yas::observer<T>> {
    std::size_t operator()(yas::observer<T> const &key) const {
        return std::hash<uintptr_t>()(key.identifier());
    }
};

template <typename T>
struct std::hash<yas::weak<yas::observer<T>>> {
    std::size_t operator()(yas::weak<yas::observer<T>> const &weak_key) const {
        auto key = weak_key.lock();
        return std::hash<uintptr_t>()(key.identifier());
    }
};

#include "yas_observing_private.h"
