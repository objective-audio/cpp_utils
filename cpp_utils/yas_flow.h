//
//  yas_flow.h
//

#pragma once

#include "yas_any.h"
#include "yas_types.h"
#include "yas_flow_protocol.h"
#include <functional>

namespace yas::flow {
template <typename T>
struct receiver : base {
    class impl;

    receiver(std::function<void(T const &)>);
    receiver(std::nullptr_t);

    flow::receivable<T> receivable();
    receiver_flowable<T> flowable();

   private:
    receiver_flowable<T> _flowable = nullptr;
};

template <typename T>
struct sender : base {
    class impl;

    sender();
    sender(std::nullptr_t);

    void set_can_sync_handler(std::function<bool(void)>);
    void set_sync_handler(std::function<T(void)>);

    void send_value(T const &);

    [[nodiscard]] node<T, T, T> begin();

    sender_flowable<T> flowable();

   private:
    sender_flowable<T> _flowable = nullptr;
};

template <typename T>
[[nodiscard]] node<T, T, T> begin();

template <typename Begin>
struct observer : base {
    class impl;

    observer(input<Begin>);
    observer(std::nullptr_t);

    flow::input<Begin> &input();

    void sync();
};

template <typename Out, typename In, typename Begin>
struct node : base {
    class impl;

    node(input<Begin>);
    // private
    node(input<Begin>, std::function<Out(In const &)>);
    node(std::nullptr_t);

    [[nodiscard]] node<Out, Out, Begin> normalize();

    [[nodiscard]] node<Out, In, Begin> perform(std::function<void(Out const &)>);
    [[nodiscard]] node<Out, In, Begin> receive(receivable<Out>);
    [[nodiscard]] node<Out, In, Begin> receive(receiver<Out> &);

    [[nodiscard]] node<Out, Out, Begin> guard(std::function<bool(Out const &)>);

    [[nodiscard]] node<Out, In, Begin> convert(std::function<Out(Out const &)>);
    template <typename Next = Out>
    [[nodiscard]] node<Next, In, Begin> convert(std::function<Next(Out const &)>);

    [[nodiscard]] node<Out, Out, Begin> wait(double const);

    template <typename SubIn, typename SubBegin>
    [[nodiscard]] node<Out, Out, Begin> merge(node<Out, SubIn, SubBegin>);

    template <typename SubOut, typename SubIn, typename SubBegin>
    [[nodiscard]] node<std::pair<opt_t<Out>, opt_t<SubOut>>, std::pair<opt_t<Out>, opt_t<SubOut>>, Begin> pair(
        node<SubOut, SubIn, SubBegin>);

    template <typename SubOut, typename SubIn, typename SubBegin>
    [[nodiscard]] node<std::pair<opt_t<Out>, opt_t<SubOut>>, std::pair<opt_t<Out>, opt_t<SubOut>>, Begin> combine(
        node<SubOut, SubIn, SubBegin>);

    [[nodiscard]] observer<Begin> end();
    [[nodiscard]] observer<Begin> end(receiver<Out> &);
};
}

#include "yas_flow_private.h"
