//
//  yas_each_dictionary.h
//

#pragma once

#include <CoreFoundation/CoreFoundation.h>

#include <iterator>
#include <utility>
#include <vector>

namespace yas {
using cf_type_pair = std::pair<CFTypeRef, CFTypeRef>;
using cf_type_vector = std::vector<cf_type_pair>;
using cf_type_vector_ptr = std::shared_ptr<cf_type_vector>;

struct each_dictionary_iterator {
    each_dictionary_iterator(cf_type_vector_ptr const &keys_and_values, std::size_t const index);

    each_dictionary_iterator &operator++();
    each_dictionary_iterator operator++(int);

    std::pair<CFTypeRef, CFTypeRef> const &operator*() const;

    bool operator==(each_dictionary_iterator const &rhs) const;
    bool operator!=(each_dictionary_iterator const &rhs) const;

   private:
    cf_type_vector_ptr _keys_and_values;
    std::size_t _index;
};

class each_dictionary {
   public:
    using iterator = each_dictionary_iterator;

    each_dictionary(CFDictionaryRef const dict);
    ~each_dictionary();

    bool operator==(each_dictionary const &rhs) const;
    bool operator!=(each_dictionary const &rhs) const;

    each_dictionary::iterator begin() const;
    each_dictionary::iterator end() const;

   private:
    cf_type_vector_ptr _keys_and_values;
    CFDictionaryRef _dict;
};
}  // namespace yas
