//
//  each_dictionary_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp-utils/each_dictionary.h>

@interface each_dictionary_tests : XCTestCase

@end

@implementation each_dictionary_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_create {
    NSDictionary *dict = @{@"a": @"1", @"b": @"2"};

    yas::each_dictionary each_dict{(__bridge CFDictionaryRef)dict};

    auto end_iterator = each_dict.end();
    XCTAssertEqual((*end_iterator).first, nullptr);
    XCTAssertEqual((*end_iterator).second, nullptr);

    auto iterator = each_dict.begin();

    XCTAssertTrue(CFEqual((*iterator).first, CFSTR("a")));
    XCTAssertTrue(CFEqual((*iterator).second, CFSTR("1")));

    ++iterator;

    XCTAssertTrue(CFEqual((*iterator).first, CFSTR("b")));
    XCTAssertTrue(CFEqual((*iterator).second, CFSTR("2")));

    ++iterator;

    XCTAssertEqual(iterator, end_iterator);
}

- (void)test_foreach {
    NSDictionary *dict = @{@"a": @"1", @"b": @"2", @"c": @"3"};
    int count = 0;
    for (auto &pair : yas::each_dictionary{(__bridge CFDictionaryRef)dict}) {
        if (pair.first && pair.second) {
            ++count;
        }
    }
    XCTAssertEqual(count, 3);
}

- (void)test_retaion_count {
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:@[@"a"] forKeys:@[@"1"]];
    CFDictionaryRef cf_dict = (__bridge CFDictionaryRef)dict;

    auto pre_count = CFGetRetainCount(cf_dict);

    {
        yas::each_dictionary each_dict{cf_dict};
        XCTAssertEqual(CFGetRetainCount(cf_dict), pre_count + 1);
    }

    auto post_count = CFGetRetainCount(cf_dict);
    XCTAssertEqual(pre_count, post_count);
}

@end
