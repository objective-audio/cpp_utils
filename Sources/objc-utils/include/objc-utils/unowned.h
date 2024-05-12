//
//  objc_weak.h
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YASUnownedObject<T> : NSObject

- (instancetype)initWithObject:(nullable T)object;

- (void)setObject:(nullable T)object;
- (nullable T)object;
- (nullable T)retainedObject NS_RETURNS_RETAINED;
- (nullable T)autoreleasedObject;

@end

NS_ASSUME_NONNULL_END
