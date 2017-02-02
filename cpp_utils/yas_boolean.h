//
//  yas_boolean.h
//

#pragma once

namespace yas {
struct boolean {
    boolean();
    
    boolean(bool const);

    boolean(boolean const &);
    boolean(boolean &&rhs) noexcept;

    boolean &operator=(boolean const &rhs);
    boolean &operator=(boolean &&rhs);

    bool operator==(boolean const &rhs) const;
    bool operator!=(boolean const &rhs) const;

    explicit operator bool() const;

   private:
    bool _value;
};
}
