//
//  yas_property_private.h
//

#pragma once

namespace yas {
template <typename T, typename K>
class property<T, K>::impl : public base::impl {
   public:
    impl(T value, K key) : _key(std::move(key)), _value(std::move(value)) {
    }

    void set_property(property const &prop) {
        _weak_property = prop;
    }

    K &key() {
        return _key;
    }

    void set_value(T val) {
        if (auto lock = std::unique_lock<std::mutex>(_notify_mutex, std::try_to_lock)) {
            if (lock.owns_lock()) {
                if (auto property = _weak_property.lock()) {
                    _subject.notify(property_method::will_change, property);
                    _value = std::move(val);
                    _subject.notify(property_method::did_change, property);
                }
            }
        }
    }

    T &value() {
        return _value;
    }

    yas::subject<property<T, K>, property_method> &subject() {
        return _subject;
    }

   private:
    std::mutex _notify_mutex;
    K _key;
    T _value;
    yas::subject<property<T, K>, property_method> _subject;
    weak<property<T, K>> _weak_property;
};

template <typename T, typename K>
property<T, K>::property() : property(property_args<T, K>{}) {
}

template <typename T, typename K>
property<T, K>::property(property_args<T, K> args)
    : base(std::make_shared<impl>(std::move(args.value), std::move(args.key))) {
    impl_ptr<impl>()->set_property(*this);
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
subject<property<T, K>, property_method> &property<T, K>::subject() {
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
    return property<T, K>{key, value};
}
}
