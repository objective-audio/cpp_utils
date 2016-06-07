//
//  yas_flagset_private.h
//

#pragma once

namespace yas {
template <typename T, std::size_t Size>
flagset<T, Size>::flagset() = default;

template <typename T, std::size_t Size>
flagset<T, Size>::flagset(std::initializer_list<T> const &list) {
    set(list);
}

template <typename T, std::size_t Size>
flagset<T, Size>::~flagset() = default;

template <typename T, std::size_t Size>
flagset<T, Size>::flagset(flagset<T> const &rhs) : flags(rhs.flags) {
}

template <typename T, std::size_t Size>
flagset<T, Size>::flagset(flagset<T> &&rhs) : flags(std::move(rhs.flags)) {
    rhs.flags.reset();
}

template <typename T, std::size_t Size>
flagset<T> &flagset<T, Size>::operator=(flagset<T> const &rhs) {
    flags = rhs.flags;
    return *this;
}

template <typename T, std::size_t Size>
flagset<T> &flagset<T, Size>::operator=(flagset<T> &&rhs) {
    flags = std::move(rhs.flags);
    rhs.flags.reset();
    return *this;
}

template <typename T, std::size_t Size>
bool flagset<T, Size>::operator==(flagset const &rhs) {
    return flags == rhs.flags;
}

template <typename T, std::size_t Size>
bool flagset<T, Size>::operator!=(flagset const &rhs) {
    return flags != rhs.flags;
}

template <typename T, std::size_t Size>
void flagset<T, Size>::set(T const &flag) {
    flags.set(static_cast<flags_size_t>(flag));
}

template <typename T, std::size_t Size>
void flagset<T, Size>::set(std::initializer_list<T> const &list) {
    for (auto const &flag : list) {
        flags.set(static_cast<flags_size_t>(flag));
    }
}

template <typename T, std::size_t Size>
void flagset<T, Size>::reset(T const &flag) {
    flags.reset(static_cast<flags_size_t>(flag));
}

template <typename T, std::size_t Size>
void flagset<T, Size>::reset(std::initializer_list<T> const &list) {
    for (auto const &flag : list) {
        flags.reset(static_cast<flags_size_t>(flag));
    }
}

template <typename T, std::size_t Size>
bool flagset<T, Size>::test(T const &flag) {
    return flags.test(static_cast<flags_size_t>(flag));
}
}