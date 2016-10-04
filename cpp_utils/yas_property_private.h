//
//  yas_property_private.h
//

#pragma once

#include "yas_type_traits.h"

namespace yas {
template <typename T, typename K>
class property<T, K>::impl : public base::impl {
   public:
    impl(args const &args) : _value(args.value), _key(args.key), _validator(args.validator) {
        _validate(_value);
    }

    impl(args &&args)
        : _value(std::move(args.value)), _key(std::move(args.key)), _validator(std::move(args.validator)) {
        _validate(_value);
    }

    K &key() {
        return _key;
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

    subject_t &subject() {
        return _subject;
    }

   private:
    T _value;
    K _key;
    validator_t _validator = nullptr;
    std::mutex _notify_mutex;
    subject_t _subject;

    template <typename U, typename std::enable_if_t<has_operator_bool<U>::value, std::nullptr_t> = nullptr>
    void _set_value(U &&value) {
        if (_value != value && (_value || value)) {
            _set_value_primitive(std::move(value));
        }
    }

    template <typename U, typename std::enable_if_t<!has_operator_bool<U>::value, std::nullptr_t> = nullptr>
    void _set_value(U &&value) {
        if (_value != value) {
            _set_value_primitive(std::move(value));
        }
    }

    void _set_value_primitive(T &&val) {
        _validate(val);

        if (_subject.has_observer()) {
            if (auto lock = std::unique_lock<std::mutex>(_notify_mutex, std::try_to_lock)) {
                if (lock.owns_lock()) {
                    if (auto property = cast<yas::property<T, K>>()) {
                        _subject.notify(property_method::will_change,
                                        yas::property<T, K>::change_context{
                                            .old_value = _value, .new_value = val, .property = property});

                        auto old_value = std::move(_value);
                        _value = std::move(val);

                        _subject.notify(property_method::did_change,
                                        yas::property<T, K>::change_context{
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
};

template <typename T, typename K>
property<T, K>::property() : property(args{}) {
}

template <typename T, typename K>
property<T, K>::property(args const &args) : base(std::make_shared<impl>(args)) {
}

template <typename T, typename K>
property<T, K>::property(args &&args) : base(std::make_shared<impl>(std::move(args))) {
}

template <typename T, typename K>
property<T, K>::property(std::nullptr_t) : base(nullptr) {
}

template <typename T, typename K>
bool property<T, K>::operator==(property const &rhs) const {
    return impl_ptr() && rhs.impl_ptr() && (impl_ptr() == rhs.impl_ptr());
}

template <typename T, typename K>
bool property<T, K>::operator!=(property const &rhs) const {
    return !impl_ptr() || !rhs.impl_ptr() || (impl_ptr() != rhs.impl_ptr());
}

template <typename T, typename K>
bool property<T, K>::operator==(T const &rhs) const {
    return impl_ptr<impl>()->value() == rhs;
}

template <typename T, typename K>
bool property<T, K>::operator!=(T const &rhs) const {
    return impl_ptr<impl>()->value() != rhs;
}

template <typename T, typename K>
K const &property<T, K>::key() const {
    return impl_ptr<impl>()->key();
}

template <typename T, typename K>
void property<T, K>::set_value(T value) {
    impl_ptr<impl>()->set_value(std::move(value));
}

template <typename T, typename K>
T const &property<T, K>::value() const {
    return impl_ptr<impl>()->value();
}

template <typename T, typename K>
T &property<T, K>::value() {
    return impl_ptr<impl>()->value();
}

template <typename T, typename K>
void property<T, K>::set_validator(validator_t validator) {
    impl_ptr<impl>()->set_validator(std::move(validator));
}

template <typename T, typename K>
typename property<T, K>::validator_t const &property<T, K>::validator() const {
    return impl_ptr<impl>()->validator();
}

template <typename T, typename K>
typename property<T, K>::subject_t &property<T, K>::subject() {
    return impl_ptr<impl>()->subject();
}

template <typename T, typename K>
bool operator==(T const &lhs, property<T, K> const &rhs) {
    return lhs == rhs.value();
}

template <typename T, typename K>
bool operator!=(T const &lhs, property<T, K> const &rhs) {
    return lhs != rhs.value();
}

template <typename T, typename K>
property<T, K> make_property(T value, K key) {
    return property<T, K>{{.key = std::move(key), .value = std::move(value)}};
}
}
