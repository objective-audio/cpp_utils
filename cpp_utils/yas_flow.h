//
//  yas_flow.h
//

#pragma once

#include <functional>
#include "yas_any.h"
#include "yas_flow_protocol.h"
#include "yas_types.h"

namespace yas::flow {
template <typename T = std::nullptr_t>
struct receiver : base {
    class impl;

    receiver(std::function<void(T const &)>);
    receiver(std::function<void(void)>);
    receiver(std::nullptr_t);

    ~receiver() final;

    receiver_flowable<T> flowable();

   private:
    receiver_flowable<T> _flowable = nullptr;
};

template <typename T>
struct sender : base {
    class impl;

    sender();
    sender(std::nullptr_t);

    ~sender() final;

    void set_can_sync_handler(std::function<bool(void)>);
    void set_sync_handler(std::function<T(void)>);

    void send_value(T const &);

    [[nodiscard]] node<T, T, T> begin();

    sender_flowable<T> flowable();

   private:
    sender_flowable<T> _flowable = nullptr;
};

struct observer : base {
    struct impl : base::impl {
        virtual void sync() = 0;
    };

    observer(std::nullptr_t) : base(nullptr) {
    }

    void sync() {
        impl_ptr<impl>()->sync();
    }

   protected:
    observer(std::shared_ptr<impl> &&impl) : base(std::move(impl)) {
    }
};

template <typename Begin>
struct typed_observer : observer {
    class impl;

    typed_observer(input<Begin>);
    typed_observer(std::nullptr_t);

    ~typed_observer() final;

    flow::input<Begin> &input();
};

template <typename Out = std::nullptr_t, typename In = Out, typename Begin = In>
struct node : base {
    class impl;

    node(input<Begin>);
    // private
    node(input<Begin>, std::function<Out(In const &)>);
    node(std::nullptr_t);

    ~node() final;

    [[nodiscard]] node<Out, Out, Begin> normalize();

    [[nodiscard]] node<Out, In, Begin> perform(std::function<void(Out const &)>);

    [[nodiscard]] node<Out, In, Begin> receive(receiver<Out> &);
    [[nodiscard]] node<Out, In, Begin> receive_null(receiver<std::nullptr_t> &);

    [[nodiscard]] node<Out, Out, Begin> guard(std::function<bool(Out const &)>);

    [[nodiscard]] node<Out, In, Begin> to(std::function<Out(Out const &)>);
    template <typename Next = Out>
    [[nodiscard]] node<Next, In, Begin> to(std::function<Next(Out const &)>);
    [[nodiscard]] node<std::nullptr_t, In, Begin> to_null();

    [[nodiscard]] node<Out, Out, Begin> wait(double const);

    template <typename SubIn, typename SubBegin>
    [[nodiscard]] node<Out, Out, Begin> merge(node<Out, SubIn, SubBegin>);

    template <typename SubOut, typename SubIn, typename SubBegin>
    [[nodiscard]] node<std::pair<opt_t<Out>, opt_t<SubOut>>, std::pair<opt_t<Out>, opt_t<SubOut>>, Begin> pair(
        node<SubOut, SubIn, SubBegin>);

    template <typename SubOut, typename SubIn, typename SubBegin>
    [[nodiscard]] node<std::pair<opt_t<Out>, opt_t<SubOut>>, std::pair<opt_t<Out>, opt_t<SubOut>>, Begin> combine(
        node<SubOut, SubIn, SubBegin>);

    [[nodiscard]] typed_observer<Begin> end();
    [[nodiscard]] typed_observer<Begin> end(receiver<Out> &);
    [[nodiscard]] typed_observer<Begin> sync();
    [[nodiscard]] typed_observer<Begin> sync(receiver<Out> &);
};
}  // namespace yas::flow

#include "yas_flow_private.h"
