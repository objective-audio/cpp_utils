//
//  vector_holder.h
//

#pragma once

#include <vector>

#include "syncable.h"

namespace yas::observing::vector {
template <typename T>
class holder;

template <typename T>
using holder_ptr = std::shared_ptr<holder<T>>;

enum class event_type {
    any,
    replaced,
    inserted,
    erased,
};

template <typename T>
struct holder final {
    struct event {
        event_type type;
        std::vector<T> const &elements;
        T const *inserted = nullptr;                      // replaced, inserted
        T const *erased = nullptr;                        // replaced, erased
        std::optional<std::size_t> index = std::nullopt;  // replaced, inserted, erased
    };

    [[nodiscard]] std::vector<T> const &value() const;
    [[nodiscard]] T const &at(std::size_t const) const;
    [[nodiscard]] std::size_t size() const;

    void replace(std::vector<T> const &);
    void replace(std::vector<T> &&);
    void replace(T const &, std::size_t const);
    void replace(T &&, std::size_t const);
    void push_back(T const &);
    void push_back(T &&);
    void insert(T const &, std::size_t const);
    void insert(T &&, std::size_t const);
    T erase(std::size_t const);
    std::optional<T> erase_first(T const &);
    void clear();

    [[nodiscard]] syncable observe(typename caller<event>::handler_f &&);
    [[nodiscard]] syncable observe(std::size_t const order, typename caller<event>::handler_f &&);

    [[nodiscard]] static holder_ptr<T> make_shared();
    [[nodiscard]] static holder_ptr<T> make_shared(std::vector<T> &&);
    [[nodiscard]] static holder_ptr<T> make_shared(std::vector<T> const &);

   private:
    std::vector<T> _raw;
    caller_ptr<event> _caller = nullptr;

    holder(std::vector<T> const &);
    holder(std::vector<T> &&);

    void _call_any();
    void _call_replaced(T const *erased, std::size_t const idx);
    void _call_inserted(std::size_t const idx);
    void _call_erased(T const *, std::size_t const idx);
};
}  // namespace yas::observing::vector

#include "vector_holder_private.h"
