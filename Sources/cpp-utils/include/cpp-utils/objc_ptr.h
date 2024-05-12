//
//  objc_ptr.h
//

#pragma once

#include <objc/objc.h>

#include <functional>
#include <mutex>

namespace yas {
template <typename T>
using enable_if_id_t = typename std::enable_if_t<std::is_convertible<T, id>::value>;

struct objc_ptr_impl final {
    objc_ptr_impl();
    objc_ptr_impl(id const obj);

    virtual ~objc_ptr_impl();

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
struct objc_ptr<T, enable_if_id_t<T>> {
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

   private:
    std::shared_ptr<objc_ptr_impl> _impl;
};

template <typename T>
objc_ptr<T> objc_ptr_with_move_object(T const obj);
}  // namespace yas

#include "objc_ptr_private.h"
