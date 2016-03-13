//
//  yas_protocol.h
//

#pragma once

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

    template <typename T>
    std::shared_ptr<T> impl_ptr() const;

   protected:
    std::shared_ptr<impl> _impl;

    explicit protocol(std::shared_ptr<impl> const &);
    explicit protocol(std::shared_ptr<impl> &&);
};
}

#include "yas_protocol_private.h"
