//
//  yas_flow_private.h
//

#pragma once

#include "yas_timer.h"
#include <vector>
#include <unordered_map>

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
    impl(flow::input<Begin> &&input) : _input(std::move(input)) {
    }

    flow::input<Begin> _input;
};

template <typename Begin>
observer<Begin>::observer(flow::input<Begin> input) : base(std::make_shared<impl>(std::move(input))) {
}

template <typename Begin>
observer<Begin>::observer(std::nullptr_t) : base(nullptr) {
}

template <typename Begin>
flow::input<Begin> &observer<Begin>::input() {
    return impl_ptr<impl>()->_input;
}

template <typename Begin>
void observer<Begin>::sync() {
    impl_ptr<impl>()->_input.send();
}

#pragma mark - input_flowable

template <typename P>
void input_flowable::push_handler(std::function<void(P const &)> handler) {
    impl_ptr<impl>()->push_handler(std::move(handler));
}

template <typename P>
std::function<void(P const &)> const &input_flowable::handler(std::size_t const idx) const {
    return impl_ptr<impl>()->handler(idx).template get<std::function<void(P const &)>>();
}

#pragma mark - input

template <typename T>
struct input<T>::impl : input_base::impl, input_flowable::impl {
    weak<sender<T>> _weak_sender;

    impl(weak<sender<T>> &&weak_sender) : _weak_sender(std::move(weak_sender)) {
    }

    void send_value(T const &value) {
        if (this->_handlers.size() > 0) {
            this->_handlers.front().template get<std::function<void(T const &)>>()(value);
        } else {
            std::runtime_error("handler not found. must call the end.");
        }
    }

    bool can_send() {
        if (auto sender = this->_weak_sender.lock()) {
            return sender.flowable().can_pull();
        } else {
            return false;
        }
    }

#warning todo pullに変える？
    void send() override {
        if (auto sender = this->_weak_sender.lock()) {
            sender.flowable().pull(this->identifier());
        }

        for (auto &sub_input : this->_sub_inputs) {
            sub_input.send();
        }
    }

    void push_handler(yas::any &&handler) override {
        this->_handlers.emplace_back(std::move(handler));
    }

    yas::any handler(std::size_t const idx) override {
        return this->_handlers.at(idx);
    }

    std::size_t handlers_size() override {
        return this->_handlers.size();
    }

    void add_sub_input(input_base &&sub_input) override {
        this->_sub_inputs.emplace_back(std::move(sub_input));
    }

   private:
    std::vector<yas::any> _handlers;
    std::vector<input_base> _sub_inputs;
};

template <typename T>
input<T>::input() : input(weak<sender<T>>()) {
}

template <typename T>
input<T>::input(weak<sender<T>> weak_sender) : input_base(std::make_shared<impl>(std::move(weak_sender))) {
}

template <typename T>
input<T>::input(std::nullptr_t) : input_base(nullptr) {
}

template <typename T>
input<T>::~input() {
    if (impl_ptr() && impl_ptr().unique()) {
        if (auto sender = impl_ptr<impl>()->_weak_sender.lock()) {
            sender.flowable().erase_input(this->identifier());
        }
        impl_ptr().reset();
    }
}

template <typename T>
void input<T>::send_value(T const &value) {
    impl_ptr<impl>()->send_value(value);
}
    
template <typename T>
bool input<T>::can_send() const {
    return impl_ptr<impl>()->can_send();
}

template <typename T>
node<T, T, T> input<T>::begin() {
    return node<T, T, T>(*this);
}

template <typename T>
input_flowable &input<T>::flowable() {
    if (!this->_flowable) {
        this->_flowable = input_flowable{impl_ptr<input_flowable::impl>()};
    }
    return this->_flowable;
}

template <typename T>
node<T, T, T> begin() {
    return flow::input<T>{}.begin();
}

#pragma mark - sender_flowable

template <typename T>
sender_flowable<T>::sender_flowable(std::shared_ptr<impl> impl) : protocol(std::move(impl)) {
}

template <typename T>
sender_flowable<T>::sender_flowable(std::nullptr_t) : protocol(nullptr) {
}

template <typename T>
void sender_flowable<T>::erase_input(std::uintptr_t const key) {
    impl_ptr<impl>()->erase_input(key);
}

template <typename T>
bool sender_flowable<T>::can_pull() {
    return impl_ptr<impl>()->can_pull();
}

template <typename T>
void sender_flowable<T>::pull(std::uintptr_t const key) {
    impl_ptr<impl>()->pull(key);
}

#pragma mark - sender

