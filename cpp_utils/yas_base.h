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
        impl();
        virtual ~impl();

        virtual bool is_equal(std::shared_ptr<impl> const &) const;
        virtual bool is_less(std::shared_ptr<impl> const &) const;

        template <typename T, typename I = typename T::impl>
        T cast();

        uintptr_t identifier() const;

       private:
        impl(impl const &) = delete;
        impl(impl &&) = delete;
        impl &operator=(impl const &) = delete;
        impl &operator=(impl &&) = delete;
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

    std::shared_ptr<impl> &impl_ptr();
    void set_impl_ptr(std::shared_ptr<impl> const &);
    void set_impl_ptr(std::shared_ptr<impl> &&);

    template <typename T = impl>
    std::shared_ptr<T> impl_ptr() const;

   protected:
    base(std::shared_ptr<impl> const &);
    base(std::shared_ptr<impl> &&);

   private:
    std::shared_ptr<impl> _impl;
};

template <typename T>
bool is_kind_of(base const &);

bool is_same(base const &, base const &);

template <typename T>
T cast(base const &);

template <typename T>
class weak {
   public:
    weak();
    weak(T const &);

    weak(weak<T> const &);
    weak(weak<T> &&);

    template <typename U>
    weak(weak<U> const &);

    weak<T> &operator=(weak<T> const &);
    weak<T> &operator=(weak<T> &&);
    weak<T> &operator=(T const &);

    template <typename U>
    weak<T> &operator=(weak<U> const &);

    explicit operator bool() const;

    uintptr_t identifier() const;

    bool operator==(weak const &rhs) const;
    bool operator!=(weak const &rhs) const;

    T lock() const;
    void lock(std::function<void(T &)> const &) const;

    void reset();

   private:
    std::weak_ptr<base::impl> _impl;
};

template <typename K, typename T>
std::map<K, T> lock_values(std::map<K, weak<T>> const &);

template <typename T>
weak<T> to_weak(T const &);
}  // namespace yas

#include "yas_base_private.h"
