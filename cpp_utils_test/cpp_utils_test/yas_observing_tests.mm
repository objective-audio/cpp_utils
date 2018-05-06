//
//  yas_observing_tests.m
//

#import <XCTest/XCTest.h>
#import "yas_observing.h"

using namespace yas;

@interface yas_observing_tests : XCTestCase

@end

@implementation yas_observing_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_single {
    int sender = 100;

    std::string const key("key");
    std::string const key2("key2");

    bool called = false;
    subject<std::string, int> subject;

    {
        observer<std::string, int> observer;

        observer.add_handler(subject, key, [&called](auto const &context) {
            if (context.key == "key" && context.value == 100) {
                called = true;
            }
        });

        subject.notify(key, sender);

        XCTAssertTrue(called);

        called = false;

        subject.notify(key2, sender);

        XCTAssertFalse(called);

        observer.remove_handler(subject, key);
        subject.notify(key, sender);

        XCTAssertFalse(called);

        observer.add_handler(subject, key, [&called](auto const &context) {
            if (context.key == "key" && context.value == 100) {
                called = true;
            }
        });
    }

    subject.notify(key, sender);

    XCTAssertFalse(called);
}

- (void)test_multi_keys {
    int sender = 100;

    std::string const key1("key1");
    std::string const key2("key2");
    std::string const key3("key3");

    subject<std::string, int> subject;
    observer<std::string, int> observer;

    bool called1 = false;
    bool called2 = false;

    observer.add_handler(subject, key1, [&called1](auto const &context) {
        if (context.key == "key1" && context.value == 100) {
            called1 = true;
        }
    });
    observer.add_handler(subject, key2, [&called2](auto const &context) {
        if (context.key == "key2" && context.value == 100) {
            called2 = true;
        }
    });

    subject.notify(key1, sender);

    XCTAssertTrue(called1);
    XCTAssertFalse(called2);

    called1 = false;
    called2 = false;

    subject.notify(key2, sender);

    XCTAssertFalse(called1);
    XCTAssertTrue(called2);

    called1 = false;
    called2 = false;

    subject.notify(key3, sender);

    XCTAssertFalse(called1);
    XCTAssertFalse(called2);
}

- (void)test_multi_observers {
    int sender = 100;

    std::string const key("key");

    subject<std::string, int> subject;
    observer<std::string, int> observer1;
    observer<std::string, int> observer2;

    bool called1 = false;
    bool called2 = false;

    observer1.add_handler(subject, key, [&called1](auto const &context) {
        if (context.key == "key" && context.value == 100) {
            called1 = true;
        }
    });
    observer2.add_handler(subject, key, [&called2](auto const &context) {
        if (context.key == "key" && context.value == 100) {
            called2 = true;
        }
    });

    subject.notify(key, sender);

    XCTAssertTrue(called1);
    XCTAssertTrue(called2);
}

- (void)test_multi_subjects {
    int sender = 100;

    std::string const key("key");

    subject<std::string, int> subject1;
    subject<std::string, int> subject2;
    observer<std::string, int> observer;

    bool called1 = false;
    bool called2 = false;

    observer.add_handler(subject1, key, [&called1](auto const &context) {
        if (context.key == "key" && context.value == 100) {
            called1 = true;
        }
    });

    observer.add_handler(subject2, key, [&called2](auto const &context) {
        if (context.key == "key" && context.value == 100) {
            called2 = true;
        }
    });

    subject1.notify(key, sender);

    XCTAssertTrue(called1);
    XCTAssertFalse(called2);

    called1 = false;
    called2 = false;

    subject2.notify(key, sender);

    XCTAssertFalse(called1);
    XCTAssertTrue(called2);
}

