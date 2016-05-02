//
//  yas_property_private.h
//

#pragma once

namespace yas {
template <typename T, typename K>
class property<T, K>::impl : public base::impl {
   public:
    impl(property_args<T, K> const &args) : _args(args) {
    }

    impl(property_args<T, K> &&args) : _args(std::move(args)) {
    }

    void set_property(property const &prop) {
        _weak_property = prop;
    }

    K &key() {
        return _args.key;
    }

    void set_value(T val) {
        if (_subject.has_observer()) {
            if (auto lock = std::unique_lock<std::mutex>(_notify_mutex, std::try_to_lock)) {
                if (lock.owns_lock()) {
                    if (auto property = _weak_property.lock()) {
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

    T &value() {
        return _args.value;
    }

    subject_t &subject() {
        return _subject;
    }

   private:
    std::mutex _notify_mutex;
    property_args<T, K> _args;
    subject_t _subject;
    weak<property<T, K>> _weak_property;
};

template <typename T, typename K>
property<T, K>::property() : property(property_args<T, K>{}) {
}

template <typename T, typename K>
property<T, K>::property(property_args<T, K> const &args) : base(std::make_shared<impl>(args)) {
    impl_ptr<impl>()->set_property(*this);
}

template <typename T, typename K>
property<T, K>::property(property_args<T, K> &&args) : base(std::make_shared<impl>(std::move(args))) {
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
T &property<T, K>::value() {
    return impl_ptr<impl>()->value();
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
