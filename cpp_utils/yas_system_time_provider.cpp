//
//  yas_system_time_provider.cpp
//

#include "yas_system_time_provider.h"

using namespace yas;

#pragma mark - system_time_provider

std::shared_ptr<system_time_provider> system_time_provider::make_shared() {
    return std::shared_ptr<system_time_provider>(new system_time_provider{});
}

system_time_provider::system_time_provider() {
}

std::chrono::time_point<std::chrono::system_clock> system_time_provider::now() {
    return std::chrono::system_clock::now();
}

#pragma mark - system_time_provider_stub

std::shared_ptr<system_time_provider_stub> system_time_provider_stub::make_shared(
    std::function<time_point_t(void)> &&handler) {
    return std::shared_ptr<system_time_provider_stub>(new system_time_provider_stub{std::move(handler)});
}

system_time_provider_stub::system_time_provider_stub(std::function<time_point_t(void)> &&handler)
    : _handler(std::move(handler)) {
}

time_point_t system_time_provider_stub::now() {
    return this->_handler();
}
