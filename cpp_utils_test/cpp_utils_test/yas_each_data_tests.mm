//
//  yas_each_data_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_each_data.h"
#import <vector>

using namespace yas;

@interface yas_each_data_tests : XCTestCase

@end

@implementation yas_each_data_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_next_and_read_using_macro {
    std::vector<int8_t> vec0{1, 2, 5, 6};
    std::vector<int8_t> vec1{3, 4, 7, 8};
    std::vector<int8_t *> vecs{vec0.data(), vec1.data()};

    each_data<int8_t> each(vecs.data(), 2, 2, 2);

    XCTAssertTrue(yas_each_data_next(each));
    XCTAssertEqual(yas_each_data_value(each), 1);
    XCTAssertEqual(yas_each_data_index(each), 0);
    XCTAssertEqual(each.frm_idx, 0);
    XCTAssertEqual(each.ptr_idx, 0);
    XCTAssertEqual(each.ch_idx, 0);

    XCTAssertTrue(yas_each_data_next(each));
    XCTAssertEqual(yas_each_data_value(each), 2);
    XCTAssertEqual(yas_each_data_index(each), 1);
    XCTAssertEqual(each.frm_idx, 0);
    XCTAssertEqual(each.ptr_idx, 0);
    XCTAssertEqual(each.ch_idx, 1);

    XCTAssertTrue(yas_each_data_next(each));
    XCTAssertEqual(yas_each_data_value(each), 3);
    XCTAssertEqual(yas_each_data_index(each), 2);
    XCTAssertEqual(each.frm_idx, 0);
    XCTAssertEqual(each.ptr_idx, 1);
    XCTAssertEqual(each.ch_idx, 0);

    XCTAssertTrue(yas_each_data_next(each));
    XCTAssertEqual(yas_each_data_value(each), 4);
    XCTAssertEqual(yas_each_data_index(each), 3);
    XCTAssertEqual(each.frm_idx, 0);
    XCTAssertEqual(each.ptr_idx, 1);
    XCTAssertEqual(each.ch_idx, 1);

    XCTAssertTrue(yas_each_data_next(each));
    XCTAssertEqual(yas_each_data_value(each), 5);
    XCTAssertEqual(yas_each_data_index(each), 4);
    XCTAssertEqual(each.frm_idx, 1);
    XCTAssertEqual(each.ptr_idx, 0);
    XCTAssertEqual(each.ch_idx, 0);

    XCTAssertTrue(yas_each_data_next(each));
    XCTAssertEqual(yas_each_data_value(each), 6);
    XCTAssertEqual(yas_each_data_index(each), 5);
    XCTAssertEqual(each.frm_idx, 1);
    XCTAssertEqual(each.ptr_idx, 0);
    XCTAssertEqual(each.ch_idx, 1);

    XCTAssertTrue(yas_each_data_next(each));
    XCTAssertEqual(yas_each_data_value(each), 7);
    XCTAssertEqual(yas_each_data_index(each), 6);
    XCTAssertEqual(each.frm_idx, 1);
    XCTAssertEqual(each.ptr_idx, 1);
    XCTAssertEqual(each.ch_idx, 0);

    XCTAssertTrue(yas_each_data_next(each));
    XCTAssertEqual(yas_each_data_value(each), 8);
    XCTAssertEqual(yas_each_data_index(each), 7);
    XCTAssertEqual(each.frm_idx, 1);
    XCTAssertEqual(each.ptr_idx, 1);
    XCTAssertEqual(each.ch_idx, 1);

    XCTAssertFalse(yas_each_data_next(each));
}

- (void)test_next_and_write_using_macro {
    std::vector<int8_t> vec0{0, 0, 0, 0};
    std::vector<int8_t> vec1{0, 0, 0, 0};
    std::vector<int8_t *> vecs{vec0.data(), vec1.data()};

    each_data<int8_t> each(vecs.data(), 2, 2, 2);

    XCTAssertTrue(yas_each_data_next(each));
    yas_each_data_value(each) = 1;
    XCTAssertTrue(yas_each_data_next(each));
    yas_each_data_value(each) = 2;
    XCTAssertTrue(yas_each_data_next(each));
    yas_each_data_value(each) = 3;
    XCTAssertTrue(yas_each_data_next(each));
    yas_each_data_value(each) = 4;
    XCTAssertTrue(yas_each_data_next(each));
    yas_each_data_value(each) = 5;
    XCTAssertTrue(yas_each_data_next(each));
    yas_each_data_value(each) = 6;
    XCTAssertTrue(yas_each_data_next(each));
    yas_each_data_value(each) = 7;
    XCTAssertTrue(yas_each_data_next(each));
    yas_each_data_value(each) = 8;
    XCTAssertFalse(yas_each_data_next(each));

    XCTAssertEqual(vec0[0], 1);
    XCTAssertEqual(vec0[1], 2);
    XCTAssertEqual(vec0[2], 5);
    XCTAssertEqual(vec0[3], 6);
    XCTAssertEqual(vec1[0], 3);
    XCTAssertEqual(vec1[1], 4);
    XCTAssertEqual(vec1[2], 7);
    XCTAssertEqual(vec1[3], 8);
}

