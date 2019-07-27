//
//  yas_system_path_utils.mm
//

#include "yas_system_path_utils.h"
#include <Foundation/Foundation.h>
#include "yas_cf_utils.h"
#include "yas_objc_ptr.h"

using namespace yas;

namespace yas {
static NSSearchPathDirectory to_search_path_directory(system_path_utils::dir const dir) {
    switch (dir) {
        case system_path_utils::dir::application:
            return NSApplicationDirectory;
        case system_path_utils::dir::demo_application:
            return NSDemoApplicationDirectory;
        case system_path_utils::dir::admin_application:
            return NSAdminApplicationDirectory;
        case system_path_utils::dir::library:
            return NSLibraryDirectory;
        case system_path_utils::dir::developer:
            return NSDeveloperDirectory;
        case system_path_utils::dir::documentation:
            return NSDocumentationDirectory;
        case system_path_utils::dir::document:
            return NSDocumentDirectory;
        case system_path_utils::dir::autosaved_information:
            return NSAutosavedInformationDirectory;
        case system_path_utils::dir::desktop:
            return NSDesktopDirectory;
        case system_path_utils::dir::caches:
            return NSCachesDirectory;
        case system_path_utils::dir::application_support:
            return NSApplicationSupportDirectory;
        case system_path_utils::dir::downloads:
            return NSDownloadsDirectory;
        case system_path_utils::dir::input_methods:
            return NSInputMethodsDirectory;
        case system_path_utils::dir::movies:
            return NSMoviesDirectory;
        case system_path_utils::dir::music:
            return NSMusicDirectory;
        case system_path_utils::dir::pictures:
            return NSPicturesDirectory;
        case system_path_utils::dir::shared_public:
            return NSSharedPublicDirectory;
        case system_path_utils::dir::preference_panes:
            return NSPreferencePanesDirectory;
#if (TARGET_OS_MAC && !TARGET_OS_IPHONE)
        case system_path_utils::dir::application_scripts:
            return NSApplicationScriptsDirectory;
#endif
        case system_path_utils::dir::all_applications:
            return NSAllApplicationsDirectory;
        case system_path_utils::dir::all_libraries:
            return NSAllLibrariesDirectory;
        default:
            throw std::invalid_argument("invalid directory.");
    }
}
}

std::string system_path_utils::directory_path(dir const dir) {
    auto path = objc_ptr<NSString *>([&dir] {
        switch (dir) {
            case dir::temporary:
                return NSTemporaryDirectory();
            case dir::home:
                return NSHomeDirectory();
            case dir::open_step_root:
                return NSOpenStepRootDirectory();
            default:
                return NSSearchPathForDirectoriesInDomains(to_search_path_directory(dir), NSUserDomainMask, YES)[0];
        }
    });
    return to_string((__bridge CFStringRef)path.object());
}

url system_path_utils::directory_url(dir const dir) {
    return url::file_url(directory_path(dir));
}