- (void)test_wild_card {
    subject<std::string, std::string> subject;
    observer<std::string, std::string> observer;

    std::string key00 = "30";
    std::string key10 = "10";
    std::string key20 = "20";

    std::string sender_00 = "sender_00";
    std::string sender_10 = "sender_10";
    std::string sender_20 = "sender_20";
    std::string receive_00 = "";
    std::string receive_10 = "";
    std::string receive_20 = "";

    observer.add_wild_card_handler(subject, [&receive_10, &receive_20](auto const &context) {
        if (context.key == "10") {
            receive_10 = context.value;
        } else if (context.key == "20") {
            receive_20 = context.value;
        }
    });

    subject.notify(key00, sender_00);

    XCTAssertNotEqual(receive_00, sender_00);
    XCTAssertNotEqual(receive_10, sender_10);
    XCTAssertNotEqual(receive_20, sender_20);

    subject.notify(key10, sender_10);

    XCTAssertEqual(receive_10, sender_10);
    XCTAssertNotEqual(receive_20, sender_20);

    subject.notify(key20, sender_20);

    XCTAssertEqual(receive_20, sender_20);
}

- (void)test_remove_wild_card {
    subject<std::string, std::string> subject;
    observer<std::string, std::string> observer;

    std::string key10 = "10";
    std::string key20 = "20";

    std::string sender_10 = "sender_10";
    std::string sender_20 = "sender_20";

    std::string receive_10 = "";
    std::string receive_20 = "";

    observer.add_wild_card_handler(subject, [&receive_10, &receive_20](auto const &context) {
        if (context.key == "10") {
            receive_10 = context.value;
        } else if (context.key == "20") {
            receive_20 = context.value;
        }
    });

    observer.remove_wild_card_handler(subject);

    subject.notify(key10, sender_10);

    XCTAssertNotEqual(receive_10, sender_10);
    XCTAssertNotEqual(receive_20, sender_20);

    subject.notify(key20, sender_20);

    XCTAssertNotEqual(receive_10, sender_10);
    XCTAssertNotEqual(receive_20, sender_20);
}

- (void)test_subject_dispatcher {
    static std::string const property_method1 = "p1";
    static std::string const property_method2 = "p2";

    struct test_class {
        subject<std::string, std::string> property1;
        subject<std::string, std::string> property2;

        observer<std::string, std::string> dispatcher;
        subject<std::string, std::string> properties_subject;

        test_class() : dispatcher(make_subject_dispatcher(properties_subject, {&property1, &property2})) {
        }

        ~test_class() {
        }
    };

    test_class test_object;

    std::string value1 = "";
    std::string value2 = "";

    observer<std::string, std::string> observer;
    observer.add_wild_card_handler(test_object.properties_subject, [&value1, &value2](auto const &context) {
        if (context.key == property_method1) {
            value1 = context.value;
        } else if (context.key == property_method2) {
            value2 = context.value;
        }
    });

    test_object.property1.notify(property_method1, std::string("property1"));
    test_object.property2.notify(property_method2, std::string("property2"));

    XCTAssertEqual(value1, "property1");
    XCTAssertEqual(value2, "property2");
}

- (void)test_clear_observer {
    int sender = 100;

    std::string const key("key");

    bool called = false;

    subject<std::string, int> subject;
    observer<std::string, int> observer;

    observer.add_handler(subject, key, [&called](auto const &context) {
        if (context.key == "key" && context.value == 100) {
            called = true;
        }
    });

    subject.notify(key, sender);

    XCTAssertTrue(called);

    called = false;

    observer.clear();

    subject.notify(key, sender);

    XCTAssertFalse(called);
}

- (void)test_remove_observer {
    int sender = 100;

    std::string const key("key");

    bool called = false;

    subject<std::string, int> subject;

    {
        observer<std::string, int> observer;

        observer.add_handler(subject, key, [&called](auto const &context) {
            if (context.key == "key" && context.value == 100) {
                called = true;
            }
        });

        subject.notify(key, sender);

        XCTAssertTrue(called);

        called = false;
    }

    subject.notify(key, sender);

    XCTAssertFalse(called);
}

- (void)test_remove_subject {
    int sender = 100;

    std::string const key("key");

    bool called = false;

    observer<std::string, int> observer;

    {
        subject<std::string, int> subject;

        observer.add_handler(subject, key, [&called](auto const &context) {
            if (context.key == "key" && context.value == 100) {
                called = true;
            }
        });

        subject.notify(key, sender);

        XCTAssertTrue(called);
    }

    observer.clear();
}

