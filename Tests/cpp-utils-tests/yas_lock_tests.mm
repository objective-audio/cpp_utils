//
//  yas_lock_tests.mm
//

#import <XCTest/XCTest.h>
#include <cpp-utils/yas_lock.h>

#include <iostream>

using namespace yas;

@interface yas_lock_shared_tests : XCTestCase

@end

@implementation yas_lock_shared_tests

- (void)test_lock_one {
    auto const src = std::make_shared<int>(1);
    std::weak_ptr<int> weak_src = src;

    auto const locked = yas::lock(weak_src);

    XCTAssertEqual(*std::get<0>(locked), 1);
    XCTAssertTrue(fulfilled(locked));
}

- (void)test_lock_one_no_value {
    std::weak_ptr<int> weak_src;

    auto const locked = yas::lock(weak_src);

    XCTAssertEqual(std::get<0>(locked), nullptr);
    XCTAssertFalse(fulfilled(locked));
}

- (void)test_lock_two {
    auto const src1 = std::make_shared<int>(1);
    auto const src2 = std::make_shared<double>(2.0);
    std::weak_ptr<int> const weak_src1 = src1;
    std::weak_ptr<double> const weak_src2 = src2;

    auto const locked = yas::lock(weak_src1, weak_src2);

    XCTAssertEqual(*std::get<0>(locked), 1);
    XCTAssertEqual(*std::get<1>(locked), 2.0);
    XCTAssertTrue(fulfilled(locked));
}

- (void)test_lock_two_no_first_value {
    auto const src2 = std::make_shared<double>(2.0);
    std::weak_ptr<int> const weak_src1;
    std::weak_ptr<double> const weak_src2 = src2;

    auto const locked = yas::lock(weak_src1, weak_src2);

    XCTAssertEqual(std::get<0>(locked), nullptr);
    XCTAssertEqual(*std::get<1>(locked), 2.0);
    XCTAssertFalse(fulfilled(locked));
}

- (void)test_lock_two_no_second_value {
    auto const src1 = std::make_shared<int>(1);
    std::weak_ptr<int> const weak_src1 = src1;
    std::weak_ptr<double> const weak_src2;

    auto const locked = yas::lock(weak_src1, weak_src2);

    XCTAssertEqual(*std::get<0>(locked), 1);
    XCTAssertEqual(std::get<1>(locked), nullptr);
    XCTAssertFalse(fulfilled(locked));
}

- (void)test_lock_three {
    auto const src1 = std::make_shared<int>(1);
    auto const src2 = std::make_shared<double>(2.0);
    auto const src3 = std::make_shared<std::string>("3");
    std::weak_ptr<int> const weak_src1 = src1;
    std::weak_ptr<double> const weak_src2 = src2;
    std::weak_ptr<std::string> const weak_src3 = src3;

    auto const locked = yas::lock(weak_src1, weak_src2, weak_src3);

    XCTAssertEqual(*std::get<0>(locked), 1);
    XCTAssertEqual(*std::get<1>(locked), 2.0);
    XCTAssertEqual(*std::get<2>(locked), "3");
    XCTAssertTrue(fulfilled(locked));
}

- (void)test_lock_three_no_value {
    auto const src1 = std::make_shared<int>(1);
    auto const src2 = std::make_shared<double>(2.0);
    auto const src3 = std::make_shared<std::string>("3");
    std::weak_ptr<int> weak_src1;
    std::weak_ptr<double> weak_src2;
    std::weak_ptr<std::string> weak_src3;

    {
        weak_src1 = src1;
        weak_src2 = src2;
        weak_src3.reset();

        auto const locked = yas::lock(weak_src1, weak_src2, weak_src3);

        XCTAssertFalse(fulfilled(locked));
    }

    {
        weak_src1 = src1;
        weak_src2.reset();
        weak_src3 = src3;

        auto const locked = yas::lock(weak_src1, weak_src2, weak_src3);

        XCTAssertFalse(fulfilled(locked));
    }

    {
        weak_src1.reset();
        weak_src2 = src2;
        weak_src3 = src3;

        auto const locked = yas::lock(weak_src1, weak_src2, weak_src3);

        XCTAssertFalse(fulfilled(locked));
    }
}

@end
