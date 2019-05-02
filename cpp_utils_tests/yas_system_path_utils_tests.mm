//
//  yas_system_path_utils_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/yas_system_path_utils.h>

using namespace yas;

@interface yas_system_path_utils_tests : XCTestCase

@end

@implementation yas_system_path_utils_tests

- (void)setUp {
}

- (void)tearDown {
}

- (void)test_application_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::application);
    std::string expected = "/Applications";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_demo_application_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::demo_application);
    std::string expected = "/Applications/Demos";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_admin_application_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::admin_application);
    std::string expected = "/Applications/Utilities";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_library_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::library);
    std::string expected = "/Library";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_developer_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::developer);
    std::string expected = "/Developer";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_documentation_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::documentation);
    std::string expected = "/Library/Documentation";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_document_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::document);
    std::string expected = "/Documents";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_autosaved_information_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::autosaved_information);
    std::string expected = "/Library/Autosave Information";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_desktop_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::desktop);
    std::string expected = "/Desktop";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_caches_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::caches);
    std::string expected = "/Caches";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_application_support_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::application_support);
    std::string expected = "/Library/Application Support";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_downloads_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::downloads);
    std::string expected = "/Downloads";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_input_methods_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::input_methods);
    std::string expected = "/Library/Input Methods";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_movies_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::movies);
    std::string expected = "/Movies";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_music_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::music);
    std::string expected = "/Music";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_pictures_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::pictures);
    std::string expected = "/Pictures";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_shared_public_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::shared_public);
    std::string expected = "/Public";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_preference_panes_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::preference_panes);
    std::string expected = "/Library/PreferencePanes";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

#if (TARGET_OS_MAC && !TARGET_OS_IPHONE)

- (void)test_application_scripts_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::application_scripts);

    XCTAssertTrue(path.size() > 0);
}

#endif

- (void)test_all_applications_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::all_applications);
    std::string expected = "/Applications";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_all_libraries_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::all_libraries);
    std::string expected = "/Library";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
}

- (void)test_temporary_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::temporary);
#if TARGET_OS_IPHONE
    std::string expected = "/tmp/";
    XCTAssertEqual(path.compare(path.size() - expected.size(), expected.size(), expected), 0);
#elif TARGET_OS_MAC
    XCTAssertTrue(path.size() > 0);
#endif
}

- (void)test_home_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::home);

    XCTAssertTrue(path.size() > 0);
}

- (void)test_open_step_root_path {
    auto path = system_path_utils::directory_path(system_path_utils::dir::open_step_root);
    std::string expected = "/";
    XCTAssertEqual(path, expected);
}

@end
