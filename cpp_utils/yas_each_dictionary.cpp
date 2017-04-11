//
//  yas_each_dictionary.cpp
//

#include "yas_each_dictionary.h"
#include "yas_fast_each.h"

using namespace yas;

each_dictionary_iterator::each_dictionary_iterator(cf_type_vector_ptr const &keys_and_values, std::size_t const index)
    : _keys_and_values(keys_and_values), _index(index) {
}

each_dictionary_iterator &each_dictionary_iterator::operator++() {
    ++_index;
    return *this;
}

each_dictionary_iterator each_dictionary_iterator::operator++(int) {
    each_dictionary_iterator result = *this;
    ++_index;
    return result;
}

std::pair<CFTypeRef, CFTypeRef> const &each_dictionary_iterator::operator*() const {
    if (_index < _keys_and_values->size()) {
        return _keys_and_values->at(_index);
    }

    static std::pair<CFTypeRef, CFTypeRef> const null_pair = std::make_pair(nullptr, nullptr);
    return null_pair;
}

bool each_dictionary_iterator::operator==(each_dictionary_iterator const &rhs) const {
    return _index == rhs._index;
}

bool each_dictionary_iterator::operator!=(each_dictionary_iterator const &rhs) const {
    return _index != rhs._index;
}

#pragma mark -

each_dictionary::each_dictionary(CFDictionaryRef const dict)
    : _keys_and_values(std::make_shared<cf_type_vector>()), _dict(dict) {
    CFRetain(dict);

    std::size_t const count = CFDictionaryGetCount(dict);
    _keys_and_values->reserve(count);
    std::vector<CFTypeRef> keys{count};
    std::vector<CFTypeRef> values{count};

    CFDictionaryGetKeysAndValues(dict, keys.data(), values.data());

    auto each = make_fast_each(count);
    while (yas_fast_each_next(each)) {
        auto const &idx = yas_fast_each_index(each);
        _keys_and_values->emplace_back(std::make_pair(keys.at(idx), values.at(idx)));
    }
}

each_dictionary::~each_dictionary() {
    CFRelease(_dict);
}

bool each_dictionary::operator==(each_dictionary const &rhs) const {
    return _dict == rhs._dict;
}

bool each_dictionary::operator!=(each_dictionary const &rhs) const {
    return _dict != rhs._dict;
}

each_dictionary::iterator each_dictionary::begin() const {
    return iterator{_keys_and_values, 0};
}

each_dictionary::iterator each_dictionary::end() const {
    return iterator{_keys_and_values, _keys_and_values->size()};
}
