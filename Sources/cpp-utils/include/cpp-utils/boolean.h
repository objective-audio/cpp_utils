//
//  boolean.h
//

#pragma once

#include <ostream>
#include <string>

namespace yas {
struct boolean {
    boolean();

    boolean(boolean const &);
    boolean(boolean &&) noexcept;

    boolean(bool const &);
    boolean(bool &&) noexcept;

    boolean &operator=(boolean const &);
    boolean &operator=(boolean &&);

    bool operator==(boolean const &) const;
    bool operator!=(boolean const &) const;

    bool operator<(boolean const &) const;
    bool operator<=(boolean const &) const;
    bool operator>(boolean const &) const;
    bool operator>=(boolean const &) const;

    explicit operator bool() const;

    bool const &raw() const;

   private:
    bool _value;
};

std::string to_string(boolean const &);
}  // namespace yas

std::ostream &operator<<(std::ostream &, yas::boolean const &);
