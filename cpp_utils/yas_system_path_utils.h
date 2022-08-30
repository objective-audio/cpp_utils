//
//  yas_system_path_utils.h
//

#pragma once

#include <cpp_utils/yas_url.h>

#include <filesystem>
#include <string>

namespace yas::system_path_utils {
enum class dir {
    application,
    demo_application,
    admin_application,
    library,
    developer,
    documentation,
    document,
    autosaved_information,
    desktop,
    caches,
    application_support,
    downloads,
    input_methods,
    movies,
    music,
    pictures,
    shared_public,
    preference_panes,
#if (TARGET_OS_MAC && !TARGET_OS_IPHONE)
    application_scripts,
#endif
    all_applications,
    all_libraries,

    temporary,
    home,
    open_step_root,
};

[[nodiscard]] std::filesystem::path directory_path(dir const);
}  // namespace yas::system_path_utils
