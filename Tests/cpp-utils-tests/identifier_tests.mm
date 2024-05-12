//
//  identifier_tests.mm
//

#import <XCTest/XCTest.h>
#include <cpp-utils/identifier.h>

using namespace yas;

@interface identifier_tests : XCTestCase

@end

@implementation identifier_tests

- (void)test_equal_copied {
    identifier const id_1{};
    identifier const copied_id_1 = id_1;

    XCTAssertTrue(id_1 == copied_id_1);
    XCTAssertFalse(id_1 != copied_id_1);
}

- (void)test_not_equal_other {
    identifier const id_1{};
    identifier const id_2{};

    XCTAssertFalse(id_1 == id_2);
    XCTAssertTrue(id_1 != id_2);
}

- (void)test_not_equal_moved {
    identifier id_1{};
    identifier moved_id_1 = std::move(id_1);
    identifier id_2{};
    identifier moved_id_2 = std::move(id_2);

    XCTAssertFalse(id_1 == moved_id_1);
    XCTAssertTrue(id_1 != moved_id_1);

    XCTAssertFalse(id_1 == id_2);
    XCTAssertTrue(id_1 != id_2);
}

@end
