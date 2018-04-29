//
//  yas_property_private.h
//

#pragma once

#include "yas_type_traits.h"

namespace yas {
template <typename T>
class property<T>::impl : public base::impl, public flow::receivable<T>::impl {
   public:
    impl(args const &args) : _value(args.value), _validator(args.validator), _limiter(args.limiter) {
        _limit(_value);
        _validate(_value);
    }

    impl(args &&args)
        : _value(std::move(args.value)), _validator(std::move(args.validator)), _limiter(std::move(args.limiter)) {
        _limit(_value);
        _validate(_value);
    }

    void set_value(T &&val) {
        _set_value(std::move(val));
    }

    T &value() {
        return _value;
    }

    void set_validator(validator_t &&validator) {
        _validator = std::move(validator);
        _validate(_value);
    }

    validator_t &validator() {
        return _validator;
    }

    void set_limiter(limiter_t &&limiter) {
        _limiter = std::move(limiter);

        if (_limiter) {
            _set_value(_value);
        }
    }

    limiter_t &limiter() {
        return _limiter;
    }

    subject_t &subject() {
        return _subject;
    }

    void receive_value(T const &value) override {
        this->_set_value(value);
    }

    [[nodiscard]] flow::node<T, T, T> begin_flow(property<T> &property) {
        if (!this->_value_sender) {
            flow::sender<T> sender;

            subject_t &subject = this->subject();

            auto observer = subject.make_value_observer(
                property_method::did_change, [weak_sender = to_weak(sender)](change_context const &context) mutable {
                    if (auto sender = weak_sender.lock()) {
                        sender.send_value(context.new_value);
                    }
                });

            auto weak_property = to_weak(property);

            sender.set_can_pull_handler([weak_property]() { return !!weak_property; });

            sender.set_pull_handler([weak_property, observer]() {
                if (auto property = weak_property.lock()) {
                    return property.value();
                } else {
                    throw std::runtime_error("property is null.");
                }
            });

            this->_value_sender = std::move(sender);
        }

        return this->_value_sender.begin();
    }

    [[nodiscard]] flow_context_t begin_context_flow(property<T> &property) {
        if (!this->_context_sender) {
            flow::sender<change_context> sender;

            subject_t &subject = this->_subject;

            auto observer = subject.make_value_observer(
                property_method::did_change, [weak_sender = to_weak(sender)](change_context const &context) mutable {
                    if (auto sender = weak_sender.lock()) {
                        sender.send_value(context);
                    }
                });

            auto weak_property = to_weak(property);

            sender.set_can_pull_handler([weak_property]() { return !!weak_property; });

            sender.set_pull_handler([weak_property, observer]() {
                if (auto property = weak_property.lock()) {
                    auto const &value = property.value();
                    return change_context{.new_value = value, .old_value = value, .property = property};
                } else {
                    throw std::runtime_error("property is null.");
                }
            });

            this->_context_sender = std::move(sender);
        }

        return this->_context_sender.begin();
    }

   private:
    T _value;
    validator_t _validator = nullptr;
    limiter_t _limiter = nullptr;
    std::mutex _notify_mutex;
    subject_t _subject;
    flow::sender<T> _value_sender = nullptr;
    flow::sender<change_context> _context_sender = nullptr;

    template <typename U, typename std::enable_if_t<has_operator_bool<U>::value, std::nullptr_t> = nullptr>
    void _set_value(U &&value) {
        T limited_value = _limit(std::move(value));

        if (_value == limited_value) {
            return;
        }

        if (_value || limited_value) {
            _set_value_primitive(std::move(limited_value));
        }
    }

    template <typename U, typename std::enable_if_t<!has_operator_bool<U>::value, std::nullptr_t> = nullptr>
    void _set_value(U &&value) {
        T limited_value = _limit(std::move(value));

        if (_value == limited_value) {
            return;
        }

        _set_value_primitive(std::move(limited_value));
    }

