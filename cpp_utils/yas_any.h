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

    template <typename T>
    any(T const &);

    any operator=(any const &);

    template <typename T>
    any operator=(T const &);

    std::type_info const &type() const;

    template <typename T>
    T const &get() const;

    static any const &null();

   protected:
    any(impl_base_ptr &&);

   private:
    impl_base_ptr _impl_ptr;
};
}

#include "yas_any_private.h"
