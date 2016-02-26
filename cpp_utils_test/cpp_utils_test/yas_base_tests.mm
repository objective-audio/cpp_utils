//
//  yas_base_tests.mm
//

#import <XCTest/XCTest.h>
#import "yas_base.h"

namespace yas {
namespace test {
    class derived1 : public base {
        using super_class = base;

       public:
        class impl : public base::impl {
           public:
            float value;

            bool is_equal(std::shared_ptr<base::impl> const &rhs) const override {
                if (auto casted_rhs = std::dynamic_pointer_cast<impl>(rhs)) {
                    return value == casted_rhs->value;
                } else {
                    return false;
                }
            }
        };

        derived1() : super_class(std::make_shared<impl>()) {
        }

        derived1(std::nullptr_t) : super_class(nullptr) {
        }

        void set_value(float val) {
            if (impl_ptr()) {
                impl_ptr<impl>()->value = val;
            }
        }

        float value() const {
            if (impl_ptr()) {
                return impl_ptr<impl>()->value;
            }
            return 0.0f;
        }

        template <typename T>
        T object_from_impl() {
            return impl_ptr()->cast<T>();
        }
    };

    class derived2 : public base {
        using super_class = base;

       public:
        class impl : public base::impl {
           public:
            float value;
        };

        derived2() : super_class(std::make_shared<impl>()) {
        }

        derived2(std::nullptr_t) : super_class(nullptr) {
        }

        void set_value(float val) {
            if (impl_ptr()) {
                impl_ptr<impl>()->value = val;
            }
        }
    };
}
}

@interface yas_base_tests : XCTestCase

@end

@implementation yas_base_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_lock_values {
    yas::test::derived1 derived_1;
    yas::test::derived1 derived_2;

    derived_1.set_value(1.0f);
    derived_2.set_value(2.0f);

    auto weak_1 = yas::to_weak(derived_1);
    auto weak_2 = yas::to_weak(derived_2);

    std::map<int, decltype(weak_1)> map;
    map.insert(std::make_pair(1, weak_1));
    map.insert(std::make_pair(2, weak_2));

    auto locked_map = yas::lock_values(map);

    for (auto &pair : locked_map) {
        switch (pair.first) {
            case 1:
                XCTAssertEqual(pair.second.value(), 1.0f);
                break;
            case 2:
                XCTAssertEqual(pair.second.value(), 2.0f);
                break;
            default:
                break;
        }
    }
}

- (void)test_cast_success {
    yas::test::derived1 derived;
    yas::base base = derived;

    auto casted = base.cast<yas::test::derived1>();

    XCTAssertTrue(!!casted);
}

- (void)test_cast_failed {
    yas::base base{nullptr};
    base.set_impl_ptr(std::make_shared<yas::base::impl>());

    auto casted = base.cast<yas::test::derived1>();

    XCTAssertFalse(!!casted);
}

- (void)test_make_object_from_impl_success {
    yas::test::derived1 derived;

    auto derived_from_impl = derived.object_from_impl<yas::test::derived1>();

    XCTAssertTrue(!!derived_from_impl);
}

- (void)test_make_object_from_impl_failed {
    yas::test::derived1 derived;

    auto derived2_from_impl = derived.object_from_impl<yas::test::derived2>();

    XCTAssertFalse(!!derived2_from_impl);
}

- (void)test_equal_to_nullptr {
    yas::base base{nullptr};

    XCTAssertTrue(base == nullptr);

    base.set_impl_ptr(std::make_shared<yas::base::impl>());

    XCTAssertFalse(base == nullptr);
}

- (void)test_not_equal_to_nullptr {
    yas::base base{nullptr};

    XCTAssertFalse(base != nullptr);

    base.set_impl_ptr(std::make_shared<yas::base::impl>());

    XCTAssertTrue(base != nullptr);
}

- (void)test_derived_equal_to_nullptr {
    yas::test::derived1 derived{nullptr};

    XCTAssertTrue(derived == nullptr);

    derived.set_impl_ptr(std::make_shared<yas::test::derived1::impl>());

    XCTAssertFalse(derived == nullptr);
}

