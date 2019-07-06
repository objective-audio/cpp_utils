//
//  yas_type_traits.h
//

#pragma once

#include <array>
#include <type_traits>
#include <vector>

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
struct is_array : std::false_type {};
template <typename T, std::size_t N>
struct is_array<std::array<T, N>> : std::true_type {};
template <typename T, typename U = void>
using enable_if_array_t = typename std::enable_if_t<is_array<T>::value, U>;
template <typename T, typename U = void>
using disable_if_array_t = typename std::enable_if_t<!is_array<T>::value, U>;

template <typename>
struct is_vector : std::false_type {};
template <typename T>
struct is_vector<std::vector<T>> : std::true_type {};
template <typename T, typename U = void>
using enable_if_vector_t = typename std::enable_if_t<is_vector<T>::value, U>;
template <typename T, typename U = void>
using disable_if_vector_t = typename std::enable_if_t<!is_vector<T>::value, U>;

template <typename>
struct is_pair : std::false_type {};
template <typename T, typename U>
struct is_pair<std::pair<T, U>> : std::true_type {};
template <typename T, typename V = void>
using enable_if_pair_t = typename std::enable_if_t<is_pair<T>::value, V>;
template <typename T, typename V = void>
using disable_if_pair_t = typename std::enable_if_t<!is_pair<T>::value, V>;

template <typename>
struct is_tuple : std::false_type {};
template <typename... T>
struct is_tuple<std::tuple<T...>> : std::true_type {};
template <typename T, typename U = void>
using enable_if_tuple_t = typename std::enable_if_t<is_tuple<T>::value, U>;
template <typename T, typename U = void>
using disable_if_tuple_t = typename std::enable_if_t<!is_tuple<T>::value, U>;

template <typename>
struct is_shared_ptr : std::false_type {};
template <typename T>
struct is_shared_ptr<std::shared_ptr<T>> : std::true_type {};
template <typename T, typename U = void>
using enable_if_shared_ptr_t = typename std::enable_if_t<is_shared_ptr<T>::value, U>;
template <typename T, typename U = void>
using disable_if_shared_ptr_t = typename std::enable_if_t<!is_shared_ptr<T>::value, U>;

template <typename F, typename R, typename... Args>
R __return_type__(R (F::*)(Args...));
template <typename F, typename R, typename... Args>
R __return_type__(R (F::*)(Args...) const);
template <typename F>
using return_t = decltype(__return_type__(&F::operator()));
}  // namespace yas
