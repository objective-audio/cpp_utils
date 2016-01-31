//
//  yas_chain.cpp
//

#include "yas_chain.h"

using namespace yas;

void yas::chain(std::vector<std::function<void(chain_context<std::nullptr_t>)>> functions) {
    if (functions.size() > 0) {
        chain_context<std::nullptr_t> context{nullptr, std::move(functions)};
        context.next();
    }
}
