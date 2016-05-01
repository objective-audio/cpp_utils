//
//  yas_property.h
//

#pragma once

#include <memory>
#include <mutex>
#include "yas_base.h"
#include "yas_observing.h"

namespace yas {
enum class property_method {
    will_change,
    did_change,
};

struct null_key {};

template <typename T, typename K = null_key>
struct property_args {
    T value;
    K key;
};

template <typename T, typename K = null_key>
class property : public base {
    class impl;

   public:
    struct change_context {
        T const &old_value;
        T const &new_value;
        property const &property;
    };

    using subject_t = subject<change_context, property_method>;
    using observer_t = observer<change_context, property_method>;

    property();
    explicit property(property_args<T, K>);
    property(std::nullptr_t);

    bool operator==(property const &) const;
    bool operator!=(property const &) const;
    bool operator==(T const &) const;
    bool operator!=(T const &) const;

    K const &key() const;
    K &key();

    void set_value(T value);
    T const &value() const;
    T &value();

    subject_t &subject();
};

template <typename T, typename K = null_key>
property<T, K> make_property(T value, K key = null_key{});
}

#include "yas_property_private.h"
