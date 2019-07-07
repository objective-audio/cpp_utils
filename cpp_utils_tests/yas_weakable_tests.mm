//
//  yas_weakable_tests.mm
//

#import <XCTest/XCTest.h>
#import <cpp_utils/yas_weakable.h>

using namespace yas;

@interface yas_weakable_tests : XCTestCase

@end

@implementation yas_weakable_tests

- (void)setUp {
}

- (void)tearDown {
}

- (void)test_weakable {
    struct test_class : weakable<test_class> {
        struct impl : weakable_impl {
            int value;

            impl(int const value) : value(value) {
            }
        };

        test_class(int const value) : _impl(std::make_shared<impl>(value)) {
        }

        test_class(std::shared_ptr<impl> &&impl) : _impl(std::move(impl)) {
        }

        std::shared_ptr<weakable_impl> weakable_impl_ptr() const override {
            return this->_impl;
        }

        int value() {
            return this->_impl->value;
        }

        void reset_impl() {
            this->_impl.reset();
        }

       private:
        std::shared_ptr<impl> _impl;
    };

    {
        test_class source{1};

        auto weak = to_weak(source);

        auto locked_opt = weak.lock();

        XCTAssertTrue(locked_opt);

        XCTAssertEqual(locked_opt->value(), 1);
    }

    {
        test_class source{2};

        auto weak = to_weak(source);

        source.reset_impl();

        auto locked_opt = weak.lock();

        XCTAssertFalse(locked_opt);
    }
}

@end