    void _set_value_primitive(T &&val) {
        _validate(val);

        if (_subject.has_observer()) {
            if (auto lock = std::unique_lock<std::mutex>(_notify_mutex, std::try_to_lock)) {
                if (lock.owns_lock()) {
                    if (auto property = cast<yas::property<T>>()) {
                        _subject.notify(property_method::will_change,
                                        yas::property<T>::change_context{
                                            .old_value = _value, .new_value = val, .property = property});

                        auto old_value = std::move(_value);
                        _value = std::move(val);

                        _subject.notify(property_method::did_change,
                                        yas::property<T>::change_context{
                                            .old_value = old_value, .new_value = _value, .property = property});
                    }
                }
            }
        } else {
            _value = std::move(val);
        }
    }

    void _validate(T &value) {
        if (_validator && !_validator(value)) {
            throw "validation failed.";
        }
    }

    T _limit(T const &value) {
        if (_limiter) {
            return _limiter(value);
        }
        return value;
    }

    T _limit(T &&value) {
        if (_limiter) {
            return _limiter(value);
        }
        return std::move(value);
    }
};

template <typename T>
property<T>::property() : property(args{}) {
}

template <typename T>
property<T>::property(args const &args) : base(std::make_shared<impl>(args)) {
}

template <typename T>
property<T>::property(args &&args) : base(std::make_shared<impl>(std::move(args))) {
}

template <typename T>
property<T>::property(std::nullptr_t) : base(nullptr) {
}

template <typename T>
bool property<T>::operator==(property const &rhs) const {
    return impl_ptr() && rhs.impl_ptr() && (impl_ptr() == rhs.impl_ptr());
}

template <typename T>
bool property<T>::operator!=(property const &rhs) const {
    return !impl_ptr() || !rhs.impl_ptr() || (impl_ptr() != rhs.impl_ptr());
}

template <typename T>
bool property<T>::operator==(T const &rhs) const {
    return impl_ptr<impl>()->value() == rhs;
}

template <typename T>
bool property<T>::operator!=(T const &rhs) const {
    return impl_ptr<impl>()->value() != rhs;
}

template <typename T>
void property<T>::set_value(T value) {
    impl_ptr<impl>()->set_value(std::move(value));
}

template <typename T>
T const &property<T>::value() const {
    return impl_ptr<impl>()->value();
}

template <typename T>
T &property<T>::value() {
    return impl_ptr<impl>()->value();
}

template <typename T>
void property<T>::set_validator(validator_t validator) {
    impl_ptr<impl>()->set_validator(std::move(validator));
}

template <typename T>
typename property<T>::validator_t const &property<T>::validator() const {
    return impl_ptr<impl>()->validator();
}

template <typename T>
void property<T>::set_limiter(limiter_t limiter) {
    impl_ptr<impl>()->set_limiter(std::move(limiter));
}

template <typename T>
typename property<T>::limiter_t const &property<T>::limiter() const {
    return impl_ptr<impl>()->limiter();
}

template <typename T>
typename property<T>::subject_t &property<T>::subject() {
    return impl_ptr<impl>()->subject();
}

template <typename T>
flow::node<T, T, T> property<T>::begin_flow() {
    return impl_ptr<impl>()->begin_flow(*this);
}

template <typename T>
typename property<T>::flow_context_t property<T>::begin_context_flow() {
    return impl_ptr<impl>()->begin_context_flow(*this);
}

template <typename T>
flow::receivable<T> property<T>::receivable() {
    return flow::receivable<T>{impl_ptr<typename flow::receivable<T>::impl>()};
}

template <typename T>
bool operator==(T const &lhs, property<T> const &rhs) {
    return lhs == rhs.value();
}

template <typename T>
bool operator!=(T const &lhs, property<T> const &rhs) {
    return lhs != rhs.value();
}

template <typename T>
property<T> make_property(T value) {
    return property<T>{{.value = std::move(value)}};
}
}
