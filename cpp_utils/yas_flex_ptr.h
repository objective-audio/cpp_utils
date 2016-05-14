//
//  yas_flex_ptr.h
//

#pragma once

#include <cstddef>
#include <cstdint>

namespace yas {
class flex_ptr {
   public:
    union {
        void *v;
        float *f32;
        double *f64;
        int32_t *i32;
        uint32_t *u32;
        int16_t *i16;
        uint16_t *u16;
        int8_t *i8;
        uint8_t *u8;
    };

    flex_ptr(std::nullptr_t n = nullptr);
    template <typename T>
    flex_ptr(T const *const p);
};
}
