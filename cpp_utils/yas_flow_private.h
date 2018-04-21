//
//  yas_flow_private.h
//

#pragma once

#include "yas_timer.h"
#include <vector>

namespace yas::flow {

#pragma mark - receivable

template <typename T>
receivable<T>::receivable(std::shared_ptr<impl> impl) : protocol(std::move(impl)) {
}

template <typename T>
receivable<T>::receivable(std::nullptr_t) : protocol(nullptr) {
}

template <typename T>
void receivable<T>::receive_value(T const &value) {
    impl_ptr<impl>()->receive_value(value);
}

#pragma mark - flow::receiver

template <typename T>
struct flow::receiver<T>::impl : base::impl, flow::receivable<T>::impl {
    std::function<void(T const &)> handler;

    impl(std::function<void(T const &)> &&handler) : handler(std::move(handler)) {
    }

    void receive_value(T const &value) override {
        this->handler(value);
    }
};

template <typename T>
flow::receiver<T>::receiver(std::function<void(T const &)> handler) : base(std::make_shared<impl>(std::move(handler))) {
}

template <typename T>
flow::receiver<T>::receiver(std::nullptr_t) : base(nullptr) {
}

template <typename T>
flow::receivable<T> flow::receiver<T>::receivable() {
    return flow::receivable<T>{impl_ptr<typename flow::receivable<T>::impl>()};
}

#pragma mark - observer

template <typename Begin>
struct observer<Begin>::impl : base::impl {
    impl(flow::sender<Begin> &&sender) : _sender(std::move(sender)) {
    }

    flow::sender<Begin> _sender;
};

template <typename Begin>
observer<Begin>::observer(flow::sender<Begin> sender) : base(std::make_shared<impl>(std::move(sender))) {
}

template <typename Begin>
observer<Begin>::observer(std::nullptr_t) : base(nullptr) {
}

template <typename Begin>
flow::sender<Begin> &observer<Begin>::sender() {
    return impl_ptr<impl>()->_sender;
}

template <typename Begin>
void observer<Begin>::sync() {
    impl_ptr<impl>()->_sender.send();
}

#pragma mark - sender

template <typename T>
struct sender<T>::impl : sender_base::impl {
    std::vector<yas::any> _handlers;
    std::function<bool(void)> _can_send_handler;
    std::function<T(void)> _send_handler;

    void send_value(T const &value) {
        if (this->_handlers.size() > 0) {
            this->_handlers.front().template get<std::function<void(T const &)>>()(value);
        } else {
            std::runtime_error("handler not found. must call the end.");
        }
    }

    bool can_send() {
        if (auto handler = this->_can_send_handler) {
            return handler();
        } else {
            return false;
        }
    }

    void send() override {
        if (this->can_send()) {
            this->send_value(this->_send_handler());
        }
    }
};

template <typename T>
sender<T>::sender() : sender_base(std::make_shared<impl>()) {
}

template <typename T>
sender<T>::sender(std::nullptr_t) : sender_base(nullptr) {
}

template <typename T>
void sender<T>::send_value(T const &value) {
    impl_ptr<impl>()->send_value(value);
}

template <typename T>
void sender<T>::set_can_send_handler(std::function<bool(void)> handler) {
    impl_ptr<impl>()->_can_send_handler = std::move(handler);
}

template <typename T>
bool sender<T>::can_send() const {
    return impl_ptr<impl>()->can_send();
}

template <typename T>
void sender<T>::set_send_handler(std::function<T(void)> handler) {
    impl_ptr<impl>()->_send_handler = std::move(handler);
}

template <typename T>
node<T, T, T> sender<T>::begin_flow() {
    return node<T, T, T>(*this);
}

template <typename T>
template <typename P>
void sender<T>::push_handler(std::function<void(P const &)> handler) {
    impl_ptr<impl>()->_handlers.push_back(handler);
}

template <typename T>
std::size_t sender<T>::handlers_size() const {
    return impl_ptr<impl>()->_handlers.size();
}

template <typename T>
template <typename P>
std::function<void(P const &)> const &sender<T>::handler(std::size_t const idx) const {
    return impl_ptr<impl>()->_handlers.at(idx).template get<std::function<void(P const &)>>();
}

#pragma mark -

template <typename Out, typename In, typename Begin>
struct node<Out, In, Begin>::impl : base::impl {
    impl(sender<Begin> &&sender, std::function<Out(In const &)> &&handler)
        : _sender(std::move(sender)), _handler(std::move(handler)) {
    }

