//
//  yas_any.h
//

#pragma once

#include <memory>

namespace yas {
struct any {
    struct impl_base;
    using impl_base_ptr = std::shared_ptr<impl_base>;

    template <typename T>
    struct impl;

    std::type_info const &type() const;

    template <typename T>
    T const &get() const;

    static any const &null();

   protected:
    any(impl_base_ptr &&);

   private:
    impl_base_ptr _impl_ptr;
};

template <typename T>
any make_any(T const &);
template <typename T>
any make_any(T &&);
}

#include "yas_any_private.h"