template <typename T>
struct sender<T>::impl : base::impl, sender_flowable<T>::impl {
    std::function<T(void)> _pull_handler;
    std::function<bool(void)> _can_pull_handler;
    std::unordered_map<std::uintptr_t, weak<input<T>>> inputs;

    node<T, T, T> begin(sender<T> &sender) {
        flow::input<T> input{to_weak(sender)};
        this->inputs.insert(std::make_pair(input.identifier(), to_weak(input)));
        return input.begin();
    }

    void send_value(T const &value) {
        for (auto &pair : this->inputs) {
            weak<flow::input<T>> &weak_input = pair.second;
            if (!!weak_input) {
                weak_input.lock().send_value(value);
            }
        }
    }

    void erase_input(std::uintptr_t const key) override {
        this->inputs.erase(key);
    }

    bool can_pull() override {
        if (auto handler = this->_can_pull_handler) {
            return handler();
        } else {
            return false;
        }
    }

    void pull(std::uintptr_t const key) override {
        if (this->can_pull()) {
            if (auto input = this->inputs.at(key).lock()) {
                input.send_value(this->_pull_handler());
            }
        }
    }
};

template <typename T>
sender<T>::sender() : base(std::make_shared<impl>()) {
}

template <typename T>
sender<T>::sender(std::nullptr_t) : base(nullptr) {
}

template <typename T>
void sender<T>::set_can_pull_handler(std::function<bool(void)> handler) {
    impl_ptr<impl>()->_can_pull_handler = std::move(handler);
}

template <typename T>
void sender<T>::set_pull_handler(std::function<T(void)> handler) {
    impl_ptr<impl>()->_pull_handler = std::move(handler);
}

template <typename T>
void sender<T>::send_value(T const &value) {
    impl_ptr<impl>()->send_value(value);
}

template <typename T>
node<T, T, T> sender<T>::begin() {
    return impl_ptr<impl>()->begin(*this);
}

template <typename T>
sender_flowable<T> sender<T>::flowable() {
    if (!this->_flowable) {
        this->_flowable = sender_flowable<T>{impl_ptr<typename sender_flowable<T>::impl>()};
    }
    return this->_flowable;
}

#pragma mark - node

template <typename Out, typename In, typename Begin>
struct node<Out, In, Begin>::impl : base::impl {
    impl(input<Begin> &&input, std::function<Out(In const &)> &&handler)
        : _input(std::move(input)), _handler(std::move(handler)) {
    }

    input<Begin> _input;
    std::function<Out(In const &)> _handler;
};

template <typename Out, typename In, typename Begin>
node<Out, In, Begin>::node(input<Begin> input) : node(std::move(input), [](Begin const &value) { return value; }) {
}

template <typename Out, typename In, typename Begin>
node<Out, In, Begin>::node(input<Begin> input, std::function<Out(In const &)> handler)
    : base(std::make_shared<impl>(std::move(input), std::move(handler))) {
}

template <typename Out, typename In, typename Begin>
node<Out, In, Begin>::node(std::nullptr_t) : base(nullptr) {
}

