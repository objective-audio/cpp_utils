//
//  yas_flags_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_flagset.h"

#import <iostream>

using namespace yas;

namespace yas {
namespace test {
    enum class test_enum : std::size_t {
        flag_a,
        flag_b,
        flag_c,

        count,
    };
}
}

@interface yas_flags_tests : XCTestCase

@end

@implementation yas_flags_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_create {
    flagset<test::test_enum> flagset;

    XCTAssertEqual(flagset.flags.size(), 3);
}

- (void)test_set {
    flagset<test::test_enum> flagset;

    flagset.set(test::test_enum::flag_a);

    XCTAssertTrue(flagset.test(test::test_enum::flag_a));
    XCTAssertFalse(flagset.test(test::test_enum::flag_b));
    XCTAssertFalse(flagset.test(test::test_enum::flag_c));
}

- (void)test_set_by_initializer_list {
    flagset<test::test_enum> flagset;

    flagset.set({test::test_enum::flag_b, test::test_enum::flag_c});

    XCTAssertFalse(flagset.test(test::test_enum::flag_a));
    XCTAssertTrue(flagset.test(test::test_enum::flag_b));
    XCTAssertTrue(flagset.test(test::test_enum::flag_c));
}

- (void)test_reset {
    flagset<test::test_enum> flagset;
    flagset.flags.set();

    flagset.reset(test::test_enum::flag_b);

    XCTAssertTrue(flagset.test(test::test_enum::flag_a));
    XCTAssertFalse(flagset.test(test::test_enum::flag_b));
    XCTAssertTrue(flagset.test(test::test_enum::flag_c));
}

- (void)test_reset_by_initializer_list {
    flagset<test::test_enum> flagset;
    flagset.flags.set();

    flagset.reset({test::test_enum::flag_a, test::test_enum::flag_c});

    XCTAssertFalse(flagset.test(test::test_enum::flag_a));
    XCTAssertTrue(flagset.test(test::test_enum::flag_b));
    XCTAssertFalse(flagset.test(test::test_enum::flag_c));
}

- (void)test_is_equal {
    flagset<test::test_enum> flagset1;
    flagset<test::test_enum> flagset2;
    flagset<test::test_enum> flagset3;

    flagset1.set(test::test_enum::flag_b);
    flagset2.set(test::test_enum::flag_b);
    flagset3.set(test::test_enum::flag_c);

    XCTAssertTrue(flagset1 == flagset1);
    XCTAssertTrue(flagset1 == flagset2);
    XCTAssertFalse(flagset1 == flagset3);

    XCTAssertFalse(flagset1 != flagset1);
    XCTAssertFalse(flagset1 != flagset2);
    XCTAssertTrue(flagset1 != flagset3);
}

- (void)test_copy_assign {
    flagset<test::test_enum> flagset1;
    flagset<test::test_enum> flagset2;

    flagset1.set(test::test_enum::flag_a);

    flagset2 = flagset1;

    XCTAssertTrue(flagset1 == flagset2);
}

- (void)test_move_assign {
    flagset<test::test_enum> flagset1;
    flagset<test::test_enum> flagset2;

    flagset1.set(test::test_enum::flag_b);
    flagset2.set(test::test_enum::flag_c);

    flagset2 = std::move(flagset1);

    XCTAssertFalse(flagset1.test(test::test_enum::flag_b));
    XCTAssertFalse(flagset1.test(test::test_enum::flag_c));
    XCTAssertTrue(flagset2.test(test::test_enum::flag_b));
    XCTAssertFalse(flagset2.test(test::test_enum::flag_c));
}

- (void)test_copy_constructor {
    flagset<test::test_enum> flagset1;

    flagset1.set(test::test_enum::flag_a);

    flagset<test::test_enum> flagset2{flagset1};

    XCTAssertTrue(flagset1 == flagset2);
}

- (void)test_move_constructor {
    flagset<test::test_enum> flagset1;

    flagset1.set(test::test_enum::flag_b);

    flagset<test::test_enum> flagset2{std::move(flagset1)};

    XCTAssertFalse(flagset1.test(test::test_enum::flag_b));
    XCTAssertFalse(flagset1.test(test::test_enum::flag_c));
    XCTAssertTrue(flagset2.test(test::test_enum::flag_b));
    XCTAssertFalse(flagset2.test(test::test_enum::flag_c));
}

@end
