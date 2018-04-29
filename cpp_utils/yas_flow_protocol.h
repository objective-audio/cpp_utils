//
//  yas_flow_protocol.h
//

#pragma once

#include "yas_base.h"
#include "yas_protocol.h"

namespace yas::flow {
template <typename Out, typename In, typename Begin>
struct node;

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

struct input_flowable : protocol {
    struct impl : protocol::impl {
        virtual void push_handler(yas::any &&) = 0;
        virtual yas::any handler(std::size_t const) = 0;
        virtual std::size_t handlers_size() = 0;
        virtual void add_sub_input(input_base &&) = 0;
    };

    input_flowable(std::shared_ptr<impl> ptr) : protocol(std::move(ptr)) {
    }
    input_flowable(std::nullptr_t) : protocol(nullptr) {
    }

    template <typename P>
    void push_handler(std::function<void(P const &)>);
    std::size_t handlers_size() const {
        return impl_ptr<impl>()->handlers_size();
    }
    template <typename P>
    std::function<void(P const &)> const &handler(std::size_t const) const;
    void add_sub_input(input_base sug_input) {
        impl_ptr<impl>()->add_sub_input(std::move(sug_input));
    }
};

template <typename T>
struct input : input_base {
    class impl;

    input();
    input(std::nullptr_t);
    ~input();

    void send_value(T const &);

    void set_can_send_handler(std::function<bool(void)>);
    [[nodiscard]] bool can_send() const;
    void set_send_handler(std::function<T(void)>);

    [[nodiscard]] node<T, T, T> begin();

    input_flowable &flowable();

   private:
    input_flowable _flowable = nullptr;
};

template <typename T>
struct sender_flowable : protocol {
    struct impl : protocol::impl {
        virtual void erase_input(std::uintptr_t const) = 0;
        virtual bool can_pull() = 0;
        virtual void pull(std::uintptr_t const) = 0;
    };

    sender_flowable(std::shared_ptr<impl>);
    sender_flowable(std::nullptr_t);
};
}
