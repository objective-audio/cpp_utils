//
//  yas_property_private.h
//

#pragma once

#include "yas_type_traits.h"

namespace yas {
template <typename T, typename K>
class property<T, K>::impl : public base::impl {
   public:
    validator_t _validator;

    impl(args const &args) : _args(args) {
    }

    impl(args &&args) : _args(std::move(args)) {
    }

    K &key() {
        return _args.key;
    }

    void set_value(T val) {
        _set_value(std::move(val));
    }

    T &value() {
        return _args.value;
    }

    subject_t &subject() {
        return _subject;
    }

   private:
    std::mutex _notify_mutex;
    args _args;
    subject_t _subject;

    template <typename U, typename std::enable_if_t<has_operator_bool<U>::value, std::nullptr_t> = nullptr>
    void _set_value(U &&value) {
        if (_args.value != value && (_args.value || value)) {
            _set_value_primitive(std::move(value));
        }
    }

    template <typename U, typename std::enable_if_t<!has_operator_bool<U>::value, std::nullptr_t> = nullptr>
    void _set_value(U &&value) {
        if (_args.value != value) {
            _set_value_primitive(std::move(value));
        }
    }

    void _set_value_primitive(T &&val) {
        if (_validator && !_validator(val)) {
            throw "validation failed";
        }

        if (_subject.has_observer()) {
            if (auto lock = std::unique_lock<std::mutex>(_notify_mutex, std::try_to_lock)) {
                if (lock.owns_lock()) {
                    if (auto property = cast<yas::property<T, K>>()) {
                        _subject.notify(property_method::will_change,
                                        yas::property<T, K>::change_context{
                                            .old_value = _args.value, .new_value = val, .property = property});

                        auto old_value = std::move(_args.value);
                        _args.value = std::move(val);

                        _subject.notify(property_method::did_change,
                                        yas::property<T, K>::change_context{
                                            .old_value = old_value, .new_value = _args.value, .property = property});
                    }
                }
            }

        } else {
            _args.value = std::move(val);
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
    impl_ptr<impl>()->_validator = std::move(validator);
}

template <typename T, typename K>
typename property<T, K>::validator_t const &property<T, K>::validator() const {
    return impl_ptr<impl>()->_validator;
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
