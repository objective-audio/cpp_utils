//
//  yas_system_time_provider.h
//

#pragma once

#include <chrono>
#include <functional>
#include <memory>

namespace yas {
using time_point_t = std::chrono::time_point<std::chrono::system_clock>;

struct system_time_providable {
    virtual ~system_time_providable() = default;

    [[nodiscard]] virtual time_point_t now() = 0;
};

struct system_time_provider final : system_time_providable {
    static std::shared_ptr<system_time_provider> make_shared();

    [[nodiscard]] time_point_t now() override;

   private:
    system_time_provider();
};

struct system_time_provider_stub final : system_time_providable {
    static std::shared_ptr<system_time_provider_stub> make_shared(std::function<time_point_t(void)> &&);

    [[nodiscard]] time_point_t now() override;

   private:
    std::function<time_point_t(void)> const _handler;

    system_time_provider_stub(std::function<time_point_t(void)> &&);
};
}  // namespace yas
