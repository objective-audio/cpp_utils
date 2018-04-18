//
//  yas_flow.h
//

#pragma once

#include "yas_base.h"
#include "yas_protocol.h"
#include "yas_any.h"
#include <functional>

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

template <typename T>
struct receiver : base {
    struct impl;

    receiver(std::function<void(T const &)>);
    receiver(std::nullptr_t);

    flow::receivable<T> receivable();
};

template <typename T>
struct sender : base {
    class impl;

    sender();
    sender(std::nullptr_t);

    void send_value(T const &);

    void set_can_send_handler(std::function<bool(void)>);
    [[nodiscard]] bool can_send() const;
    void set_send_handler(std::function<T(void)>);
    void send() const;

    node<T, T, T> begin_flow();

    template <typename P>
    void push_handler(std::function<void(P const &)>);
    std::size_t handlers_size() const;
    template <typename P>
    std::function<void(P const &)> const &handler(std::size_t const) const;
};

template <typename Begin>
struct observer : base {
    class impl;

    observer(sender<Begin>);
    observer(std::nullptr_t);

    void sync();
};

template <typename Out, typename In, typename Begin>
struct node : base {
    class impl;

    node(sender<Begin>);
    // private
    node(sender<Begin>, std::function<Out(In const &)>);
    node(std::nullptr_t);

    [[nodiscard]] node<Out, In, Begin> perform(std::function<void(Out const &)>);
    [[nodiscard]] node<Out, In, Begin> receive(receivable<Out>);

    [[nodiscard]] node<Out, Out, Begin> guard(std::function<bool(Out const &)>);

    template <typename Next = Out>
    [[nodiscard]] node<Next, In, Begin> convert(std::function<Next(Out const &)>);

    [[nodiscard]] node<Out, Out, Begin> wait(double const);

    template <typename SubIn, typename SubBegin>
    [[nodiscard]] node<Out, Out, Begin> merge(node<Out, SubIn, SubBegin>);
    [[nodiscard]] node<Out, Out, Begin> merge(sender<Out>);

    [[nodiscard]] observer<Begin> end();
    [[nodiscard]] observer<Begin> end(receivable<Out>);
};
}

#include "yas_flow_private.h"
