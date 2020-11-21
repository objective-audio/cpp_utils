//
//  yas_enumerator_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/cpp_utils.h>

@interface yas_enumerator_tests : XCTestCase

@end

@implementation yas_enumerator_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_create_with_end {
    yas::each_index<int> each_index(3);

    auto end_iterator = each_index.end();
    XCTAssertEqual(*end_iterator, 3);

    auto iterator = each_index.begin();
    XCTAssertEqual(*iterator, 0);

    iterator++;
    XCTAssertEqual(*iterator, 1);
    iterator++;
    XCTAssertEqual(*iterator, 2);
    iterator++;
    XCTAssertEqual(*iterator, 3);

    XCTAssertEqual(iterator, end_iterator);
}

- (void)test_create_with_range {
    yas::each_index<int> each_index(2, 4);

    auto end_iterator = each_index.end();
    XCTAssertEqual(*end_iterator, 4);

    auto iterator = each_index.begin();
    XCTAssertEqual(*iterator, 2);

    iterator++;
    XCTAssertEqual(*iterator, 3);
    iterator++;
    XCTAssertEqual(*iterator, 4);

    XCTAssertEqual(iterator, end_iterator);
}

- (void)test_out_of_range {
    yas::each_index<int> each_index(5, 1);

    XCTAssertEqual(each_index.begin(), each_index.end());
}

- (void)test_foreach {
    int count = 0;
    for (auto &idx : yas::each_index<int>(0, 10)) {
        XCTAssertEqual(count, idx);
        ++count;
    }
    XCTAssertEqual(count, 10);
}

- (void)test_support_types {
    // integral type only

    yas::each_index<uint8_t>{0};
    yas::each_index<uint16_t>{0};
    yas::each_index<uint32_t>{0};
    yas::each_index<uint64_t>{0};
    yas::each_index<int8_t>{0};
    yas::each_index<int16_t>{0};
    yas::each_index<int32_t>{0};
    yas::each_index<int64_t>{0};

    //    compile error

    //    yas::each_index<float>{0};
    //    yas::each_index<double>{0};
    //    yas::each_index<std::string>{0};
}

- (void)test_make_each {
    std::size_t count = 0;

    for (auto const &idx : yas::make_each_index(3)) {
        XCTAssertEqual(idx, count);
        ++count;
    }

    XCTAssertEqual(count, 3);
}

- (void)test_make_each_with_end {
    std::size_t count = 4;

    for (auto const &idx : yas::make_each_index(4, 7)) {
        XCTAssertEqual(idx, count);
        ++count;
    }

    XCTAssertEqual(count, 7);
}

@end