- (void)test_make_observer {
    subject<std::string, int> subject;
    const int sender = 101;
    int receiver = 0;
    std::string key = "key";

    auto observer = subject.make_value_observer(key, [&receiver](int const &value) {
        if (value == 101) {
            receiver = sender;
        }
    });

    subject.notify(key, sender);
    XCTAssertEqual(receiver, 101);
}

- (void)test_make_wild_card_observer {
    subject<std::string, int> subject;
    int receiver = 0;
    std::string key1 = "key1";
    std::string key2 = "key2";
    std::string key3 = "key3";

    auto observer = subject.make_wild_card_observer([&receiver](auto const &context) {
        if (context.key == "key1" || context.key == "key2") {
            receiver = context.value;
        }
    });

    subject.notify(key1, 101);
    XCTAssertEqual(receiver, 101);

    receiver = 0;
    subject.notify(key2, 102);
    XCTAssertEqual(receiver, 102);

    receiver = 0;
    subject.notify(key3, 103);
    XCTAssertNotEqual(receiver, 103);
}

- (void)test_observer_hold_by_base {
    base base{nullptr};
    subject<std::string, int> subject;
    bool called = false;

    base = subject.make_value_observer("key", [&called](auto const &) { called = true; });

    subject.notify("key", 0);

    XCTAssertTrue(called);

    called = false;
    base = nullptr;

    subject.notify("key", 0);

    XCTAssertFalse(called);
}

- (void)test_subject_has_observer {
    subject<std::string, int> subject;

    XCTAssertFalse(subject.has_observer());

    if (auto observer = subject.make_value_observer("key", [](auto const &) {})) {
        XCTAssertTrue(subject.has_observer());
    } else {
        XCTAssert(0);
    }

    XCTAssertFalse(subject.has_observer());
}

- (void)test_enum_key {
    enum class test_enum { type1, type2 };

    subject<test_enum, int> subject;

    {
        bool called = false;
        int value = 0;

        auto observer = subject.make_value_observer(test_enum::type1, [&called, &value](int const &val) {
            called = true;
            value = val;
        });

        subject.notify(test_enum::type2, 1);

        XCTAssertFalse(called);
        XCTAssertEqual(value, 0);

        subject.notify(test_enum::type1, 1);

        XCTAssertTrue(called);
        XCTAssertEqual(value, 1);
    }
}

- (void)test_value_observer {
    subject<std::string, int> subject;

    int notified = -1;

    auto observer = subject.make_value_observer("test_key", [&notified](int const &value) { notified = value; });

    subject.notify("test_key", 2);

    XCTAssertEqual(notified, 2);
}

- (void)test_begin_flow_with_key {
    enum key { first, second };

    subject<key, int> subject;

    std::string received_first_value = "";
    int received_second_value = -1;

    auto flow_first = subject.begin_flow(key::first)
                          .to<std::string>([](int const value) { return std::to_string(value); })
                          .perform([&received_first_value](std::string const &value) { received_first_value = value; })
                          .end();

    auto flow_second = subject.begin_flow(key::second)
                           .perform([&received_second_value](int const &value) { received_second_value = value; })
                           .end();

    XCTAssertEqual(received_first_value, "");
    XCTAssertEqual(received_second_value, -1);

    subject.notify(key::first, 1);

    XCTAssertEqual(received_first_value, "1");
    XCTAssertEqual(received_second_value, -1);

    subject.notify(key::first, 2);

    XCTAssertEqual(received_first_value, "2");
    XCTAssertEqual(received_second_value, -1);

    subject.notify(key::second, 3);

    XCTAssertEqual(received_first_value, "2");
    XCTAssertEqual(received_second_value, 3);
}

- (void)test_begin_flow {
    using subject_t = subject<std::string, int>;
    subject_t subject;

    std::string received_key = "";
    int received_value = -1;

    auto flow = subject.begin_flow()
                    .perform([&received_key, &received_value](subject_t::flow_context_t const &context) {
                        received_key = context.key;
                        received_value = context.value;
                    })
                    .end();

    XCTAssertEqual(received_key, "");
    XCTAssertEqual(received_value, -1);

    subject.notify("key", 1);

    XCTAssertEqual(received_key, "key");
    XCTAssertEqual(received_value, 1);
}

@end
