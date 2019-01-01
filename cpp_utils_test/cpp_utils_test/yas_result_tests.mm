//
//  yas_result_tests.m
//

#import <XCTest/XCTest.h>
#import <cpp_utils/yas_result.h>
#import <vector>

using namespace yas;

@interface yas_result_tests : XCTestCase

@end

@implementation yas_result_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_create_success_result_move_constructor {
    std::string value("test_value");
    yas::result<std::string, int> result(std::move(value));

    XCTAssertTrue(result);
    XCTAssertTrue(result.is_success());
    XCTAssertFalse(result.is_error());
    XCTAssertEqual(result.value(), std::string("test_value"));

    XCTAssertNotEqual(value, result.value());
}

- (void)test_create_success_result_copy_constructor {
    std::string value("test_value");
    yas::result<std::string, int> result(value);

    XCTAssertTrue(result);
    XCTAssertTrue(result.is_success());
    XCTAssertFalse(result.is_error());
    XCTAssertEqual(result.value(), std::string("test_value"));

    XCTAssertEqual(value, result.value());
}

- (void)test_create_void_ptr_sucess_result {
    yas::result<std::nullptr_t, int> result(nullptr);

    XCTAssertTrue(result);
    XCTAssertTrue(result.is_success());
    XCTAssertFalse(result.is_error());
    XCTAssertEqual(result.value(), nullptr);
}

- (void)test_create_error_result_move_constructor {
    std::string error("test_error");
    yas::result<bool, std::string> result(std::move(error));

    XCTAssertFalse(result);
    XCTAssertFalse(result.is_success());
    XCTAssertTrue(result.is_error());
    XCTAssertEqual(result.error(), std::string("test_error"));

    XCTAssertNotEqual(error, result.error());
}

- (void)test_create_error_result_copy_constructor {
    std::string error("test_error");
    yas::result<bool, std::string> result(error);

    XCTAssertFalse(result);
    XCTAssertFalse(result.is_success());
    XCTAssertTrue(result.is_error());
    XCTAssertEqual(result.error(), std::string("test_error"));

    XCTAssertEqual(error, result.error());
}

- (void)test_error_to_success_copy_assignment {
    yas::result<std::nullptr_t, std::string> result{"test_error"};

    XCTAssertFalse(result);

    yas::result<std::nullptr_t, std::string> success_result{nullptr};
    result = success_result;

    XCTAssertTrue(result);
}

- (void)test_success_to_error_copy_assignment {
    yas::result<std::nullptr_t, std::string> result{nullptr};

    XCTAssertTrue(result);

    yas::result<std::nullptr_t, std::string> error_result{"test_error"};
    result = error_result;

    XCTAssertFalse(result);
}

- (void)test_error_to_success_move_assignment {
    yas::result<std::nullptr_t, std::string> result{"test_error"};

    XCTAssertFalse(result);

    result = yas::result<std::nullptr_t, std::string>{nullptr};

    XCTAssertTrue(result);
}

- (void)test_success_to_error_move_assignment {
    yas::result<std::nullptr_t, std::string> result{nullptr};

    XCTAssertTrue(result);

    result = yas::result<std::nullptr_t, std::string>{"test_error"};

    XCTAssertFalse(result);
}

- (void)test_copy_constructor {
    yas::result<std::nullptr_t, std::string> src_result{"test_error"};
    yas::result<std::nullptr_t, std::string> result{src_result};

    XCTAssertFalse(result);
    XCTAssertEqual(result.error(), "test_error");
}

- (void)test_move_constructor {
    yas::result<std::nullptr_t, std::string> src_result{"test_error"};
    yas::result<std::nullptr_t, std::string> result{std::move(src_result)};

    XCTAssertFalse(result);
    XCTAssertEqual(result.error(), "test_error");
}

- (void)test_receive_success_result {
    bool value = true;
    bool result_flag;

    if (auto result = yas::result<bool, int>(std::move(value))) {
        result_flag = true;
    } else {
        result_flag = false;
    }

    XCTAssertTrue(result_flag);
}

- (void)test_receive_error_result {
    int error = 10;
    bool result_flag;

    if (auto result = yas::result<bool, int>(std::move(error))) {
        result_flag = true;
    } else {
        result_flag = false;
    }

    XCTAssertFalse(result_flag);
}

- (void)test_value_opt {
    bool value = true;

    auto result = yas::result<bool, int>(std::move(value));
    auto value_opt = result.value_opt();

    XCTAssertTrue(value_opt);
    XCTAssertEqual(*value_opt, true);

    auto error_opt = result.error_opt();
    XCTAssertFalse(error_opt);
}

- (void)test_error_opt {
    int error = 20;

    auto result = yas::result<bool, int>(std::move(error));
    auto error_opt = result.error_opt();

    XCTAssertTrue(error_opt);
    XCTAssertEqual(*error_opt, 20);

    auto value_opt = result.value_opt();

    XCTAssertFalse(value_opt);
}

- (void)test_move_value {
    yas::result<std::string, int> result1{std::string{"test_string"}};

    auto moved_value1 = std::move(result1.value());

    XCTAssertEqual(moved_value1, "test_string");
    XCTAssertEqual(result1.value().size(), 0);
}

- (void)test_move_error {
    yas::result<int, std::string> result1{std::string{"test_string"}};

    auto moved_value1 = std::move(result1.error());

    XCTAssertEqual(moved_value1, "test_string");
    XCTAssertEqual(result1.error().size(), 0);
}

- (void)test_where {
    bool bool_true_value = true;
    bool bool_false_value = false;
    int int_true_value = 1;
    int int_false_value = 0;

    XCTAssertTrue(where(bool_true_value));
    XCTAssertFalse(where(bool_false_value));
    XCTAssertTrue(where(bool_true_value, int_true_value));
    XCTAssertFalse(where(bool_true_value, int_false_value));
    XCTAssertFalse(where(bool_false_value, int_true_value));
    XCTAssertFalse(where(bool_false_value, int_false_value));
}

- (void)test_where_result_type {
    bool bool_value = true;
    int int_value = 1;

    auto result = where(bool_value, int_value);
    XCTAssertTrue(typeid(std::get<0>(result.value())) == typeid(bool));
    XCTAssertTrue(typeid(std::get<1>(result.value())) == typeid(int));
}

- (void)test_where_many_parameters {
    XCTAssertTrue(where(true, true, true, true, true));
    XCTAssertFalse(where(true, true, false, true, true));
    XCTAssertFalse(where(false, true, true, true, true));
    XCTAssertFalse(where(true, true, true, true, false));
}

@end
