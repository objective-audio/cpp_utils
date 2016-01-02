//
//  yas_version.cpp
//

#include <sstream>
#include "yas_each_index.h"
#include "yas_stl_utils.h"
#include "yas_version.h"

using namespace yas;

namespace yas {
static std::vector<int> to_numbers(std::string const &str) {
    std::vector<int> vec;
    std::istringstream stream(replaced(str, ".", " "));
    for (int i; stream >> i;) {
        vec.push_back(i);
    }
    return vec;
}

enum class comparison_result {
    equal,
    ascending,
    descending,
};

static comparison_result compare(version const &lhs, version const &rhs) {
    auto &lhs_numbers = lhs.numbers();
    auto &rhs_numbers = rhs.numbers();
    auto lhs_size = lhs_numbers.size();
    auto rhs_size = rhs_numbers.size();
    auto max_size = std::max(lhs_size, rhs_size);

    for (auto &idx : each_index<size_t>{max_size}) {
        if (idx < lhs_size && idx < rhs_size) {
            auto &lhs_val = lhs_numbers[idx];
            auto &rhs_val = rhs_numbers[idx];
            if (lhs_val != rhs_val) {
                return lhs_val < rhs_val ? comparison_result::ascending : comparison_result::descending;
            }
        } else if (idx < lhs_size) {
            if (lhs_numbers[idx] > 0) {
                return comparison_result::descending;
            }
        } else if (idx < rhs_size) {
            if (rhs_numbers[idx] > 0) {
                return comparison_result::ascending;
            }
        }
    }

    return comparison_result::equal;
}
}

version::version(std::string const &str) : _numbers(to_numbers(str)) {
}

version::version(std::vector<int> const &numbers) : _numbers(numbers) {
}

bool version::operator==(version const &rhs) const {
    return compare(*this, rhs) == comparison_result::equal;
}

bool version::operator!=(version const &rhs) const {
    return compare(*this, rhs) != comparison_result::equal;
}

bool version::operator<(version const &rhs) const {
    return compare(*this, rhs) == comparison_result::ascending;
}

bool version::operator<=(version const &rhs) const {
    return compare(*this, rhs) != comparison_result::descending;
}

bool version::operator>(version const &rhs) const {
    return compare(*this, rhs) == comparison_result::descending;
}

bool version::operator>=(version const &rhs) const {
    return compare(*this, rhs) != comparison_result::ascending;
}

std::string version::str() const {
    return joined(map<std::string>(_numbers, [](int const &i) { return std::to_string(i); }), ".");
}

std::vector<int> const &version::numbers() const {
    return _numbers;
}