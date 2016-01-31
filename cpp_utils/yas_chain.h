//
//  yas_chain.h
//

#pragma once

#include <functional>
#include <vector>
#include "yas_base.h"

namespace yas {
template <typename T>
class chain_context;

template <typename T>
class chain_context : base {
    using super_class = base;

   public:
    chain_context(T &&default_value, std::vector<std::function<void(chain_context<T>)>> &&functions);

    void set(T &&);
    T const &get() const;
    T &get();

    void next();
    void stop();

   private:
    class impl;
};

void chain(std::vector<std::function<void(chain_context<std::nullptr_t>)>> functions);

template <typename T>
void chain(T default_value, std::vector<std::function<void(chain_context<T>)>> functions);
}

#include "yas_chain_private.h"
