//
//  yas_value.h
//

#pragma once

#include <memory>

namespace yas {
struct value {
    struct impl_base;
    using impl_base_ptr = std::shared_ptr<impl_base>;

    template <typename T>
    struct impl;

    std::type_info const &type() const;

    template <typename T>
    T const &get() const;

   protected:
    value(impl_base_ptr &&);

   private:
    impl_base_ptr _impl_ptr;
};

template <typename T>
value make_value(T const &);
template <typename T>
value make_value(T &&);
}

#include "yas_value_private.h"
