//
//  yas_cf_tests.m
//

#import <XCTest/XCTest.h>
#import <cpp_utils/cpp_utils.h>

@interface yas_cf_tests : XCTestCase

@end

@implementation yas_cf_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testRetaining {
    CFMutableArrayRef _property_array = nullptr;
    CFMutableArrayRef array = CFArrayCreateMutable(nullptr, 1, nullptr);

    XCTAssertEqual(CFGetRetainCount(array), 1);

    yas::set_cf_property(_property_array, array);

    XCTAssertEqual(_property_array, array);
    XCTAssertEqual(CFGetRetainCount(array), 2);

    CFRelease(array);

    XCTAssertEqual(CFGetRetainCount(array), 1);

    @autoreleasepool {
        CFMutableArrayRef array2 = yas::get_cf_property(_property_array);

        XCTAssertEqual(_property_array, array2);
        XCTAssertEqual(CFGetRetainCount(array), 2);
    }

    XCTAssertEqual(CFGetRetainCount(array), 1);

    CFRelease(array);
}

- (void)testStringToCFString {
    std::string string("test_string");

    CFStringRef cf_string = yas::to_cf_object(string);

    CFComparisonResult result = CFStringCompare(cf_string, CFSTR("test_string"), kNilOptions);

    XCTAssertEqual(result, kCFCompareEqualTo);
}

- (void)testStringToCFStringFailed {
    std::string string("\202");

    CFStringRef cf_string = yas::to_cf_object(string);

    CFComparisonResult result = CFStringCompare(cf_string, CFSTR(""), kNilOptions);

    XCTAssertEqual(result, kCFCompareEqualTo);
}

- (void)testCFStringToString {
    CFStringRef cf_string = CFSTR("test_cf_string");

    std::string string = yas::to_string(cf_string);

    XCTAssertTrue(string == std::string("test_cf_string"));

    CFRelease(cf_string);
}

- (void)testFloat32ToCFNumber {
    float value = 1.5;

    CFNumberRef cf_number = yas::to_cf_object(value);

    XCTAssertEqual(CFNumberCompare(cf_number, (CFNumberRef)(@1.5), nullptr), kCFCompareEqualTo);
}

- (void)testFloat64ToCFNumber {
    double value = 2.6;

    CFNumberRef cf_number = yas::to_cf_object(value);

    XCTAssertEqual(CFNumberCompare(cf_number, (CFNumberRef)(@2.6), nullptr), kCFCompareEqualTo);
}

- (void)testSInt32ToCFNumber {
    int32_t value = 3;

    CFNumberRef cf_number = yas::to_cf_object(value);

    XCTAssertEqual(CFNumberCompare(cf_number, (CFNumberRef)(@3), nullptr), kCFCompareEqualTo);
}

- (void)testSInt16ToCFNumber {
    int16_t value = 123;

    CFNumberRef cf_number = yas::to_cf_object(value);

    XCTAssertEqual(CFNumberCompare(cf_number, (CFNumberRef)(@123), nullptr), kCFCompareEqualTo);
}

- (void)testVectorToCFArray {
    std::string value1 = "test_value_1";
    std::string value2 = "test_value_2";
    std::vector<std::string> vector{value1, value2};

    CFArrayRef cf_array = yas::to_cf_object(vector);

    XCTAssertEqual(CFArrayGetCount(cf_array), 2);

    CFStringRef const cf_value1 = static_cast<CFStringRef>(CFArrayGetValueAtIndex(cf_array, 0));
    CFStringRef const cf_value2 = static_cast<CFStringRef>(CFArrayGetValueAtIndex(cf_array, 1));

    XCTAssertTrue(CFStringCompare(cf_value1, CFSTR("test_value_1"), kNilOptions) == kCFCompareEqualTo);
    XCTAssertTrue(CFStringCompare(cf_value2, CFSTR("test_value_2"), kNilOptions) == kCFCompareEqualTo);
}

