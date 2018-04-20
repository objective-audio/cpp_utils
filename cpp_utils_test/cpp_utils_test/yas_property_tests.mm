//
//  yas_property_tests.m
//

#import <XCTest/XCTest.h>
#import "yas_property.h"

using namespace yas;

enum class test_key {
    property1,
    property2,
};

struct test_class {
    using property_t = yas::property<test_key, int>;

    property_t property1;
    property_t property2;

    property_t::subject_t properties_subject;
    property_t::observer_t dispatcher;

    test_class()
        : property1({.key = test_key::property1, .value = 1}),
          property2({.key = test_key::property2, .value = 2}),
          dispatcher(yas::make_subject_dispatcher(properties_subject, {&property1.subject(), &property2.subject()})) {
    }
};

@interface yas_property_tests : XCTestCase

@end

@implementation yas_property_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_create_property {
    int key = 1;
    float value1 = 1.5;

    yas::property<int, float> float_property({.value = value1, .key = key});

    XCTAssertEqual(key, float_property.key());
    XCTAssertEqual(float_property.value(), value1);

    float value2 = 3.2;

    float_property.set_value(value2);

    XCTAssertEqual(float_property.value(), value2);
    XCTAssertNotEqual(float_property.value(), value1);
}

- (void)test_create_property_with_validator {
    bool called = false;

    yas::property<int, float> property{{.value = 1.0f, .validator = [&called](auto const &value) {
                                            called = true;
                                            return true;
                                        }}};

    XCTAssertTrue(property.validator());

    property.set_value(2.0f);

    XCTAssertTrue(called);
}

- (void)test_create_property_by_copy_constructor {
    property<int, float>::args args{.key = 1, .value = 2.0f};
    property<int, float> property{args};

    XCTAssertEqual(property.key(), 1);
    XCTAssertEqual(property.value(), 2.0f);
}

- (void)test_make_property_with_key {
    int key = 1;
    float value = 2.0f;

    auto property = make_property(key, value);

    XCTAssertEqual(property.key(), 1);
    XCTAssertEqual(property.value(), 2.0f);

    XCTAssertTrue(typeid(property.key()) == typeid(int));
    XCTAssertTrue(typeid(property.value()) == typeid(float));
}

- (void)test_change_value {
    yas::property<int, int> property({.value = 2, .key = 1});

    XCTAssertEqual(property.value(), 2);

    property.set_value(3);

    XCTAssertNotEqual(property.value(), 2);
    XCTAssertEqual(property.value(), 3);
}

- (void)test_observe_value {
    yas::property<bool, int> property({.value = false, .key = 1});
    decltype(property)::observer_t observer;

    bool will_change_called = false;

    observer.add_handler(property.subject(), yas::property_method::will_change,
                         [self, &will_change_called](auto const &context) {
                             XCTAssertEqual(context.key, yas::property_method::will_change);
                             XCTAssertEqual(context.value.property.key(), 1);
                             XCTAssertEqual(context.value.property.value(), false);
                             will_change_called = true;
                         });

    bool did_change_called = false;

    observer.add_handler(property.subject(), yas::property_method::did_change,
                         [self, &did_change_called](auto const &context) {
                             XCTAssertEqual(context.key, yas::property_method::did_change);
                             XCTAssertEqual(context.value.property.key(), 1);
                             XCTAssertEqual(context.value.property.value(), true);
                             did_change_called = true;
                         });

    int wildcard_called_count = 0;

    observer.add_wild_card_handler(property.subject(), [self, &wildcard_called_count](auto const &context) {
        if (context.key == yas::property_method::will_change) {
            XCTAssertEqual(context.value.property.key(), 1);
            XCTAssertEqual(context.value.property.value(), false);
        } else if (context.key == yas::property_method::did_change) {
            XCTAssertEqual(context.value.property.key(), 1);
            XCTAssertEqual(context.value.property.value(), true);
        }
        ++wildcard_called_count;
    });

    property.set_value(true);

    XCTAssertTrue(will_change_called);
    XCTAssertTrue(did_change_called);
    XCTAssertEqual(wildcard_called_count, 2);
}

