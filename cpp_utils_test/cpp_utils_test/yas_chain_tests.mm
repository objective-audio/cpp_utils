//
//  yas_chain_tests.mm
//

#import <XCTest/XCTest.h>
#import <string>
#import "yas_chain.h"

@interface yas_chain_tests : XCTestCase

@end

@implementation yas_chain_tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_chain_full_int {
    int count = 0;

    yas::chain(1, {[self, &count](auto context) {
                       XCTAssertEqual(count, 0);

                       context.set(2);
                       ++count;
                       context.next();
                   },
                   [self, &count](auto context) {
                       XCTAssertEqual(count, 1);
                       XCTAssertEqual(context.get(), 2);

                       ++count;
                       context.next();
                   }});

    XCTAssertEqual(count, 2);
}

- (void)test_chain_stop {
    int count = 0;

    yas::chain({[self, &count](auto context) {
                    XCTAssertEqual(count, 0);
                    count++;
                    context.stop();
                },
                [self, &count](auto context) {
                    XCTAssertEqual(count, 1);
                    count++;
                    context.next();
                }});

    XCTAssertEqual(count, 1);
}

- (void)test_chain_async {
    int count = 0;

    XCTestExpectation *exp = [self expectationWithDescription:@"exp"];

    auto func = [self, &count, exp](auto context) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), [self, &count, context, exp]() {
            dispatch_async(dispatch_get_main_queue(), [self, &count, context, exp]() mutable {
                count++;

                context.next();

                if (count == 2) {
                    [exp fulfill];
                }
            });
        });
    };

    yas::chain({func, func});

    [self waitForExpectationsWithTimeout:1.0 handler:nil];

    XCTAssertEqual(count, 2);
}

@end
