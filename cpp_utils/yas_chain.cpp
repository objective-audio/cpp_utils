//
//  yas_chain.cpp
//

#include "yas_chain.h"
#include "yas_stl_utils.h"

using namespace yas;

struct chain_context::impl : base::impl {
    std::vector<chain_f> functions;
    std::size_t idx = 0;

    impl(chain_v &&v) : functions(std::move(v)) {
    }

    bool call_next(chain_context &context) {
        if (idx < functions.size()) {
            auto const cur_idx = idx;
            ++idx;
            functions.at(cur_idx)(context);
        }
        return false;
    }

    void stop() {
        functions.clear();
    }
};

chain_context::chain_context(chain_v &&functions) : super_class(std::make_unique<impl>(std::move(functions))) {
}

void chain_context::next() {
    impl_ptr<impl>()->call_next(*this);
}

void chain_context::stop() {
    impl_ptr<impl>()->stop();
}

void yas::chain(chain_v functions) {
    if (functions.size() > 0) {
        chain_context context{std::move(functions)};
        context.next();
    }
}