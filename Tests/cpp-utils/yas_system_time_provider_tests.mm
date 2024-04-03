//
//  yas_system_time_provider_tests.mm
//

#import <XCTest/XCTest.h>
#include <cpp-utils/yas_system_time_provider.h>
#include <thread>

using namespace yas;
using namespace std::chrono_literals;

@interface yas_system_time_provider_tests : XCTestCase

@end

@implementation yas_system_time_provider_tests

- (void)setUp {
}

- (void)tearDown {
}

- (void)test_now {
    auto const provider = system_time_provider::make_shared();

    auto const prev = std::chrono::system_clock::now();

    std::this_thread::sleep_for(1ms);

    auto const now = provider->now();

    std::this_thread::sleep_for(1ms);

    auto const post = std::chrono::system_clock::now();

    XCTAssertTrue(prev < now);
    XCTAssertTrue(now < post);
}

@end