- (void)test_expired {
    yas::base base{nullptr};

    XCTAssertTrue(base.expired());

    base.set_impl_ptr(std::make_shared<yas::base::impl>());

    XCTAssertFalse(base.expired());

    base.set_impl_ptr(nullptr);

    XCTAssertTrue(base.expired());
}

- (void)test_compare {
    yas::base base1{nullptr};
    yas::base base2{nullptr};

    XCTAssertFalse(base1 < base2);
    XCTAssertFalse(base2 < base1);

    auto impl1 = std::make_shared<yas::base::impl>();
    auto impl2 = std::make_shared<yas::base::impl>();

    base1.set_impl_ptr(impl1);
    base2.set_impl_ptr(impl2);

    bool compare_impl = impl1 < impl2;
    bool compare_base = base1 < base2;

    XCTAssertEqual(compare_impl, compare_base);
}

- (void)test_is_kind_of {
    yas::base base{nullptr};
    base.set_impl_ptr(std::make_shared<yas::base::impl>());

    yas::test::derived1 derived{nullptr};
    derived.set_impl_ptr(std::make_shared<yas::test::derived1::impl>());

    XCTAssertTrue(derived.is_kind_of<yas::base>());
    XCTAssertTrue(derived.is_kind_of<yas::test::derived1>());

    XCTAssertFalse(derived.is_kind_of<yas::test::derived2>());
    XCTAssertFalse(base.is_kind_of<yas::test::derived1>());
}

- (void)test_weak_identifier {
    yas::base base{nullptr};
    base.set_impl_ptr(std::make_shared<yas::base::impl>());

    yas::weak<yas::base> weak_base{base};

    auto identifier = base.identifier();

    XCTAssertEqual(weak_base.identifier(), identifier);

    base = nullptr;

    XCTAssertNotEqual(weak_base.identifier(), identifier);
    XCTAssertEqual(weak_base.identifier(), 0);
}

- (void)test_move {
    yas::test::derived1 obj1{};
    yas::test::derived1 obj2{};

    obj1.set_value(10.0f);
    obj2.set_value(20.0f);

    XCTAssertEqual(obj1.value(), 10.0f);
    XCTAssertEqual(obj2.value(), 20.0f);

    obj1 = std::move(obj2);

    XCTAssertTrue(obj1);
    XCTAssertFalse(obj2);
    XCTAssertEqual(obj1.value(), 20.0f);
    XCTAssertEqual(obj2.value(), 0.0f);
}

- (void)test_is_equal_same_class {
    yas::test::derived1 obj1{};
    yas::test::derived1 obj2{};

    obj1.set_value(1.0);
    obj2.set_value(1.0);

    XCTAssertTrue(obj1 == obj1);
    XCTAssertFalse(obj1 != obj1);
    XCTAssertTrue(obj1 == obj2);
    XCTAssertFalse(obj1 != obj2);

    obj2.set_value(2.0);

    XCTAssertFalse(obj1 == obj2);
    XCTAssertTrue(obj1 != obj2);
}

- (void)test_is_equal_different_class {
    yas::test::derived1 obj1{};
    yas::test::derived2 obj2{};

    obj1.set_value(1.0);
    obj2.set_value(1.0);

    XCTAssertFalse(obj1 == obj2);
    XCTAssertTrue(obj1 != obj2);
}

- (void)test_is_equal_weak {
    yas::test::derived1 obj1{};
    yas::test::derived1 obj2{};

    obj1.set_value(3.5);
    obj2.set_value(3.5);

    auto wobj1 = yas::to_weak(obj1);
    auto wobj2 = yas::to_weak(obj2);

    XCTAssertTrue(wobj1 == wobj1);
    XCTAssertFalse(wobj1 != wobj1);
    XCTAssertTrue(wobj1 == wobj2);
    XCTAssertFalse(wobj1 != wobj2);

    obj2.set_value(-1.0);
    
    XCTAssertFalse(wobj1 == wobj2);
    XCTAssertTrue(wobj1 != wobj2);
}

@end
