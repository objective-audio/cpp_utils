//
//  yas_property.h
//

#pragma once

#include <memory>
#include <mutex>
#include "yas_base.h"
#include "yas_observing.h"

namespace yas {
namespace property_method {
    static auto const will_change = "yas.property.will_change";
    static auto const did_change = "yas.property.did_change";
};

struct null_key {};

template <typename T, typename K = null_key>
class property : public base {
    using super_class = base;

   public:
    property();
    explicit property(K key);
    property(K key, T value);
    property(std::nullptr_t);

    bool operator==(property const &) const;
    bool operator!=(property const &) const;
    bool operator==(T const &) const;
    bool operator!=(T const &) const;

    K const &key() const;
    void set_value(T value);
    T const &value() const;

    subject<property> &subject();

   private:
    class impl;
};
}

#include "yas_property_private.h"