- (void)test_dispatcher {
    test_class test_object;
    test_class::property_t::observer_t observer;

    int receive_value1 = 0;
    int receive_value2 = 0;

    observer.add_wild_card_handler(test_object.properties_subject,
                                   [&receive_value1, &receive_value2](auto const &context) {
                                       if (context.key == yas::property_method::did_change) {
                                           switch (context.value.property.key()) {
                                               case test_key::property1:
                                                   receive_value1 = context.value.property.value();
                                                   break;
                                               case test_key::property2:
                                                   receive_value2 = context.value.property.value();
                                                   break;
                                           }
                                       }
                                   });

    test_object.property1.set_value(11);

    XCTAssertEqual(receive_value1, 11);
    XCTAssertEqual(receive_value2, 0);

    test_object.property2.set_value(12);

    XCTAssertEqual(receive_value1, 11);
    XCTAssertEqual(receive_value2, 12);
}

- (void)test_recursive_guard {
    test_class test_object;
    test_class::property_t::observer_t observer;

    observer.add_handler(test_object.properties_subject, yas::property_method::did_change,
                         [&test_object](auto const &context) {
                             switch (context.value.property.key()) {
                                 case test_key::property1:
                                     test_object.property2.set_value(context.value.property.value());
                                     break;
                                 case test_key::property2:
                                     test_object.property1.set_value(context.value.property.value());
                                     break;
                                 default:
                                     break;
                             }
                         });

    test_object.property1.set_value(10);

    XCTAssertEqual(test_object.property1.value(), 10);
    XCTAssertEqual(test_object.property2.value(), 10);

    test_object.property2.set_value(20);

    XCTAssertEqual(test_object.property1.value(), 20);
    XCTAssertEqual(test_object.property2.value(), 20);
}

- (void)test_equal {
    yas::property<int, float> property1;
    yas::property<int, float> property2;

    XCTAssertTrue(property1 == property1);
    XCTAssertFalse(property1 == property2);
}

- (void)test_not_equal {
    yas::property<int, float> property1;
    yas::property<int, float> property2;

    XCTAssertFalse(property1 != property1);
    XCTAssertTrue(property1 != property2);
}

- (void)test_equal_to_value_true {
    float value = 3.0f;

    yas::property<int, float> property1{{.key = 1, .value = value}};
    yas::property<int, float> property2{{.key = 2, .value = value}};

    XCTAssertTrue(property1 == value);
    XCTAssertTrue(value == property1);
}

- (void)test_equal_to_value_false {
    float value1 = 3.0f;
    float value2 = 5.0f;

    yas::property<int, float> property1{{.key = 1, .value = value1}};
    yas::property<int, float> property2{{.key = 2, .value = value2}};

    XCTAssertFalse(property1 == value2);
    XCTAssertFalse(value1 == property2);
}

- (void)test_not_equal_to_value_true {
    float value1 = 3.0f;
    float value2 = 5.0f;

    yas::property<int, float> property1{{.key = 1, .value = value1}};
    yas::property<int, float> property2{{.key = 2, .value = value2}};

    XCTAssertTrue(property1 != value2);
    XCTAssertTrue(value1 != property2);
}

- (void)test_not_equal_to_value_false {
    float value = 3.0f;

    yas::property<int, float> property1{{.key = 1, .value = value}};
    yas::property<int, float> property2{{.key = 2, .value = value}};

    XCTAssertFalse(property1 != value);
    XCTAssertFalse(value != property1);
}

- (void)test_change_context {
    yas::property<int, int> property{{.value = 1}};

    bool will_called = false;
    bool did_called = false;

    auto will_observer =
        property.subject().make_value_observer(property_method::will_change, [self, &will_called](auto const &value) {
            XCTAssertEqual(value.old_value, 1);
            XCTAssertEqual(value.new_value, 2);
            XCTAssertEqual(value.property.value(), 1);
            will_called = true;
        });

    auto did_observer =
        property.subject().make_value_observer(property_method::did_change, [self, &did_called](auto const &value) {
            XCTAssertEqual(value.old_value, 1);
            XCTAssertEqual(value.new_value, 2);
            XCTAssertEqual(value.property.value(), 2);
            did_called = true;
        });

    property.set_value(2);

    XCTAssertTrue(will_called);
    XCTAssertTrue(did_called);
}