    sender<Begin> _sender;
    std::function<Out(In const &)> _handler;
};

template <typename Out, typename In, typename Begin>
node<Out, In, Begin>::node(sender<Begin> sender) : node(std::move(sender), [](Begin const &value) { return value; }) {
}

template <typename Out, typename In, typename Begin>
node<Out, In, Begin>::node(sender<Begin> sender, std::function<Out(In const &)> handler)
    : base(std::make_shared<impl>(std::move(sender), std::move(handler))) {
}

template <typename Out, typename In, typename Begin>
node<Out, In, Begin>::node(std::nullptr_t) : base(nullptr) {
}

template <typename Out, typename In, typename Begin>
node<Out, In, Begin> node<Out, In, Begin>::perform(std::function<void(Out const &)> perform_handler) {
    auto imp = impl_ptr<impl>();
    return node<Out, In, Begin>(
        std::move(imp->_sender),
        [perform_handler = std::move(perform_handler), handler = std::move(imp->_handler)](In const &value) {
            Out result = handler(value);
            perform_handler(result);
            return result;
        });
}

template <typename Out, typename In, typename Begin>
node<Out, In, Begin> node<Out, In, Begin>::receive(receivable<Out> receiver) {
    return this->perform([receiver = std::move(receiver)](Out const &value) mutable { receiver.receive_value(value); });
}

template <typename Out, typename In, typename Begin>
node<Out, Out, Begin> node<Out, In, Begin>::guard(std::function<bool(Out const &value)> guard_handler) {
    auto imp = impl_ptr<impl>();
    flow::sender<Begin> &sender = imp->_sender;
    auto weak_sender = to_weak(sender);
    std::size_t const next_idx = sender.handlers_size() + 1;

    sender.template push_handler<In>([
        handler = imp->_handler, weak_sender, next_idx, guard_handler = std::move(guard_handler)
    ](In const &value) mutable {
        auto const result = handler(value);
        if (guard_handler(result)) {
            if (auto sender = weak_sender.lock()) {
                sender.template handler<Out>(next_idx)(result);
            }
        }
    });

    return node<Out, Out, Begin>(sender, [](Out const &value) { return value; });
}

template <typename Out, typename In, typename Begin>
template <typename Next>
node<Next, In, Begin> node<Out, In, Begin>::convert(std::function<Next(Out const &)> convert_handler) {
    auto imp = impl_ptr<impl>();
    return node<Next, In, Begin>(std::move(imp->_sender), [
        convert_handler = std::move(convert_handler), handler = std::move(imp->_handler)
    ](In const &value) { return convert_handler(handler(value)); });
}

template <typename Out, typename In, typename Begin>
node<Out, Out, Begin> node<Out, In, Begin>::wait(double const time_interval) {
    auto imp = impl_ptr<impl>();
    flow::sender<Begin> &sender = imp->_sender;
    auto weak_sender = to_weak(sender);
    std::size_t const next_idx = sender.handlers_size() + 1;

    sender.template push_handler<In>([
        handler = imp->_handler, time_interval, weak_sender, next_idx, timer = yas::timer{nullptr}
    ](In const &value) mutable {
        timer = yas::timer(time_interval, false, [value = handler(value), weak_sender, next_idx]() {
            if (auto sender = weak_sender.lock()) {
                sender.template handler<Out>(next_idx)(value);
            }
        });
    });

    return node<Out, Out, Begin>(sender, [](Out const &value) { return value; });
}

template <typename Out, typename In, typename Begin>
template <typename SubIn, typename SubBegin>
node<Out, Out, Begin> node<Out, In, Begin>::merge(node<Out, SubIn, SubBegin> sub_node) {
    auto imp = impl_ptr<impl>();
    flow::sender<Begin> &sender = imp->_sender;
    auto weak_sender = to_weak(sender);
    std::size_t const next_idx = sender.handlers_size() + 1;

    auto sub_imp = sub_node.template impl_ptr<typename node<Out, SubIn, SubBegin>::impl>();
    auto &sub_sender = sub_imp->_sender;

    sub_sender.template push_handler<SubIn>(
        [handler = sub_imp->_handler, weak_sender, next_idx](SubIn const &value) mutable {
            if (auto sender = weak_sender.lock()) {
                sender.template handler<Out>(next_idx)(handler(value));
            }
        });

    sender.template push_handler<In>(
        [handler = imp->_handler, weak_sender, next_idx, sub_sender](In const &value) mutable {
            if (auto sender = weak_sender.lock()) {
                sender.template handler<Out>(next_idx)(handler(value));
            }
        });

    return node<Out, Out, Begin>(sender, [](Out const &value) { return value; });
}

template <typename Out, typename In, typename Begin>
node<Out, Out, Begin> node<Out, In, Begin>::merge(sender<Out> sub_sender) {
    return this->merge(sub_sender.begin_flow());
}

template <typename Out, typename In, typename Begin>
template <typename SubOut, typename SubIn, typename SubBegin>
node<std::pair<opt_t<Out>, opt_t<SubOut>>, std::pair<opt_t<Out>, opt_t<SubOut>>, Begin> node<Out, In, Begin>::combine(
    node<SubOut, SubIn, SubBegin> sub_node) {
    using opt_pair_t = std::pair<opt_t<Out>, opt_t<SubOut>>;

    auto imp = impl_ptr<impl>();
    flow::sender<Begin> &sender = imp->_sender;
    auto weak_sender = to_weak(sender);
    std::size_t const next_idx = sender.handlers_size() + 1;

    auto sub_imp = sub_node.template impl_ptr<typename node<SubOut, SubIn, SubBegin>::impl>();
    auto &sub_sender = sub_imp->_sender;

    sub_sender.template push_handler<SubIn>(
        [handler = sub_imp->_handler, weak_sender, next_idx](SubIn const &value) mutable {
            if (auto sender = weak_sender.lock()) {
                sender.template handler<opt_pair_t>(next_idx)(opt_pair_t{nullopt, handler(value)});
            }
        });

    sender.template push_handler<In>(
        [handler = imp->_handler, weak_sender, next_idx, sub_sender](In const &value) mutable {
            if (auto sender = weak_sender.lock()) {
                sender.template handler<opt_pair_t>(next_idx)(opt_pair_t(handler(value), nullopt));
            }
        });

    return node<opt_pair_t, opt_pair_t, Begin>(sender, [opt_pair = opt_pair_t{}](opt_pair_t const &value) mutable {
        if (value.first) {
            opt_pair.first = value.first;
        }
        if (value.second) {
            opt_pair.second = value.second;
        }
        return opt_pair;
    });
}

template <typename Out, typename In, typename Begin>
observer<Begin> node<Out, In, Begin>::end() {
    auto &sender = impl_ptr<impl>()->_sender;
    sender.template push_handler<In>([handler = impl_ptr<impl>()->_handler](In const &value) { handler(value); });
    return observer<Begin>(std::move(sender));
}

template <typename Out, typename In, typename Begin>
observer<Begin> node<Out, In, Begin>::end(receivable<Out> receiver) {
    return this->receive(std::move(receiver)).end();
}
}