- (void)testMapToCFDictionary {
    std::string const key1 = "key_1";
    int16_t const value1 = 10;

    std::string const key2 = "key_2";
    int16_t const value2 = 20;

    std::unordered_map<std::string, int16_t> map{{key1, value1}, {key2, value2}};

    CFDictionaryRef const cf_dictionary = yas::to_cf_object(map);

    CFStringRef const cf_key1 = CFSTR("key_1");
    CFStringRef const cf_key2 = CFSTR("key_2");

    XCTAssertEqual(CFDictionaryGetCount(cf_dictionary), 2);
    XCTAssertTrue(CFDictionaryContainsKey(cf_dictionary, CFSTR("key_1")));
    XCTAssertTrue(CFDictionaryContainsKey(cf_dictionary, CFSTR("key_1")));

    CFNumberRef cf_value1 = static_cast<CFNumberRef>(CFDictionaryGetValue(cf_dictionary, cf_key1));
    CFNumberRef cf_value2 = static_cast<CFNumberRef>(CFDictionaryGetValue(cf_dictionary, cf_key2));

    XCTAssertTrue(CFNumberCompare(cf_value1, (CFNumberRef)(@(10)), nullptr) == kCFCompareEqualTo);
    XCTAssertTrue(CFNumberCompare(cf_value2, (CFNumberRef)(@(20)), nullptr) == kCFCompareEqualTo);
}

#pragma mark -

- (void)testFileTypeStringWithHFSTypeCodeSuccess {
    CFStringRef fileType = yas::file_type_for_hfs_type_code('abcd');
    XCTAssertEqualObjects((__bridge NSString *)fileType, @"'abcd'");
}

- (void)testFileTypeStringWithHFSTypeCodeZeroSuccess {
    OSType fcc = 0;
    CFStringRef fileType = yas::file_type_for_hfs_type_code(fcc);
    XCTAssertEqualObjects((__bridge NSString *)fileType, @"''");
}

- (void)testHFSTypeCodeSuccess {
    OSType fcc = yas::hfs_type_code_from_file_type(CFSTR("'abcd'"));
    XCTAssertEqual(fcc, 'abcd');
}

- (void)testHFSTypeCodeIncludeQuoteSuccess {
    OSType fcc = yas::hfs_type_code_from_file_type(CFSTR("'ab'c'"));
    XCTAssertEqual(fcc, 'ab\'c');
}

- (void)testHFSTypeCodeNoQuotesFail {
    OSType fcc = yas::hfs_type_code_from_file_type(CFSTR("abcd"));
    XCTAssertEqual(fcc, 0);
}

- (void)testHFSTypeCodeGapQuotesFail {
    OSType fcc = yas::hfs_type_code_from_file_type(CFSTR("'abc'd"));
    XCTAssertEqual(fcc, 0);
}

- (void)testHFSTypeCodeShortCharacterFail {
    OSType fcc = yas::hfs_type_code_from_file_type(CFSTR("'abc'"));
    XCTAssertEqual(fcc, 0);
}

- (void)testHFSTypeCodeLongCharacterFail {
    OSType fcc = yas::hfs_type_code_from_file_type(CFSTR("'abcde'"));
    XCTAssertEqual(fcc, 0);
}

- (void)testHFSTypeCodeJapaneseFail {
    OSType fcc = yas::hfs_type_code_from_file_type(CFSTR("'あいうえ'"));
    XCTAssertEqual(fcc, 0);
}

- (void)testHFSTypeCodeEmojiFail {
    OSType fcc = yas::hfs_type_code_from_file_type(CFSTR("'😊😓💦😱'"));
    XCTAssertEqual(fcc, 0);
}

- (void)test_to_vector {
    CFArrayRef array = (__bridge CFArrayRef)(@[@"a", @"b", @"c"]);

    auto vector =
        yas::to_vector<std::string>(array, [](CFTypeRef const &obj) { return yas::to_string((CFStringRef)obj); });

    XCTAssertEqual(vector.size(), 3);
    XCTAssertEqual(vector.at(0), "a");
    XCTAssertEqual(vector.at(1), "b");
    XCTAssertEqual(vector.at(2), "c");
}

@end