- (void)test_next_frame_using_macro {
    std::vector<int8_t> vec0{1, 2, 5, 6};
    std::vector<int8_t> vec1{3, 4, 7, 8};
    std::vector<int8_t *> vecs{vec0.data(), vec1.data()};

    {
        each_data<int8_t> each(vecs.data(), 2, 2, 2);

        XCTAssertTrue(yas_each_data_next_frame(each));
        XCTAssertEqual(yas_each_data_index(each), 0);
        XCTAssertEqual(each.frm_idx, 0);
        XCTAssertEqual(each.ptr_idx, 0);
        XCTAssertEqual(each.ch_idx, 0);

        XCTAssertTrue(yas_each_data_next_frame(each));
        XCTAssertEqual(yas_each_data_index(each), 4);
        XCTAssertEqual(each.frm_idx, 1);
        XCTAssertEqual(each.ptr_idx, 0);
        XCTAssertEqual(each.ch_idx, 0);

        XCTAssertFalse(yas_each_data_next_frame(each));
    }
}

- (void)test_next_ch_using_macro {
    std::vector<int8_t> vec0{1, 2, 5, 6};
    std::vector<int8_t> vec1{3, 4, 7, 8};
    std::vector<int8_t *> vecs{vec0.data(), vec1.data()};

    each_data<int8_t> each(vecs.data(), 2, 2, 2);

    XCTAssertTrue(yas_each_data_next_ch(each));
    XCTAssertEqual(yas_each_data_index(each), 0);
    XCTAssertEqual(each.frm_idx, 0);
    XCTAssertEqual(each.ptr_idx, 0);
    XCTAssertEqual(each.ch_idx, 0);

    XCTAssertTrue(yas_each_data_next_ch(each));
    XCTAssertEqual(yas_each_data_index(each), 1);
    XCTAssertEqual(each.frm_idx, 0);
    XCTAssertEqual(each.ptr_idx, 0);
    XCTAssertEqual(each.ch_idx, 1);

    XCTAssertTrue(yas_each_data_next_ch(each));
    XCTAssertEqual(yas_each_data_index(each), 2);
    XCTAssertEqual(each.frm_idx, 0);
    XCTAssertEqual(each.ptr_idx, 1);
    XCTAssertEqual(each.ch_idx, 0);

    XCTAssertTrue(yas_each_data_next_ch(each));
    XCTAssertEqual(yas_each_data_index(each), 3);
    XCTAssertEqual(each.frm_idx, 0);
    XCTAssertEqual(each.ptr_idx, 1);
    XCTAssertEqual(each.ch_idx, 1);

    XCTAssertFalse(yas_each_data_next_ch(each));
}

- (void)test_next_ch_and_frame_using_macro {
    std::vector<int8_t> vec0{1, 2, 5, 6};
    std::vector<int8_t> vec1{3, 4, 7, 8};
    std::vector<int8_t *> vecs{vec0.data(), vec1.data()};

    each_data<int8_t> each(vecs.data(), 2, 2, 2);

    XCTAssertTrue(yas_each_data_next_frame(each));

    XCTAssertTrue(yas_each_data_next_ch(each));
    XCTAssertEqual(yas_each_data_index(each), 0);
    XCTAssertEqual(each.frm_idx, 0);
    XCTAssertEqual(each.ptr_idx, 0);
    XCTAssertEqual(each.ch_idx, 0);

    XCTAssertTrue(yas_each_data_next_ch(each));
    XCTAssertEqual(yas_each_data_index(each), 1);
    XCTAssertEqual(each.frm_idx, 0);
    XCTAssertEqual(each.ptr_idx, 0);
    XCTAssertEqual(each.ch_idx, 1);

    XCTAssertTrue(yas_each_data_next_ch(each));
    XCTAssertEqual(yas_each_data_index(each), 2);
    XCTAssertEqual(each.frm_idx, 0);
    XCTAssertEqual(each.ptr_idx, 1);
    XCTAssertEqual(each.ch_idx, 0);

    XCTAssertTrue(yas_each_data_next_ch(each));
    XCTAssertEqual(yas_each_data_index(each), 3);
    XCTAssertEqual(each.frm_idx, 0);
    XCTAssertEqual(each.ptr_idx, 1);
    XCTAssertEqual(each.ch_idx, 1);

    XCTAssertFalse(yas_each_data_next_ch(each));

    XCTAssertTrue(yas_each_data_next_frame(each));

    XCTAssertTrue(yas_each_data_next_ch(each));
    XCTAssertEqual(yas_each_data_index(each), 4);
    XCTAssertEqual(each.frm_idx, 1);
    XCTAssertEqual(each.ptr_idx, 0);
    XCTAssertEqual(each.ch_idx, 0);

    XCTAssertTrue(yas_each_data_next_ch(each));
    XCTAssertEqual(yas_each_data_index(each), 5);
    XCTAssertEqual(each.frm_idx, 1);
    XCTAssertEqual(each.ptr_idx, 0);
    XCTAssertEqual(each.ch_idx, 1);

    XCTAssertTrue(yas_each_data_next_ch(each));
    XCTAssertEqual(yas_each_data_index(each), 6);
    XCTAssertEqual(each.frm_idx, 1);
    XCTAssertEqual(each.ptr_idx, 1);
    XCTAssertEqual(each.ch_idx, 0);

    XCTAssertTrue(yas_each_data_next_ch(each));
    XCTAssertEqual(yas_each_data_index(each), 7);
    XCTAssertEqual(each.frm_idx, 1);
    XCTAssertEqual(each.ptr_idx, 1);
    XCTAssertEqual(each.ch_idx, 1);

    XCTAssertFalse(yas_each_data_next_ch(each));

    XCTAssertFalse(yas_each_data_next_frame(each));
}

