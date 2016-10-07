//
//  yas_cf_ref.h
//

#pragma once

#include <CoreFoundation/CFBase.h>
#include <mutex>
#include "yas_base.h"

namespace yas {
struct cf_ref_impl : public base::impl {
    cf_ref_impl();
    cf_ref_impl(CFTypeRef const obj);
    cf_ref_impl(std::nullptr_t);

    virtual ~cf_ref_impl() final;

    void set_object(CFTypeRef const obj);
    void move_object(CFTypeRef const obj);

    CFTypeRef object();
    CFTypeRef retained_object();
    CFTypeRef autoreleased_object();

   private:
    CFTypeRef _obj = nullptr;
    std::recursive_mutex _mutex;
};

template <typename T>
class cf_ref : public base {
   public:
    cf_ref();
    explicit cf_ref(T const);
    cf_ref(std::nullptr_t);

    cf_ref &operator=(T const);

    explicit operator bool() const;

    void set_object(T const);
    void move_object(T const);

    T object() const;
    T retained_object() const;
    T autoreleased_object() const;
};

template <typename T>
cf_ref<T> make_cf_ref(T const obj);
}

#include "yas_cf_ref_private.h"