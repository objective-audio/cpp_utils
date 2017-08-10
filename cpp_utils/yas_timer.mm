//
//  yas_timer.mm
//

#include "yas_timer.h"
#include "yas_objc_ptr.h"
#import <Foundation/Foundation.h>

using namespace yas;

struct timer::impl : base::impl {
    objc_ptr<NSTimer *> _objc_timer;

    impl(double const time_interval, bool const repeats, std::function<void(void)> &&handler)
        : _objc_timer(make_objc_ptr<NSTimer *>([time_interval, repeats, handler = std::move(handler)]() {
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
        if (NSTimer *timer = *this->_objc_timer) {
            [timer invalidate];
        }
    }

    void invalidate() {
        if (NSTimer *timer = *this->_objc_timer) {
            [timer invalidate];
            this->_objc_timer = nullptr;
        }
    }
};

timer::timer(double const time_interval, bool const repeats, std::function<void(void)> handler)
    : base(std::make_shared<impl>(time_interval, repeats, std::move(handler))) {
}

timer::timer(std::nullptr_t) : base(nullptr) {
}

void timer::invalidate() {
    impl_ptr<impl>()->invalidate();
}
