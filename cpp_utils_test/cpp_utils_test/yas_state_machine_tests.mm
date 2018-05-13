//
//  yas_state_machine_tests.mm
//

#import <XCTest/XCTest.h>
#import <string>
#import <vector>
#import "yas_state_machine.h"

using namespace yas;

@interface yas_state_machine_tests : XCTestCase

@end

@implementation yas_state_machine_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_current_state {
    state_machine<> machine;

    std::string const state_name_a = "state_a";
    std::string const state_name_b = "state_b";

    XCTAssertEqual(machine.current_state(), "");

    machine.change(state_name_a);

    XCTAssertEqual(machine.current_state(), state_name_a);

    machine.change(state_name_b);

    XCTAssertEqual(machine.current_state(), state_name_b);
}

- (void)test_entered_by_string_key {
    state_machine<> machine;

    std::string const state_name_a = "state_a";
    std::string const state_name_b = "state_b";

    std::vector<std::string> called_state_names;

    machine.set_entered(
        state_name_a, [&called_state_names](auto const &context) { called_state_names.push_back(context.current()); });

    machine.set_entered(
        state_name_b, [&called_state_names](auto const &context) { called_state_names.push_back(context.current()); });

    machine.change(state_name_a);

    XCTAssertEqual(called_state_names.size(), 1);

    machine.change(state_name_b);

    XCTAssertEqual(called_state_names.size(), 2);

    XCTAssertEqual(called_state_names.at(0), state_name_a);
    XCTAssertEqual(called_state_names.at(1), state_name_b);
}

- (void)test_entered_by_enum_key {
    enum class test_state {
        initial,
        a,
        b,
    };

    state_machine<test_state> machine;

    std::vector<test_state> called_state_names;

    machine.set_entered(
        test_state::a, [&called_state_names](auto const &context) { called_state_names.push_back(context.current()); });

    machine.set_entered(
        test_state::b, [&called_state_names](auto const &context) { called_state_names.push_back(context.current()); });

    machine.change(test_state::a);

    XCTAssertEqual(called_state_names.size(), 1);

    machine.change(test_state::b);

    XCTAssertEqual(called_state_names.size(), 2);

    XCTAssertEqual(called_state_names.at(0), test_state::a);
    XCTAssertEqual(called_state_names.at(1), test_state::b);
}

- (void)test_change_by_context {
    enum class test_state {
        initial,
        a,
        b,
    };

    state_machine<test_state> machine;

    std::vector<test_state> called_state_names;

    machine.set_entered(test_state::a, [&called_state_names](auto const &context) {
        called_state_names.push_back(context.current());
        context.change(test_state::b);
    });

    machine.set_entered(
        test_state::b, [&called_state_names](auto const &context) { called_state_names.push_back(context.current()); });

    XCTAssertEqual(called_state_names.size(), 0);

    machine.change(test_state::a);

    XCTAssertEqual(called_state_names.size(), 2);

    XCTAssertEqual(called_state_names.at(0), test_state::a);
    XCTAssertEqual(called_state_names.at(1), test_state::b);
}

- (void)test_change_by_context_with_value {
    enum class test_state {
        initial,
        a,
        b,
    };

    state_machine<test_state> machine;

    std::vector<test_state> called_state_names;

    machine.set_entered(test_state::a, [&called_state_names](auto const &context) {
        called_state_names.push_back(context.current());
        context.change(test_state::b, int(10));
    });

    auto called_value = any::null();

    machine.set_entered(test_state::b, [&called_state_names, &called_value](auto const &context) {
        called_state_names.push_back(context.current());
        called_value = context.value;
    });

    XCTAssertEqual(called_state_names.size(), 0);

    machine.change(test_state::a);

    XCTAssertEqual(called_state_names.size(), 2);

    XCTAssertEqual(called_state_names.at(0), test_state::a);
    XCTAssertEqual(called_state_names.at(1), test_state::b);

    XCTAssertEqual(called_value.get<int>(), 10);
}

- (void)test_perform_unreturned_method {
    enum class test_state {
        a,
        b,
    };

    enum class test_method {
        a,
    };

    using test_state_machine_t = state_machine<test_state, test_method>;

    test_state_machine_t machine;

    std::vector<std::string> called_method_names;

    machine.set_unreturned(test_state::a, test_method::a,
                           [&called_method_names](auto const &) { called_method_names.push_back("state_a_method_a"); });
    machine.set_unreturned(test_state::b, test_method::a,
                           [&called_method_names](auto const &) { called_method_names.push_back("state_b_method_a"); });

    XCTAssertEqual(called_method_names.size(), 0);

    machine.perform(test_method::a);

    XCTAssertEqual(called_method_names.size(), 1);
    XCTAssertEqual(called_method_names.at(0), "state_a_method_a");

    machine.change(test_state::b);

    machine.perform(test_method::a);

    XCTAssertEqual(called_method_names.size(), 2);
    XCTAssertEqual(called_method_names.at(1), "state_b_method_a");
}

