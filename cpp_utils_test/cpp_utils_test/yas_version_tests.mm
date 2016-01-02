//
//  yas_version_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_version.h"

@interface yas_version_tests : XCTestCase

@end

@implementation yas_version_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_create_version_with_string {
    yas::version version{"1.2.3"};

    XCTAssertEqual(version.numbers().size(), 3);

    auto const &numbers = version.numbers();
    XCTAssertEqual(numbers.at(0), 1);
    XCTAssertEqual(numbers.at(1), 2);
    XCTAssertEqual(numbers.at(2), 3);

    XCTAssertEqual(version.str(), "1.2.3");
}

- (void)test_create_version_with_numbers {
    yas::version version{std::vector<int>{5, 4, 3, 2}};

    XCTAssertEqual(version.numbers().size(), 4);

    auto const &numbers = version.numbers();
    XCTAssertEqual(numbers.at(0), 5);
    XCTAssertEqual(numbers.at(1), 4);
    XCTAssertEqual(numbers.at(2), 3);
    XCTAssertEqual(numbers.at(3), 2);

    XCTAssertEqual(version.str(), "5.4.3.2");
}

- (void)test_equal {
    yas::version ver1{"1.2.3"};
    yas::version ver2{"1.2.3"};

    XCTAssertTrue(ver1 == ver2);

    yas::version ver3{"1.2.0"};
    yas::version ver4{"1.2"};

    XCTAssertTrue(ver1 == ver2);

    yas::version ver5{"1.2.3"};
    yas::version ver6{"1.5.3"};

    XCTAssertFalse(ver5 == ver6);
}

- (void)test_not_equal {
    yas::version ver1{"1.2.3"};
    yas::version ver2{"1.2.3"};

    XCTAssertFalse(ver1 != ver2);

    yas::version ver3{"1.2.0"};
    yas::version ver4{"1.2"};

    XCTAssertFalse(ver1 != ver2);

    yas::version ver5{"1.2.3"};
    yas::version ver6{"1.5.3"};

    XCTAssertTrue(ver5 != ver6);
}

- (void)test_less {
    yas::version ver1{"1.2.3"};
    yas::version ver2{"1.2.4"};

    XCTAssertTrue(ver1 < ver2);

    yas::version ver3{"1.2.5"};
    yas::version ver4{"1.2.5"};

    XCTAssertFalse(ver3 < ver4);
}

- (void)test_less_or_equal {
    yas::version ver1{"1.2.3"};
    yas::version ver2{"1.2.4"};

    XCTAssertTrue(ver1 <= ver2);

    yas::version ver3{"1.2.5"};
    yas::version ver4{"1.2.5"};

    XCTAssertTrue(ver3 <= ver4);
}

- (void)test_greater {
    yas::version ver1{"1.2.4"};
    yas::version ver2{"1.2.3"};

    XCTAssertTrue(ver1 > ver2);

    yas::version ver3{"1.2.5"};
    yas::version ver4{"1.2.5"};

    XCTAssertFalse(ver3 > ver4);
}

- (void)test_greater_or_equal {
    yas::version ver1{"1.2.4"};
    yas::version ver2{"1.2.3"};

    XCTAssertTrue(ver1 >= ver2);

    yas::version ver3{"1.2.5"};
    yas::version ver4{"1.2.5"};

    XCTAssertTrue(ver3 >= ver4);
}

@end
