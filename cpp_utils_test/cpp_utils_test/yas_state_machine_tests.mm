//
//  yas_state_machine_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_state_machine.h"
#import <vector>
#import <string>

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
    state_machine<std::string> machine;

    std::string const state_name_a = "state_a";
    std::string const state_name_b = "state_b";

    machine.register_state(state_name_a, [](auto const &) {});
    machine.register_state(state_name_b, [](auto const &) {});

    machine.change_state(state_name_a);

    XCTAssertEqual(machine.current_state(), state_name_a);

    machine.change_state(state_name_b);

    XCTAssertEqual(machine.current_state(), state_name_b);
}

- (void)test_make_state_machine {
    std::string const state_name_a = "state_a";
    std::string const state_name_b = "state_b";

    state_machine<std::string>::handlers_t handlers{{state_name_a, [](auto const &) {}},
                                                    {state_name_b, [](auto const &) {}}};

    auto machine = make_state_machine(state_name_a, {std::move(handlers)});

    XCTAssertEqual(machine.current_state(), state_name_a);

    machine.change_state(state_name_b);

    XCTAssertEqual(machine.current_state(), state_name_b);
}

- (void)test_change_state_string_key {
    state_machine<std::string> machine;

    std::string const state_name_a = "state_a";
    std::string const state_name_b = "state_b";

    std::vector<std::string> called_state_names;

    machine.register_state(state_name_a, [&called_state_names](state_machine<std::string>::changer const &changer) {
        called_state_names.push_back(changer.current());
    });

    machine.register_state(state_name_b, [&called_state_names](state_machine<std::string>::changer const &changer) {
        called_state_names.push_back(changer.current());
    });

    machine.change_state(state_name_a);

    XCTAssertEqual(called_state_names.size(), 1);

    machine.change_state(state_name_b);

    XCTAssertEqual(called_state_names.size(), 2);

    XCTAssertEqual(called_state_names.at(0), state_name_a);
    XCTAssertEqual(called_state_names.at(1), state_name_b);
}

- (void)test_change_state_enum_key {
    enum class test_state {
        a,
        b,
    };

    state_machine<test_state> machine;

    std::vector<test_state> called_state_names;

    machine.register_state(test_state::a, [&called_state_names](state_machine<test_state>::changer const &changer) {
        called_state_names.push_back(changer.current());
    });

    machine.register_state(test_state::b, [&called_state_names](state_machine<test_state>::changer const &changer) {
        called_state_names.push_back(changer.current());
    });

    machine.change_state(test_state::a);

    XCTAssertEqual(called_state_names.size(), 1);

    machine.change_state(test_state::b);

    XCTAssertEqual(called_state_names.size(), 2);

    XCTAssertEqual(called_state_names.at(0), test_state::a);
    XCTAssertEqual(called_state_names.at(1), test_state::b);
}

- (void)test_change_state_by_changer {
    enum class test_state {
        a,
        b,
    };

    state_machine<test_state> machine;

    std::vector<test_state> called_state_names;

    machine.register_state(test_state::a, [&called_state_names](state_machine<test_state>::changer const &changer) {
        called_state_names.push_back(changer.current());
        changer.change(test_state::b);
    });

    machine.register_state(test_state::b, [&called_state_names](state_machine<test_state>::changer const &changer) {
        called_state_names.push_back(changer.current());
    });

    machine.change_state(test_state::a);

    XCTAssertEqual(called_state_names.size(), 2);

    XCTAssertEqual(called_state_names.at(0), test_state::a);
    XCTAssertEqual(called_state_names.at(1), test_state::b);
}

@end
