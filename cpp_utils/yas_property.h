//
//  yas_property.h
//

#pragma once

#include <functional>
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

template <typename K, typename T>
class property : public base {
   public:
    class impl;

    struct change_context {
        T const &old_value;
        T const &new_value;
        property const &property;
    };

    using subject_t = subject<property_method, change_context>;
    using observer_t = observer<property_method, change_context>;
    using validator_t = std::function<bool(T const &)>;
    using limiter_t = std::function<T(T const &)>;

    struct args {
        T value;
        K key;
        validator_t validator = nullptr;
        limiter_t limiter = nullptr;
    };

    property();
    explicit property(args const &);
    explicit property(args &&);
    property(std::nullptr_t);

    bool operator==(property const &) const;
    bool operator!=(property const &) const;
    bool operator==(T const &) const;
    bool operator!=(T const &) const;

    K const &key() const;

    void set_value(T value);
    T const &value() const;
    T &value();

    void set_validator(validator_t);
    validator_t const &validator() const;

    void set_limiter(limiter_t);
    limiter_t const &limiter() const;

    subject_t &subject();
};

template <typename K, typename T>
property<K, T> make_property(K key, T value);

std::string to_string(yas::property_method const method);
}

#include "yas_property_private.h"