- (void)test_perform_returned_method {
    enum class test_state {
        a,
        b,
    };

    enum class test_method {
        a,
    };

    using test_state_machine_t = state_machine<test_state, test_method>;

    test_state_machine_t machine;

    machine.set_returned(test_state::a, test_method::a, [](auto const &) { return any(int(1)); });
    machine.set_returned(test_state::b, test_method::a, [](auto const &) { return any(int(2)); });

    XCTAssertEqual(machine.perform(test_method::a).get<int>(), 1);

    machine.change(test_state::b);

    XCTAssertEqual(machine.perform(test_method::a).get<int>(), 2);
}

- (void)test_change_state_at_method {
    enum class test_state {
        initial,
        a,
        b,
    };

    enum class test_method {
        a,
    };

    using test_state_machine_t = state_machine<test_state, test_method>;

    test_state_machine_t machine;

    std::vector<test_state> called_states;

    machine.set_entered(test_state::a, [&called_states](auto const &) { called_states.push_back(test_state::a); });
    machine.set_unreturned(test_state::a, test_method::a, [](auto const &context) { context.change(test_state::b); });
    machine.set_entered(test_state::b, [&called_states](auto const &) { called_states.push_back(test_state::b); });

    machine.change(test_state::a);

    XCTAssertEqual(called_states.size(), 1);
    XCTAssertEqual(called_states.at(0), test_state::a);

    machine.perform(test_method::a);

    XCTAssertEqual(called_states.size(), 2);
    XCTAssertEqual(called_states.at(1), test_state::b);
}

- (void)test_perform_returned_with_value {
    enum class test_state {
        a,
        b,
    };

    enum class test_method {
        a,
    };

    using test_state_machine_t = state_machine<test_state, test_method>;

    test_state_machine_t machine;

    machine.set_returned(test_state::a, test_method::a, [](auto const &context) {
        any const &any_value = context.value;
        auto int_value = any_value.get<int>();
        return any(int_value + 10);
    });

    machine.set_returned(test_state::b, test_method::a, [](auto const &context) {
        any const &any_value = context.value;
        auto int_value = any_value.get<int>();
        return any(int_value + 20);
    });

    XCTAssertEqual(machine.perform(test_method::a, any(int(1))).get<int>(), 11);

    machine.change(test_state::b);

    XCTAssertEqual(machine.perform(test_method::a, any(int(1))).get<int>(), 21);
}

- (void)test_perform_unreturned_with_value {
    enum class test_state {
        a,
        b,
    };

    enum class test_method {
        a,
    };

    using test_state_machine_t = state_machine<test_state, test_method>;

    test_state_machine_t machine;

    std::vector<any> values;

    machine.set_unreturned(test_state::a, test_method::a,
                           [&values](auto const &context) { values.push_back(context.value); });

    machine.set_unreturned(test_state::b, test_method::a,
                           [&values](auto const &context) { values.push_back(context.value); });

    XCTAssertTrue(machine.perform(test_method::a, any(int(1))).type() == typeid(std::nullptr_t));
    XCTAssertEqual(values.size(), 1);
    XCTAssertEqual(values.at(0).get<int>(), 1);

    machine.change(test_state::b);

    XCTAssertTrue(machine.perform(test_method::a, any(int(2))).type() == typeid(std::nullptr_t));
    XCTAssertEqual(values.size(), 2);
    XCTAssertEqual(values.at(1).get<int>(), 2);
}

- (void)test_entered_with_value {
    enum class test_state {
        initial,
        a,
    };

    state_machine<test_state> machine;

    std::vector<any> values;

    machine.set_entered(test_state::a, [&values](auto const &context) { values.push_back(context.value); });

    machine.change(test_state::a, any(int(5)));

    XCTAssertEqual(values.size(), 1);
    XCTAssertEqual(values.at(0).get<int>(), 5);
}

- (void)test_initial_state {
    enum class test_state {
        a,
        b,
    };

    state_machine<test_state> machine{test_state::b};

    XCTAssertEqual(machine.current_state(), test_state::b);
}

- (void)test_change_same_state {
    enum class test_state {
        a,
        b,
    };

    state_machine<test_state> machine{test_state::a};

    std::vector<test_state> called_states;

    machine.set_entered(test_state::a,
                        [&called_states](auto const &context) { called_states.push_back(test_state::a); });
    machine.set_entered(test_state::b,
                        [&called_states](auto const &context) { called_states.push_back(test_state::b); });

    machine.change(test_state::b);

    XCTAssertEqual(called_states.size(), 1);
    XCTAssertEqual(called_states.at(0), test_state::b);

    machine.change(test_state::b);

    XCTAssertEqual(called_states.size(), 1);
}

@end
