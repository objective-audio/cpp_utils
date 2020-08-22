//
//  yas_flagset.h
//

#pragma once

#include <bitset>
#include <initializer_list>

namespace yas {
template <typename T, std::size_t Size = static_cast<typename std::underlying_type<T>::type>(T::count)>
class flagset {
    using flags_size_t = typename std::underlying_type<T>::type;

   public:
    std::bitset<Size> flags;

    flagset();
    flagset(std::initializer_list<T> const &);

    ~flagset();

    flagset(flagset<T> const &);
    flagset(flagset<T> &&);

    flagset<T> &operator=(flagset<T> const &);
    flagset<T> &operator=(flagset<T> &&);

    bool operator==(flagset const &) const;
    bool operator!=(flagset const &) const;

    void set(T const &);
    void set(std::initializer_list<T> const &);
    void reset(T const &);
    void reset(std::initializer_list<T> const &);
    bool test(T const &) const;
    bool and_test(flagset<T> const &) const;
};
}  // namespace yas

#include <cpp_utils/yas_flagset_private.h>
