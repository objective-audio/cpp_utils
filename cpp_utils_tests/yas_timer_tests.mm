

//
//  yas_timer_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/yas_timer.h>

using namespace yas;

@interface yas_timer_tests : XCTestCase

@end

@implementation yas_timer_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_timer_no_repeats {
    XCTestExpectation *exp = [self expectationWithDescription:@"timer"];

    auto timer = yas::timer(0.1, false, [exp]() { [exp fulfill]; });

    [self waitForExpectations:@[exp] timeout:10.0];
}

- (void)test_timer_repeats {
    uint32_t count = 0;

    XCTestExpectation *exp = [self expectationWithDescription:@"timer"];

    auto timer = yas::timer(0.1, true, [exp, &count]() {
        ++count;

        if (count > 1) {
            [exp fulfill];
        }
    });

    [self waitForExpectations:@[exp] timeout:10.0];
}

- (void)test_invalidate {
    uint32_t count_all = 0;
    uint32_t count_invalidated = 0;

    XCTestExpectation *exp = [self expectationWithDescription:@"timer"];

    auto timer = yas::timer(0.05, true, [exp, &count_all]() { ++count_all; });

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(),
                   [&timer, &count_all, &count_invalidated, exp]() mutable {
                       timer.invalidate();
                       count_invalidated = count_all;

                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                                      dispatch_get_main_queue(), [exp]() mutable { [exp fulfill]; });
                   });

    [self waitForExpectations:@[exp] timeout:10.0];

    XCTAssertEqual(count_all, count_invalidated);
    XCTAssertGreaterThan(count_all, 1);
}

- (void)test_invalidate_at_destructor {
    uint32_t count_all = 0;
    uint32_t count_invalidated = 0;

    {
        XCTestExpectation *exp1 = [self expectationWithDescription:@"1"];

        auto timer = yas::timer(0.1, true, [&count_all]() { ++count_all; });

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(),
                       [&count_all, &count_invalidated, exp1]() mutable {
                           count_invalidated = count_all;
                           [exp1 fulfill];
                       });

        [self waitForExpectations:@[exp1] timeout:10.0];
    }

    XCTestExpectation *exp2 = [self expectationWithDescription:@"2"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(),
                   [exp2]() mutable { [exp2 fulfill]; });

    [self waitForExpectations:@[exp2] timeout:10.0];

    XCTAssertEqual(count_all, count_invalidated);
    XCTAssertGreaterThan(count_all, 1);
}

@end
