//
//  yas_type_traits.h
//

#pragma once

#include <type_traits>

namespace yas {
template <typename T>
class has_operator_bool {
   private:
    template <typename U>
    static auto confirm(U v) -> decltype(v.operator bool(), std::true_type());
    static auto confirm(...) -> decltype(std::false_type());

   public:
    static bool constexpr value = decltype(confirm(std::declval<T>()))::value;
};

template <typename T, typename U = void>
using enable_if_integral_t = typename std::enable_if_t<std::is_integral<T>::value, U>;
template <typename T, typename U = void>
using enable_if_pointer_t = typename std::enable_if_t<std::is_pointer<T>::value, U>;

template <typename>
struct is_tuple : std::false_type {};
template <typename... T>
struct is_tuple<std::tuple<T...>> : std::true_type {};
template <typename T, typename U = void>
using enable_if_tuple_t = typename std::enable_if_t<is_tuple<T>::value, U>;
template <typename T, typename U = void>
using disable_if_tuple_t = typename std::enable_if_t<!is_tuple<T>::value, U>;
}  // namespace yas
