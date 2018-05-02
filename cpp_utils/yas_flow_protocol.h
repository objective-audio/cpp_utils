//
//  yas_flow_protocol.h
//

#pragma once

#include "yas_base.h"
#include "yas_protocol.h"

namespace yas::flow {
template <typename Out, typename In, typename Begin>
class node;
template <typename T>
class sender;
template <typename T>
class receiver;

template <typename T>
struct receivable : protocol {
    struct impl : protocol::impl {
        virtual void receive_value(T const &) = 0;
    };

    explicit receivable(std::shared_ptr<impl> impl);
    receivable(std::nullptr_t);

    void receive_value(T const &);
};

template <typename T>
struct output : base {
    class impl;

    output(weak<receiver<T>>);
    output(std::nullptr_t);

    void output_value(T const &);
};

struct input_base : base {
    struct impl : base::impl {
        virtual void sync() = 0;
    };

    input_base(std::shared_ptr<impl> &&ptr) : base(std::move(ptr)) {
    }

    input_base(std::nullptr_t) : base(nullptr) {
    }

    void sync() {
        impl_ptr<impl>()->sync();
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
    input(weak<sender<T>>);
    input(std::nullptr_t);
    ~input();

    void input_value(T const &);

    [[nodiscard]] bool can_sync() const;

    [[nodiscard]] node<T, T, T> begin();

    input_flowable &flowable();

   private:
    input_flowable _flowable = nullptr;
};

template <typename T>
struct sender_flowable : protocol {
    struct impl : protocol::impl {
        virtual void erase_input(std::uintptr_t const) = 0;
        virtual bool can_sync() = 0;
        virtual void sync(std::uintptr_t const) = 0;
    };

    sender_flowable(std::shared_ptr<impl>);
    sender_flowable(std::nullptr_t);

    void erase_input(std::uintptr_t const);
    bool can_sync();
    void sync(std::uintptr_t const);
};
}
