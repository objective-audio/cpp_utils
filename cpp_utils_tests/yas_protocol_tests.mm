//
//  yas_protocol_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/yas_base.h>
#import <cpp_utils/yas_protocol.h>

using namespace yas;

namespace yas {
namespace test {
    class required_protocol : public protocol {
       public:
        struct impl : public protocol::impl {
            virtual bool required_function() = 0;
        };

        explicit required_protocol(std::shared_ptr<impl> impl) : protocol(std::move(impl)) {
        }

        bool required_function() {
            return impl_ptr<impl>()->required_function();
        }
    };

    class optional_protocol : public protocol {
       public:
        struct impl : public protocol::impl {
            virtual bool optional_function() {
                return false;
            };
        };

        explicit optional_protocol(std::shared_ptr<impl> impl) : protocol(std::move(impl)) {
        }

        bool optional_function() {
            return impl_ptr<impl>()->optional_function();
        }
    };

    class required_object : public base {
        struct impl : public base::impl, public required_protocol::impl, public optional_protocol::impl {
            bool required_function() override {
                return true;
            }
        };

       public:
        required_object() : base(std::make_shared<impl>()) {
        }

        required_protocol required() {
            return required_protocol{impl_ptr<required_protocol::impl>()};
        }

        optional_protocol optional() {
            return optional_protocol{impl_ptr<optional_protocol::impl>()};
        }

        bool required_function() {
            return impl_ptr<required_protocol::impl>()->required_function();
        }

        bool optional_function() {
            return impl_ptr<optional_protocol::impl>()->optional_function();
        }
    };

    class optional_object : public base {
        struct impl : public base::impl, public required_protocol::impl, public optional_protocol::impl {
            bool required_function() override {
                return false;
            }

            bool optional_function() override {
                return true;
            }
        };

       public:
        optional_object() : base(std::make_shared<impl>()) {
        }

        required_protocol required() {
            return required_protocol{impl_ptr<required_protocol::impl>()};
        }

        optional_protocol optional() {
            return optional_protocol{impl_ptr<optional_protocol::impl>()};
        }

        bool required_function() {
            return impl_ptr<required_protocol::impl>()->required_function();
        }

        bool optional_function() {
            return impl_ptr<optional_protocol::impl>()->optional_function();
        }
    };
}
}

@interface yas_protocol_tests : XCTestCase

@end

@implementation yas_protocol_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_required_protocol {
    test::required_object req_obj;

    XCTAssertTrue(req_obj.required_function());
    XCTAssertFalse(req_obj.optional_function());

    auto required = req_obj.required();

    XCTAssertTrue(required.required_function());

    auto optional = req_obj.optional();

    XCTAssertFalse(optional.optional_function());
}

- (void)test_optional_protocol {
    test::optional_object opt_obj;

    XCTAssertFalse(opt_obj.required_function());
    XCTAssertTrue(opt_obj.optional_function());

    auto required = opt_obj.required();

    XCTAssertFalse(required.required_function());

    auto optional = opt_obj.optional();

    XCTAssertTrue(optional.optional_function());
}

- (void)test_to_weak {
    std::function<bool(void)> handler = nullptr;

    {
        test::required_object req_obj;
        auto required = req_obj.required();

        handler = [weak = to_weak(required)]() { return weak.operator bool(); };

        XCTAssertTrue(handler());
    }

    XCTAssertFalse(handler());
}

@end
