//
//  yas_timer.mm
//

#include "yas_timer.h"
#import <Foundation/Foundation.h>
#include <optional>
#include "yas_objc_ptr.h"

using namespace yas;

struct timer::impl {
    std::optional<objc_ptr<NSTimer *>> _objc_timer;

    impl(double const time_interval, bool const repeats, std::function<void(void)> &&handler)
        : _objc_timer(objc_ptr<NSTimer *>([time_interval, repeats, handler = std::move(handler)]() {
              return [NSTimer scheduledTimerWithTimeInterval:time_interval
                                                     repeats:repeats
                                                       block:[handler = std::move(handler)](NSTimer *) {
                                                           if (handler) {
                                                               handler();
                                                           }
                                                       }];
          })) {
    }

    ~impl() {
        if (this->_objc_timer) {
            [this->_objc_timer.value().object() invalidate];
        }
    }

    void invalidate() {
        if (this->_objc_timer) {
            [this->_objc_timer.value().object() invalidate];
            this->_objc_timer = std::nullopt;
        }
    }
};

timer::timer(double const time_interval, bool const repeats, std::function<void(void)> handler)
    : _impl(std::make_unique<impl>(time_interval, repeats, std::move(handler))) {
}

void timer::invalidate() {
    this->_impl->invalidate();
}
