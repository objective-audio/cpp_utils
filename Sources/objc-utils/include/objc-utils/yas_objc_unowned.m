//
//  yas_objc_weak.m
//

#import "yas_objc_unowned.h"
#import "yas_objc_macros.h"

// clang-format off
@interface YASUnownedObject<T> ()
@property(nonatomic, yas_weak_for_property) T weakObject;
@end
// clang-format on

@implementation YASUnownedObject

- (instancetype)initWithObject:(nullable id)object {
    self = [super init];
    if (self) {
        [self setObject:object];
    }
    return self;
}

- (void)setObject:(nullable id)object {
    self.weakObject = object;
}

- (nullable id)object {
    return self.weakObject;
}

- (nullable id)retainedObject {
    return yas_retain(self.weakObject);
}

- (nullable id)autoreleasedObject {
    return yas_retain_and_autorelease(self.weakObject);
}

@end
