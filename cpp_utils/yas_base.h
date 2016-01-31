//
//  yas_base.h
//

#pragma once

#include <map>
#include <memory>

namespace yas {
class base {
   public:
    class impl : public std::enable_shared_from_this<base::impl> {
       public:
        virtual ~impl();

        template <typename T, typename I = typename T::impl>
        T cast();

        uintptr_t identifier() const;
    };

    base(std::nullptr_t);
    virtual ~base();

    base(base const &);
    base(base &&);
    base &operator=(base const &);
    base &operator=(base &&);

    bool operator==(base const &rhs) const;
    bool operator!=(base const &rhs) const;
    bool operator==(std::nullptr_t) const;
    bool operator!=(std::nullptr_t) const;
    bool operator<(base const &rhs) const;

    explicit operator bool() const;
    bool expired() const;

    uintptr_t identifier() const;

    template <typename T, typename I = typename T::impl>
    T cast() const;

    template <typename T, typename I = typename T::impl>
    bool is_kind_of() const;

    std::shared_ptr<impl> &impl_ptr();
    void set_impl_ptr(std::shared_ptr<impl> const &);
    void set_impl_ptr(std::shared_ptr<impl> &&);

    template <typename T = impl>
    std::shared_ptr<T> const impl_ptr() const;

   protected:
    base(std::shared_ptr<impl> const &);
    base(std::shared_ptr<impl> &&);

   private:
    std::shared_ptr<impl> _impl;
};

template <typename T>
class weak {
   public:
    weak();
    weak(T const &);

    weak(weak<T> const &);
    weak(weak<T> &&);
    weak<T> &operator=(weak<T> const &);
    weak<T> &operator=(weak<T> &&);
    weak<T> &operator=(T const &);

    explicit operator bool() const;

    uintptr_t identifier() const;

    bool operator==(weak const &rhs) const;
    bool operator!=(weak const &rhs) const;

    T lock() const;

    void reset();

   private:
    std::weak_ptr<base::impl> _impl;
};

template <typename K, typename T>
std::map<K, T> lock_values(std::map<K, weak<T>> const &);

template <typename T>
weak<T> to_weak(T const &);
}

#include "yas_base_private.h"
