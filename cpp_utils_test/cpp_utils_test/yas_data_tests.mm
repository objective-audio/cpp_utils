//
//  yas_data_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_data.h"

using namespace yas;

@interface yas_data_tests : XCTestCase

@end

@implementation yas_data_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_make_data {
    std::vector<float> vec{0, 1, 2};

    auto data = make_data(vec.data(), 3);

    XCTAssertEqual(data.ptr, vec.data());
    XCTAssertEqual(data.length, 3);
}

- (void)test_make_data_from_vector {
    std::vector<float> vec{0, 1, 2, 3};

    auto data = make_data(vec);

    XCTAssertEqual(data.ptr, vec.data());
    XCTAssertEqual(data.length, 4);
}

- (void)test_make_const_data {
    std::vector<float> const vec{0, 1, 2};

    auto data = make_const_data(vec.data(), 3);

    XCTAssertEqual(data.ptr, vec.data());
    XCTAssertEqual(data.length, 3);
}

- (void)test_make_const_data_from_vector {
    std::vector<float> const vec{0, 1, 2, 3};

    auto data = make_const_data(vec);

    XCTAssertEqual(data.ptr, vec.data());
    XCTAssertEqual(data.length, 4);
}

- (void)test_data_copy {
    std::vector<int> src_vec{10, 11, 12};
    std::vector<int> dst_vec{0, 0, 0};

    data_copy<int> data_copy{.src_data = make_const_data(src_vec), .dst_data = make_data(dst_vec), .length = 3};
    data_copy.copy();

    XCTAssertEqual(dst_vec.at(0), 10);
    XCTAssertEqual(dst_vec.at(1), 11);
    XCTAssertEqual(dst_vec.at(2), 12);
}

- (void)test_data_copy_partial {
    std::vector<int> src_vec{10, 11, 12, 13, 14};
    std::vector<int> dst_vec{0, 0, 0, 0, 0};

    data_copy<int> data_copy{.src_data = make_const_data(src_vec),
                             .dst_data = make_data(dst_vec),
                             .src_begin_idx = 1,
                             .dst_begin_idx = 2,
                             .length = 2};
    data_copy.copy();

    XCTAssertEqual(dst_vec.at(0), 0);
    XCTAssertEqual(dst_vec.at(1), 0);
    XCTAssertEqual(dst_vec.at(2), 11);
    XCTAssertEqual(dst_vec.at(3), 12);
    XCTAssertEqual(dst_vec.at(4), 0);
}

@end