- (void)test_set_same_value {
    yas::property<int, std::shared_ptr<int>> property({.value = nullptr});

    bool called = false;
    std::shared_ptr<int> called_value = nullptr;

    auto observer = property.subject().make_value_observer(yas::property_method::did_change,
                                                           [&called_value, &called](auto const &value) mutable {
                                                               called_value = value.property.value();
                                                               called = true;
                                                           });

    property.set_value(nullptr);

    XCTAssertFalse(called);

    auto value10 = std::make_shared<int>(10);

    property.set_value(value10);

    XCTAssertTrue(called);
    XCTAssertEqual(*called_value, 10);

    called = false;
    called_value = nullptr;

    property.set_value(value10);

    XCTAssertFalse(called);
}

- (void)test_set_same_string_value {
    yas::property<int, std::string> property;

    bool called = false;
    std::string called_value;

    auto observer = property.subject().make_value_observer(yas::property_method::did_change,
                                                           [&called_value, &called](auto const &value) mutable {
                                                               called_value = value.property.value();
                                                               called = true;
                                                           });

    property.set_value(std::string{});

    XCTAssertFalse(called);

    std::string value10 = "10";

    property.set_value(value10);

    XCTAssertTrue(called);
    XCTAssertEqual(called_value, "10");

    called = false;
    called_value = std::string{};

    property.set_value(value10);

    XCTAssertFalse(called);
}

- (void)test_set_validator {
    yas::property<int, std::string> property;

    XCTAssertFalse(property.validator());

    property.set_validator([](auto const &value) { return true; });

    XCTAssertTrue(property.validator());
}

- (void)test_validation_set_value {
    yas::property<int, std::string> property;

    property.set_validator([](auto const &value) { return value != "no"; });

    XCTAssertNoThrow(property.set_value("yes"));
    XCTAssertNoThrow(property.set_value(""));
    XCTAssertThrows(property.set_value("no"));
}

- (void)test_validation_construct {
    auto create_property_success = []() {
        yas::property<int, std::string> property{{.value = "", .validator = [](auto const &) { return true; }}};
    };

    XCTAssertNoThrow(create_property_success());

    auto create_property_failed = []() {
        yas::property<int, std::string> property{{.value = "", .validator = [](auto const &) { return false; }}};
    };

    XCTAssertThrows(create_property_failed());
}

- (void)test_set_limiter {
    yas::property<int, std::string> property;

    XCTAssertFalse(property.limiter());

    property.set_limiter([](std::string const &value) { return value; });

    XCTAssertTrue(property.limiter());
}

- (void)test_set_limiter_and_limit_value {
    yas::property<int, std::string> property{{.value = "test_value"}};

    XCTAssertEqual(property.value(), "test_value");

    property.set_limiter([](std::string const &value) { return ""; });

    XCTAssertEqual(property.value(), "");
}

- (void)test_limitation_set_value {
    yas::property<int, int> property{{.value = 10, .limiter = [](int const &value) {
                                          if (value < 0) {
                                              return 0;
                                          }
                                          return value;
                                      }}};

    property.set_value(1);
    XCTAssertEqual(property.value(), 1);

    property.set_value(0);
    XCTAssertEqual(property.value(), 0);

    property.set_value(-1);
    XCTAssertEqual(property.value(), 0);
}

- (void)test_property_method_to_string {
    XCTAssertEqual(yas::to_string(yas::property_method::will_change), "will_change");
    XCTAssertEqual(yas::to_string(yas::property_method::did_change), "did_change");
}

- (void)test_begin_flow {
    property<std::nullptr_t, int> property{{.value = 10}};

    int received = -1;

    auto flow = property.begin_flow().perform([&received](int const &value) { received = value; }).end();

    flow.sync();

    XCTAssertEqual(received, 10);

    property.set_value(20);

    XCTAssertEqual(received, 20);
}

- (void)test_receive {
    property<std::nullptr_t, int> property{{.value = 100}};

    flow::sender<int> sender;
    auto flow = sender.begin_flow().receive(property.receivable()).end();

    sender.send_value(200);

    XCTAssertEqual(property.value(), 200);
}

@end
