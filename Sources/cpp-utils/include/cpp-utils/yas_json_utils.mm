//
//  yas_json_utils.mm
//

#include "yas_json_utils.h"

#include "yas_cf_utils.h"

#import <Foundation/Foundation.h>

#include <objc-utils/yas_objc_macros.h>

using namespace yas;

json_value json_utils::to_json_value(id object) {
    if ([object isKindOfClass:[NSString class]]) {
        NSString *const string_object = object;
        return json_value{to_string((__bridge CFStringRef)string_object)};
    } else if ([object isKindOfClass:[NSArray class]]) {
        std::vector<json_value> vector;

        NSArray *const array = object;
        for (id arrayValue in array) {
            if (auto value = to_json_value(arrayValue); !value.is_empty()) {
                vector.emplace_back(std::move(value));
            }
        }

        return json_value{std::move(vector)};
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        std::map<std::string, json_value> map;

        NSDictionary *const dictionary = object;
        for (NSString *dictKey in dictionary.allKeys) {
            if ([dictKey isKindOfClass:[NSString class]]) {
                if (auto value = to_json_value(dictionary[dictKey]); !value.is_empty()) {
                    map.emplace(to_string((__bridge CFStringRef)dictKey), std::move(value));
                }
            }
        }

        return json_value{std::move(map)};
    } else if ([object isKindOfClass:[NSNumber class]]) {
        NSNumber *const number = object;

        const char *objc_type = number.objCType;

        if (*objc_type == 'f' || *objc_type == 'd') {
            return json_value{number.doubleValue};
        } else {
            return json_value{(int64_t)number.integerValue};
        }
    } else {
        return std::nullopt;
    }
}

id json_utils::to_json_object(json_value const &value) {
    if (value.integer.has_value()) {
        return @(value.integer.value());
    } else if (value.real.has_value()) {
        return @(value.real.value());
    } else if (value.string.has_value()) {
        return (__bridge NSString *)to_cf_object(value.string.value());
    } else if (value.has_value(json_value_kind::map)) {
        NSMutableDictionary *const dictionary = yas_autorelease([[NSMutableDictionary alloc] init]);

        for (auto const &pair : value.map.value()) {
            if (auto const &value = pair.second; !value.is_empty()) {
                NSString *const key = (__bridge NSString *)to_cf_object(pair.first);
                dictionary[key] = to_json_object(value);
            }
        }

        return dictionary;
    } else if (value.has_value(json_value_kind::vector)) {
        NSMutableArray *const array = yas_autorelease([[NSMutableArray alloc] init]);

        auto const &vector = value.vector.value();
        for (auto const &value : vector) {
            if (id object = to_json_object(value); object != nil) {
                [array addObject:object];
            }
        }

        return array;
    } else {
        return nil;
    }
}
