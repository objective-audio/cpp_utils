//
//  yas_chain_private.h
//

#pragma once

namespace yas {
template <typename T>
struct chain_context<T>::impl : base::impl {
    std::vector<std::function<void(chain_context<T>)>> functions;
    std::size_t idx = 0;
    T value;

    impl(T &&default_value, std::vector<std::function<void(chain_context<T>)>> &&v)
        : value(std::move(default_value)), functions(std::move(v)) {
    }

    bool call_next(chain_context &context) {
        if (idx < functions.size()) {
            auto const cur_idx = idx;
            ++idx;
            functions.at(cur_idx)(context);
        }
        return false;
    }

    void stop() {
        functions.clear();
    }
};

template <typename T>
chain_context<T>::chain_context(T &&default_value, std::vector<std::function<void(chain_context<T>)>> &&functions)
    : super_class(std::make_unique<impl>(std::move(default_value), std::move(functions))) {
}

template <typename T>
void chain_context<T>::set(T val) {
    impl_ptr<impl>()->value = std::move(val);
}

template <typename T>
T const &chain_context<T>::get() const {
    return impl_ptr<impl>()->value;
}

template <typename T>
T &chain_context<T>::get() {
    return impl_ptr<impl>()->value;
}

template <typename T>
void chain_context<T>::next() {
    impl_ptr<impl>()->call_next(*this);
}

template <typename T>
void chain_context<T>::stop() {
    impl_ptr<impl>()->stop();
}

template <typename T>
void chain(T default_value, std::vector<std::function<void(chain_context<T>)>> functions) {
    if (functions.size() > 0) {
        chain_context<T> context{std::move(default_value), std::move(functions)};
        context.next();
    }
}
}
