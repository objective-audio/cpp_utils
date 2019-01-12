//
//  yas_data_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/yas_data.h>

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

- (void)test_execute {
    std::vector<int> src_vec{10, 11, 12};
    std::vector<int> dst_vec{0, 0, 0};

    data_copy<int> data_copy{.src_data = make_const_data(src_vec), .dst_data = make_data(dst_vec), .length = 3};

    auto const result = data_copy.execute();

    XCTAssertTrue(result.is_success());

    XCTAssertEqual(dst_vec.at(0), 10);
    XCTAssertEqual(dst_vec.at(1), 11);
    XCTAssertEqual(dst_vec.at(2), 12);
}

- (void)test_execute_float {
    std::vector<float> src_vec{2.0f, 4.0f, 8.0f};
    std::vector<float> dst_vec{0, 0, 0};

    data_copy<float> data_copy{.src_data = make_const_data(src_vec), .dst_data = make_data(dst_vec), .length = 3};

    auto const result = data_copy.execute();

    XCTAssertTrue(result.is_success());

    XCTAssertEqual(dst_vec.at(0), 2.0f);
    XCTAssertEqual(dst_vec.at(1), 4.0f);
    XCTAssertEqual(dst_vec.at(2), 8.0f);
}

- (void)test_execute_double {
    std::vector<double> src_vec{1.0, 0.5, 0.25};
    std::vector<double> dst_vec{0, 0, 0};

    data_copy<double> data_copy{.src_data = make_const_data(src_vec), .dst_data = make_data(dst_vec), .length = 3};

    auto const result = data_copy.execute();

    XCTAssertTrue(result.is_success());

    XCTAssertEqual(dst_vec.at(0), 1.0);
    XCTAssertEqual(dst_vec.at(1), 0.5);
    XCTAssertEqual(dst_vec.at(2), 0.25);
}

- (void)test_execute_partial {
    std::vector<int> src_vec{10, 11, 12, 13, 14};
    std::vector<int> dst_vec{0, 0, 0, 0, 0};

    data_copy<int> data_copy{.src_data = make_const_data(src_vec),
                             .dst_data = make_data(dst_vec),
                             .src_begin_idx = 1,
                             .dst_begin_idx = 2,
                             .length = 2};
    auto const result = data_copy.execute();

    XCTAssertTrue(result.is_success());

    XCTAssertEqual(dst_vec.at(0), 0);
    XCTAssertEqual(dst_vec.at(1), 0);
    XCTAssertEqual(dst_vec.at(2), 11);
    XCTAssertEqual(dst_vec.at(3), 12);
    XCTAssertEqual(dst_vec.at(4), 0);
}