- (void)test_stop_with_next {
    std::vector<int8_t> vec0{1, 2, 5, 6};
    std::vector<int8_t> vec1{3, 4, 7, 8};
    std::vector<int8_t *> vecs{vec0.data(), vec1.data()};
    
    each_data<int8_t> each(vecs.data(), 2, 2, 2);
    
    std::size_t last_idx = 0;
    int8_t last_value = 0;
    
    while (yas_each_data_next(each)) {
        last_idx = yas_each_data_index(each);
        last_value = yas_each_data_value(each);
        if (last_idx == 4) {
            yas_each_data_stop(each);
        }
    }
    
    XCTAssertEqual(last_idx, 4);
    XCTAssertEqual(last_value, 5);
}

- (void)test_stop_with_next_frame {
    std::vector<int8_t> vec0{1, 2, 5, 6};
    std::vector<int8_t> vec1{3, 4, 7, 8};
    std::vector<int8_t *> vecs{vec0.data(), vec1.data()};
    
    each_data<int8_t> each(vecs.data(), 2, 2, 2);
    
    std::size_t last_frm_idx = 0;
    int8_t last_value = 0;
    
    while (yas_each_data_next_frame(each)) {
        yas_each_data_stop(each);
        
        last_frm_idx = each.frm_idx;
        last_value = yas_each_data_value(each);
    }
    
    XCTAssertEqual(last_frm_idx, 0);
    XCTAssertEqual(last_value, 1);
}

- (void)test_stop_with_next_ch {
    std::vector<int8_t> vec0{1, 2, 5, 6};
    std::vector<int8_t> vec1{3, 4, 7, 8};
    std::vector<int8_t *> vecs{vec0.data(), vec1.data()};
    
    each_data<int8_t> each(vecs.data(), 2, 2, 2);
    
    std::size_t last_ptr_idx = 0;
    std::size_t last_ch_idx = 0;
    int8_t last_value = 0;
    
    while (yas_each_data_next_ch(each)) {
        last_ptr_idx = each.ptr_idx;
        last_ch_idx = each.ch_idx;
        last_value = yas_each_data_value(each);
        
        if (yas_each_data_index(each) == 2) {
            yas_each_data_stop(each);
        }
    }
    
    XCTAssertEqual(last_ptr_idx, 1);
    XCTAssertEqual(last_ch_idx, 0);
    XCTAssertEqual(last_value, 3);
}

- (void)test_make_each_data {
    std::vector<int8_t> vec0{1, 2, 5, 6};
    std::vector<int8_t> vec1{3, 4, 7, 8};
    std::vector<int8_t *> vecs{vec0.data(), vec1.data()};

    auto each = make_each_data(vecs.data(), 2, 2, 2);
    
    XCTAssertTrue(yas_each_data_next(each));
    XCTAssertEqual(yas_each_data_value(each), 1);
    
    XCTAssertTrue(yas_each_data_next(each));
    XCTAssertEqual(yas_each_data_value(each), 2);
    
    XCTAssertTrue(yas_each_data_next(each));
    XCTAssertEqual(yas_each_data_value(each), 3);
    
    XCTAssertTrue(yas_each_data_next(each));
    XCTAssertEqual(yas_each_data_value(each), 4);
    
    XCTAssertTrue(yas_each_data_next(each));
    XCTAssertEqual(yas_each_data_value(each), 5);
    
    XCTAssertTrue(yas_each_data_next(each));
    XCTAssertEqual(yas_each_data_value(each), 6);
    
    XCTAssertTrue(yas_each_data_next(each));
    XCTAssertEqual(yas_each_data_value(each), 7);
    
    XCTAssertTrue(yas_each_data_next(each));
    XCTAssertEqual(yas_each_data_value(each), 8);
    
    XCTAssertFalse(yas_each_data_next(each));
}

@end
