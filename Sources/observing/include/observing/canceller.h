//
//  canceller.h
//

#pragma once

#include <cstdint>
#include <functional>
#include <memory>

#include "cancellable.h"

namespace yas::observing {
class canceller_pool;
class canceller;
using canceller_ptr = std::shared_ptr<canceller>;
using canceller_wptr = std::weak_ptr<canceller>;

struct canceller final : cancellable {
    using remover_f = std::function<void(uintptr_t const)>;

    ~canceller();

    void cancel() override;
    void ignore();
    [[nodiscard]] bool has_cancellable() const override;
    void add_to(canceller_pool &) override;
    void set_to(cancellable_ptr &) override;

    [[nodiscard]] uintptr_t identifier() const;

    [[nodiscard]] static canceller_ptr make_shared(remover_f &&);

   private:
    canceller(remover_f &&);

    std::weak_ptr<canceller> _weak_canceller;
    std::function<void(uintptr_t const)> _handler;
    bool _cancelled = false;
};

struct empty_canceller final : cancellable {
    [[nodiscard]] static std::shared_ptr<empty_canceller> make_shared();

    void cancel() override;
    [[nodiscard]] bool has_cancellable() const override;
    void add_to(canceller_pool &) override;
    void set_to(cancellable_ptr &) override;

   private:
    empty_canceller();
};
}  // namespace yas::observing
