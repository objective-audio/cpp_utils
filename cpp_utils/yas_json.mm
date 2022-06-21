//
//  yas_json.mm
//

#include "yas_json.h"
#import <Foundation/Foundation.h>
#include <cpp_utils/yas_cf_utils.h>
#include <cpp_utils/yas_json_utils.h>

using namespace yas;

std::string yas::to_json_string(json_value const &json_value) {
    id json_object = json_utils::to_json_object(json_value);

    if (!json_object) {
        return "";
    }

    NSData *const data = [NSJSONSerialization dataWithJSONObject:json_object options:kNilOptions error:nil];

    if (!data) {
        return "";
    }

    NSString *const json_string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (json_string) {
        return to_string((__bridge CFStringRef)json_string);
    } else {
        return "";
    }
}

json_value yas::to_json_value(std::string const &string) {
    auto *const ns_string = (__bridge NSString *)to_cf_object(string);

    NSData *const data = [ns_string dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return std::nullopt;
    }

    id const json_object = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    if (!json_object) {
        return std::nullopt;
    }

    return json_utils::to_json_value(json_object);
}
