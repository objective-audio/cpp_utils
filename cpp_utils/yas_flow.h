//
//  yas_flow.h
//

#pragma once

#include <functional>
#include "yas_any.h"
#include "yas_flow_protocol.h"
#include "yas_type_traits.h"
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

    void set_sync_handler(std::function<opt_t<T>(void)>);

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

    [[nodiscard]] auto normalize();

    [[nodiscard]] auto perform(std::function<void(Out const &)>);

    template <std::size_t N = 0, typename T>
    [[nodiscard]] auto receive(receiver<T> &);
    [[nodiscard]] auto receive_null(receiver<std::nullptr_t> &);

    [[nodiscard]] auto guard(std::function<bool(Out const &)>);

    template <typename F>
    [[nodiscard]] auto map(F);
    template <typename T>
    [[nodiscard]] auto to_value(T);
    [[nodiscard]] auto to_null();
    [[nodiscard]] auto to_tuple();

    [[nodiscard]] auto wait(double const);

    template <typename SubIn, typename SubBegin>
    [[nodiscard]] auto merge(node<Out, SubIn, SubBegin>);

    template <typename SubOut, typename SubIn, typename SubBegin>
    [[nodiscard]] auto pair(node<SubOut, SubIn, SubBegin>);

    template <typename SubOut, typename SubIn, typename SubBegin>
    [[nodiscard]] auto combine(node<SubOut, SubIn, SubBegin>);

    [[nodiscard]] typed_observer<Begin> end();
    [[nodiscard]] typed_observer<Begin> sync();
};
}  // namespace yas::flow

#include "yas_flow_private.h"
