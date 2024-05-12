//
//  ns_utils.mm
//

#include "ns_utils.h"

#include <Foundation/NSString.h>

using namespace yas;

objc_ptr<NSString *> yas::to_ns_object(std::string const &string) {
    NSString *nsString = [[NSString alloc] initWithCString:string.c_str() encoding:NSUTF8StringEncoding];

    if (nsString) {
        return objc_ptr_with_move_object(nsString);
    } else {
        return objc_ptr<NSString *>([] { return @""; });
    }
}
