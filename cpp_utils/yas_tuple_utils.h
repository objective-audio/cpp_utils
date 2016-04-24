//
//  yas_tuple_utils.h
//

#pragma once

#include <tuple>
#include "yas_result.h"

namespace yas {
template <typename Tpl>
bool is_true_all_values(Tpl const &tpl);

template <typename... Args>
result<std::tuple<Args...>, std::nullptr_t> make_tuple_result(Args &&... args);
}

#include "yas_tuple_utils_private.h"
