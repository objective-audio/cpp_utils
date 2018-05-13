//
//  yas_objc_ptr.h
//

#pragma once

#include <objc/objc.h>
#include <functional>
#include <mutex>
#include "yas_base.h"

namespace yas {
template <typename T>
using enable_if_id_t = typename std::enable_if_t<std::is_convertible<T, id>::value>;

struct objc_ptr_impl : public base::impl {
    objc_ptr_impl();
    objc_ptr_impl(id const obj);

    virtual ~objc_ptr_impl() final;

    void set_object(id const obj);
    void move_object(id const obj);

    id object();
    id retained_object();
    id autoreleased_object();

   private:
    id _obj = nil;
    std::recursive_mutex _mutex;
};

template <typename T = id, typename Enable = void>
class objc_ptr;

template <typename T>
class objc_ptr<T, enable_if_id_t<T>> : public base {
   public:
    objc_ptr();
    explicit objc_ptr(T const);
    explicit objc_ptr(std::function<T(void)> const &func);

    objc_ptr &operator=(T const);
    T operator*() const noexcept;

    explicit operator bool() const;

    void set_object(T const);
    void move_object(T const);

    T object() const;
    T retained_object() const;
    T autoreleased_object() const;
};

template <typename T>
objc_ptr<T> make_objc_ptr(T const obj);

template <typename T>
objc_ptr<T> make_objc_ptr(std::function<T(void)> const &func);
}  // namespace yas

#include "yas_objc_ptr_private.h"
