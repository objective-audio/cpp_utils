//
//  macros.h
//

// clang-format off

#pragma once

#import <TargetConditionals.h>

#if !__has_feature(objc_arc)
    #define yas_autorelease(__v) [__v autorelease]
    #define yas_retain(__v) [__v retain]
    #define yas_retain_or_ignore(__v) [__v retain]
    #define yas_release(__v) [__v release]
    #define yas_retain_and_autorelease(__v) [[__v retain] autorelease]
    #define yas_super_dealloc() [super dealloc]
    #define yas_dispatch_queue_retain(__v) dispatch_retain(__v)
    #define yas_dispatch_queue_release(__v) dispatch_release(__v)
    #define yas_weak_for_block __block
    #define yas_weak_for_property assign
    #define yas_weak_for_variable __unsafe_unretained
#else
    #define yas_autorelease(__v) __v
    #define yas_retain(__v) __v
    #define yas_retain_or_ignore(__v)
    #define yas_release(__v)
    #define yas_retain_and_autorelease(__v) __v
    #define yas_super_dealloc()
    #if OS_OBJECT_USE_OBJC
        #define yas_dispatch_queue_retain(__v)
        #define yas_dispatch_queue_release(__v)
    #else
        #define yas_dispatch_queue_retain(__v) dispatch_retain(__v)
        #define yas_dispatch_queue_release(__v) dispatch_release(__v)
    #endif
    #define yas_weak_for_block __weak
    #define yas_weak_for_property weak
    #define yas_weak_for_variable __weak
#endif

#if DEBUG
    #define yas_log(...) NSLog(__VA_ARGS__)
#else
    #define yas_log(...)
#endif

#if TARGET_OS_IPHONE

@class UIColor, UIView, UIViewController;

#define yas_objc_color UIColor
#define yas_objc_view UIView
#define yas_objc_view_controller UIViewController
#define yas_edge_insets UIEdgeInsets

#elif TARGET_OS_MAC

@class NSColor, NSView, NSViewController;

#define yas_objc_color NSColor
#define yas_objc_view NSView
#define yas_objc_view_controller NSViewController
#define yas_edge_insets NSEdgeInsets

#endif
