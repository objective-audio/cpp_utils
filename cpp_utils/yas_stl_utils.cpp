//
//  yas_stl_utils.cpp
//

#include "yas_stl_utils.h"

#include <sstream>

std::string yas::to_lower(std::string string) {
    std::transform(string.begin(), string.end(), string.begin(), ::tolower);
    return string;
}

std::string yas::replaced(std::string source, std::string const &target, std::string const &replacement) {
    std::string destination = std::move(source);
    std::string::size_type pos = 0;
    while (static_cast<void>(pos = destination.find(target, pos)), pos != std::string::npos) {
        destination.replace(pos, target.length(), replacement);
        pos += replacement.length();
    }
    return destination;
}

std::string yas::joined(std::vector<std::string> const &components, std::string const &separator) {
    std::ostringstream stream;
    bool is_first = true;
    for (auto const &component : components) {
        if (is_first) {
            is_first = false;
        } else {
            stream << separator;
        }
        stream << component;
    }
    return stream.str();
}

std::vector<std::string> yas::split(std::string const &text, char const separator) {
    std::vector<std::string> result;
    std::stringstream stream(text);
    std::string buffer;
    while (std::getline(stream, buffer, separator)) {
        result.emplace_back(std::move(buffer));
    }
    return result;
}
