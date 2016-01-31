//
//  yas_chain.h
//

#pragma once

#include <functional>
#include <vector>
#include "yas_base.h"

namespace yas {
class chain_context;
using chain_f = std::function<void(chain_context)>;
using chain_v = std::vector<chain_f>;

class chain_context : base {
    using super_class = base;

   public:
    void next();
    void stop();

   private:
    class impl;

    chain_context(chain_v &&functions);

    friend void chain(chain_v);
};

void chain(chain_v functions);
}
