//
//  yas_boolean.h
//

#pragma once

namespace yas {
struct boolean {
    boolean();

    boolean(bool const);

    boolean(boolean const &);
    boolean(boolean &&) noexcept;

    boolean &operator=(boolean const &);
    boolean &operator=(boolean &&);

    bool operator==(boolean const &) const;
    bool operator!=(boolean const &) const;

    bool operator<(boolean const &) const;
    bool operator<=(boolean const &) const;
    bool operator>(boolean const &) const;
    bool operator>=(boolean const &) const;

    explicit operator bool() const;

   private:
    bool _value;
};
}