template <typename Out, typename In, typename Begin>
node<Out, In, Begin> node<Out, In, Begin>::perform(std::function<void(Out const &)> perform_handler) {
    auto imp = impl_ptr<impl>();
    return node<Out, In, Begin>(
        std::move(imp->_input),
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
    flow::input<Begin> &input = imp->_input;
    auto weak_input = to_weak(input);
    std::size_t const next_idx = input.flowable().handlers_size() + 1;

    input.flowable().template push_handler<In>([
        handler = imp->_handler, weak_input, next_idx, guard_handler = std::move(guard_handler)
    ](In const &value) mutable {
        auto const result = handler(value);
        if (guard_handler(result)) {
            if (auto input = weak_input.lock()) {
                input.flowable().template handler<Out>(next_idx)(result);
            }
        }
    });

    return node<Out, Out, Begin>(input, [](Out const &value) { return value; });
}

template <typename Out, typename In, typename Begin>
node<Out, In, Begin> node<Out, In, Begin>::convert(std::function<Out(Out const &)> convert_handler) {
    return this->convert<Out>(std::move(convert_handler));
}

template <typename Out, typename In, typename Begin>
template <typename Next>
node<Next, In, Begin> node<Out, In, Begin>::convert(std::function<Next(Out const &)> convert_handler) {
    auto imp = impl_ptr<impl>();
    return node<Next, In, Begin>(std::move(imp->_input), [
        convert_handler = std::move(convert_handler), handler = std::move(imp->_handler)
    ](In const &value) { return convert_handler(handler(value)); });
}

template <typename Out, typename In, typename Begin>
node<Out, Out, Begin> node<Out, In, Begin>::wait(double const time_interval) {
    auto imp = impl_ptr<impl>();
    flow::input<Begin> &input = imp->_input;
    auto weak_input = to_weak(input);
    std::size_t const next_idx = input.flowable().handlers_size() + 1;

    input.flowable().template push_handler<In>([
        handler = imp->_handler, time_interval, weak_input, next_idx, timer = yas::timer{nullptr}
    ](In const &value) mutable {
        timer = yas::timer(time_interval, false, [value = handler(value), weak_input, next_idx]() {
            if (auto input = weak_input.lock()) {
                input.flowable().template handler<Out>(next_idx)(value);
            }
        });
    });

    return node<Out, Out, Begin>(input, [](Out const &value) { return value; });
}

template <typename Out, typename In, typename Begin>
template <typename SubIn, typename SubBegin>
node<Out, Out, Begin> node<Out, In, Begin>::merge(node<Out, SubIn, SubBegin> sub_node) {
    auto imp = impl_ptr<impl>();
    flow::input<Begin> &input = imp->_input;
    auto weak_input = to_weak(input);
    std::size_t const next_idx = input.flowable().handlers_size() + 1;

    auto sub_imp = sub_node.template impl_ptr<typename node<Out, SubIn, SubBegin>::impl>();
    auto &sub_input = sub_imp->_input;

    sub_input.flowable().template push_handler<SubIn>(
        [handler = sub_imp->_handler, weak_input, next_idx](SubIn const &value) mutable {
            if (auto input = weak_input.lock()) {
                input.flowable().template handler<Out>(next_idx)(handler(value));
            }
        });

    input.flowable().template push_handler<In>(
        [handler = imp->_handler, weak_input, next_idx](In const &value) mutable {
            if (auto input = weak_input.lock()) {
                input.flowable().template handler<Out>(next_idx)(handler(value));
            }
        });

    input.flowable().add_sub_input(std::move(sub_input));

    return node<Out, Out, Begin>(input, [](Out const &value) { return value; });
}

template <typename Out, typename In, typename Begin>
template <typename SubOut, typename SubIn, typename SubBegin>
[[nodiscard]] node<std::pair<opt_t<Out>, opt_t<SubOut>>, std::pair<opt_t<Out>, opt_t<SubOut>>, Begin>
node<Out, In, Begin>::pair(node<SubOut, SubIn, SubBegin> sub_node) {
    using opt_pair_t = std::pair<opt_t<Out>, opt_t<SubOut>>;

    auto imp = impl_ptr<impl>();
    flow::input<Begin> &input = imp->_input;
    auto weak_input = to_weak(input);
    std::size_t const next_idx = input.flowable().handlers_size() + 1;

    auto sub_imp = sub_node.template impl_ptr<typename node<SubOut, SubIn, SubBegin>::impl>();
    auto &sub_input = sub_imp->_input;

    sub_input.flowable().template push_handler<SubIn>(
        [handler = sub_imp->_handler, weak_input, next_idx](SubIn const &value) mutable {
            if (auto input = weak_input.lock()) {
                input.flowable().template handler<opt_pair_t>(next_idx)(opt_pair_t{nullopt, handler(value)});
            }
        });

    input.flowable().template push_handler<In>(
        [handler = imp->_handler, weak_input, next_idx](In const &value) mutable {
            if (auto input = weak_input.lock()) {
                input.flowable().template handler<opt_pair_t>(next_idx)(opt_pair_t(handler(value), nullopt));
            }
        });

    input.flowable().add_sub_input(std::move(sub_input));

    return node<opt_pair_t, opt_pair_t, Begin>(input, [](opt_pair_t const &value) { return value; });
}

template <typename Out, typename In, typename Begin>
template <typename SubOut, typename SubIn, typename SubBegin>
node<std::pair<opt_t<Out>, opt_t<SubOut>>, std::pair<opt_t<Out>, opt_t<SubOut>>, Begin> node<Out, In, Begin>::combine(
    node<SubOut, SubIn, SubBegin> sub_node) {
    using opt_pair_t = std::pair<opt_t<Out>, opt_t<SubOut>>;

    return this->pair(std::move(sub_node)).convert([opt_pair = opt_pair_t{}](opt_pair_t const &value) mutable {
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
    auto &input = impl_ptr<impl>()->_input;
    input.flowable().template push_handler<In>([handler = impl_ptr<impl>()->_handler](In const &value) {
        handler(value);
    });
    return observer<Begin>(std::move(input));
}

template <typename Out, typename In, typename Begin>
observer<Begin> node<Out, In, Begin>::end(receivable<Out> receiver) {
    return this->receive(std::move(receiver)).end();
}
}