- (void)test_execute_with_stride {
    std::vector<int> src_vec{100, 101, 102, 103, 104, 105};
    std::vector<int> dst_vec{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

    data_copy<int> data_copy{.src_data = make_const_data(src_vec, 2),
                             .dst_data = make_data(dst_vec, 3),
                             .src_begin_idx = 1,
                             .dst_begin_idx = 2,
                             .length = 2};

    auto const result = data_copy.execute();

    XCTAssertTrue(result.is_success());

    XCTAssertEqual(dst_vec.at(0), 0);
    XCTAssertEqual(dst_vec.at(1), 0);
    XCTAssertEqual(dst_vec.at(2), 0);

    XCTAssertEqual(dst_vec.at(3), 0);
    XCTAssertEqual(dst_vec.at(4), 0);
    XCTAssertEqual(dst_vec.at(5), 0);

    XCTAssertEqual(dst_vec.at(6), 102);
    XCTAssertEqual(dst_vec.at(7), 0);
    XCTAssertEqual(dst_vec.at(8), 0);

    XCTAssertEqual(dst_vec.at(9), 104);
    XCTAssertEqual(dst_vec.at(10), 0);
    XCTAssertEqual(dst_vec.at(11), 0);
}

- (void)test_execute_with_stride_float {
    std::vector<float> src_vec{2.0f, 4.0f, 8.0f, 16.0f, 32.0f, 64.0f};
    std::vector<float> dst_vec{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

    data_copy<float> data_copy{.src_data = make_const_data(src_vec, 2),
                               .dst_data = make_data(dst_vec, 3),
                               .src_begin_idx = 1,
                               .dst_begin_idx = 2,
                               .length = 2};

    auto const result = data_copy.execute();

    XCTAssertTrue(result.is_success());

    XCTAssertEqual(dst_vec.at(0), 0);
    XCTAssertEqual(dst_vec.at(1), 0);
    XCTAssertEqual(dst_vec.at(2), 0);

    XCTAssertEqual(dst_vec.at(3), 0);
    XCTAssertEqual(dst_vec.at(4), 0);
    XCTAssertEqual(dst_vec.at(5), 0);

    XCTAssertEqual(dst_vec.at(6), 8.0f);
    XCTAssertEqual(dst_vec.at(7), 0);
    XCTAssertEqual(dst_vec.at(8), 0);

    XCTAssertEqual(dst_vec.at(9), 32.0f);
    XCTAssertEqual(dst_vec.at(10), 0);
    XCTAssertEqual(dst_vec.at(11), 0);
}

- (void)test_execute_with_stride_double {
    std::vector<double> src_vec{4.0f, 2.0f, 1.0f, 0.5f, 0.25f, 0.125f};
    std::vector<double> dst_vec{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

    data_copy<double> data_copy{.src_data = make_const_data(src_vec, 2),
                                .dst_data = make_data(dst_vec, 3),
                                .src_begin_idx = 1,
                                .dst_begin_idx = 2,
                                .length = 2};

    auto const result = data_copy.execute();

    XCTAssertTrue(result.is_success());

    XCTAssertEqual(dst_vec.at(0), 0);
    XCTAssertEqual(dst_vec.at(1), 0);
    XCTAssertEqual(dst_vec.at(2), 0);

    XCTAssertEqual(dst_vec.at(3), 0);
    XCTAssertEqual(dst_vec.at(4), 0);
    XCTAssertEqual(dst_vec.at(5), 0);

    XCTAssertEqual(dst_vec.at(6), 1.0f);
    XCTAssertEqual(dst_vec.at(7), 0);
    XCTAssertEqual(dst_vec.at(8), 0);

    XCTAssertEqual(dst_vec.at(9), 0.25f);
    XCTAssertEqual(dst_vec.at(10), 0);
    XCTAssertEqual(dst_vec.at(11), 0);
}

- (void)test_execute_cyclical {
    std::vector<int> src_vec{20, 21, 22};
    std::vector<int> dst_vec{0, 0, 0, 0, 0};

    data_copy<int> data_copy{.src_data = make_const_data(src_vec),
                             .dst_data = make_data(dst_vec),
                             .src_begin_idx = 0,
                             .dst_begin_idx = 4,
                             .length = 3};

    auto const result = data_copy.execute_cyclical();

    XCTAssertTrue(result.is_success());

    XCTAssertEqual(dst_vec.at(0), 21);
    XCTAssertEqual(dst_vec.at(1), 22);
    XCTAssertEqual(dst_vec.at(2), 0);
    XCTAssertEqual(dst_vec.at(3), 0);
    XCTAssertEqual(dst_vec.at(4), 20);
}

- (void)test_execute_cyclical_with_stride {
    std::vector<int> src_vec{100, 101, 102, 103, 104, 105};
    std::vector<int> dst_vec{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

    data_copy<int> data_copy{.src_data = make_const_data(src_vec, 2),
                             .dst_data = make_data(dst_vec, 3),
                             .src_begin_idx = 1,
                             .dst_begin_idx = 3,
                             .length = 2};

    auto const result = data_copy.execute_cyclical();

    XCTAssertTrue(result.is_success());
    XCTAssertEqual(result.value(), 1);

    XCTAssertEqual(dst_vec.at(0), 104);
    XCTAssertEqual(dst_vec.at(1), 0);
    XCTAssertEqual(dst_vec.at(2), 0);

    XCTAssertEqual(dst_vec.at(3), 0);
    XCTAssertEqual(dst_vec.at(4), 0);
    XCTAssertEqual(dst_vec.at(5), 0);

    XCTAssertEqual(dst_vec.at(6), 0);
    XCTAssertEqual(dst_vec.at(7), 0);
    XCTAssertEqual(dst_vec.at(8), 0);

    XCTAssertEqual(dst_vec.at(9), 102);
    XCTAssertEqual(dst_vec.at(10), 0);
    XCTAssertEqual(dst_vec.at(11), 0);
}

- (void)test_execute_cyclical_with_stride_float {
    std::vector<float> src_vec{2.0f, 4.0f, 8.0f, 16.0f, 32.0f, 64.0f};
    std::vector<float> dst_vec{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

    data_copy<float> data_copy{.src_data = make_const_data(src_vec, 2),
                               .dst_data = make_data(dst_vec, 3),
                               .src_begin_idx = 1,
                               .dst_begin_idx = 3,
                               .length = 2};

    auto const result = data_copy.execute_cyclical();

    XCTAssertTrue(result.is_success());
    XCTAssertEqual(result.value(), 1);

    XCTAssertEqual(dst_vec.at(0), 32.0f);
    XCTAssertEqual(dst_vec.at(1), 0);
    XCTAssertEqual(dst_vec.at(2), 0);

    XCTAssertEqual(dst_vec.at(3), 0);
    XCTAssertEqual(dst_vec.at(4), 0);
    XCTAssertEqual(dst_vec.at(5), 0);

    XCTAssertEqual(dst_vec.at(6), 0);
    XCTAssertEqual(dst_vec.at(7), 0);
    XCTAssertEqual(dst_vec.at(8), 0);

    XCTAssertEqual(dst_vec.at(9), 8.0f);
    XCTAssertEqual(dst_vec.at(10), 0);
    XCTAssertEqual(dst_vec.at(11), 0);
}

- (void)test_execute_cyclical_with_stride_double {
    std::vector<double> src_vec{4.0, 2.0, 1.0, 0.5, 0.25, 0.125};
    std::vector<double> dst_vec{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

    data_copy<double> data_copy{.src_data = make_const_data(src_vec, 2),
                                .dst_data = make_data(dst_vec, 3),
                                .src_begin_idx = 1,
                                .dst_begin_idx = 3,
                                .length = 2};

    auto const result = data_copy.execute_cyclical();

    XCTAssertTrue(result.is_success());
    XCTAssertEqual(result.value(), 1);

    XCTAssertEqual(dst_vec.at(0), 0.25);
    XCTAssertEqual(dst_vec.at(1), 0);
    XCTAssertEqual(dst_vec.at(2), 0);

    XCTAssertEqual(dst_vec.at(3), 0);
    XCTAssertEqual(dst_vec.at(4), 0);
    XCTAssertEqual(dst_vec.at(5), 0);

    XCTAssertEqual(dst_vec.at(6), 0);
    XCTAssertEqual(dst_vec.at(7), 0);
    XCTAssertEqual(dst_vec.at(8), 0);

    XCTAssertEqual(dst_vec.at(9), 1.0);
    XCTAssertEqual(dst_vec.at(10), 0);
    XCTAssertEqual(dst_vec.at(11), 0);
}

@end
