//
//  yas_flow_protocol.h
//

#pragma once

#include "yas_base.h"
#include "yas_protocol.h"

namespace yas::flow {
template <typename T>
struct receivable : protocol {
    struct impl : protocol::impl {
        virtual void receive_value(T const &) = 0;
    };

    explicit receivable(std::shared_ptr<impl> impl);
    receivable(std::nullptr_t);

    void receive_value(T const &);
};

struct input_base : base {
    struct impl : base::impl {
        virtual void send() = 0;
    };

    input_base(std::shared_ptr<impl> &&ptr) : base(std::move(ptr)) {
    }

    input_base(std::nullptr_t) : base(nullptr) {
    }

    void send() {
        impl_ptr<impl>()->send();
    }
};

struct input_manageable : protocol {
    struct impl : protocol::impl {
        virtual void push_handler(yas::any &&) = 0;
        virtual yas::any handler(std::size_t const) = 0;
        virtual std::size_t handlers_size() = 0;
        virtual void add_sub_input(input_base &&) = 0;
    };

    input_manageable(std::shared_ptr<impl> ptr) : protocol(std::move(ptr)) {
    }
    input_manageable(std::nullptr_t) : protocol(nullptr) {
    }

    template <typename P>
    void push_handler(std::function<void(P const &)>);
    std::size_t handlers_size() const {
        return impl_ptr<impl>()->handlers_size();
    }
    template <typename P>
    std::function<void(P const &)> const &handler(std::size_t const) const;
    void add_sub_input(input_base sub_sender) {
        impl_ptr<impl>()->add_sub_input(std::move(sub_sender));
    }
};
}
