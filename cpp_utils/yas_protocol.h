//
//  yas_protocol.h
//

#pragma once

#include <functional>
#include <memory>

namespace yas {
class protocol {
   public:
    class impl {
       public:
        impl();
        virtual ~impl();

       private:
        impl(impl const &) = delete;
        impl(impl &&) = delete;
        impl &operator=(impl const &) = delete;
        impl &operator=(impl &&) = delete;
    };

    virtual ~protocol();

    protocol(protocol const &);
    protocol(protocol &&);
    protocol &operator=(protocol const &);
    protocol &operator=(protocol &&);

    explicit operator bool() const;

    uintptr_t identifier() const;

    template <typename T = impl>
    std::shared_ptr<T> impl_ptr() const;

   protected:
    std::shared_ptr<impl> _impl;

    explicit protocol(std::shared_ptr<impl> const &);
    explicit protocol(std::shared_ptr<impl> &&);

   public:
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
        std::weak_ptr<protocol::impl> _impl;
    };
};

template <typename T>
using is_base_of_protocol = std::is_base_of<protocol, T>;
template <typename T, typename V = void>
using enable_if_base_of_protocol_t = typename std::enable_if_t<is_base_of_protocol<T>::value, V>;

template <typename T, enable_if_base_of_protocol_t<T, std::nullptr_t> = nullptr>
protocol::weak<T> to_weak(T const &obj) {
    return protocol::weak<T>(obj);
}
}  // namespace yas

#include "yas_protocol_private.h"
