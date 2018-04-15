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
struct sender : base {
    class impl;

    sender();
    sender(std::nullptr_t);

    void send_value(T const &);

    void set_can_send_handler(std::function<bool(void)>);
    bool can_send() const;
    void set_send_handler(std::function<T(void)>);
    void send() const;

    node<T, T, T> begin_flow();

    // keeper
    template <typename P>
    void push_handler(std::function<void(P const &)>);
    std::size_t handlers_size() const;
    template <typename P>
    std::function<void(P const &)> const &handler(std::size_t const) const;
};

template <typename Out, typename In, typename Begin>
struct node : base {
    class impl;

    node(sender<Begin>);
    // private
    node(sender<Begin>, std::function<Out(In const &)>);
    node(std::nullptr_t);

    node<Out, In, Begin> execute(std::function<void(In const &)>);
    node<Out, In, Begin> receive(receivable<In>);

    template <typename Next = Out>
    node<Next, In, Begin> change(std::function<Next(In const &)>);

    node<Out, Out, Begin> wait(double const);

    node<std::nullptr_t, In, Begin> end();
    node<std::nullptr_t, In, Begin> end(receivable<In>);
    
    void sync();
};
}

#include "yas_flow_private.h"
