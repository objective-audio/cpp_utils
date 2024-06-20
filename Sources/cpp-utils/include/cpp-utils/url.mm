//
//  url.mm
//

#include "url.h"

#include "cf_utils.h"
#include "objc_ptr.h"

#include <Foundation/Foundation.h>

using namespace yas;

struct url::impl {
    objc_ptr<NSURL *> _url;

    impl(objc_ptr<NSURL *> &&url) : _url(std::move(url)) {
    }

    impl(std::string const &str)
        : _url(objc_ptr_with_move_object([[NSURL alloc] initWithString:(__bridge NSString *)to_cf_object(str)])) {
    }

    bool is_equal(std::shared_ptr<impl> const &rhs) const {
        return [this->_url.object() isEqual:rhs->_url.object()];
    }
};

url::url(std::string const &str) : _impl(std::make_shared<impl>(str)) {
}

url::url(std::shared_ptr<impl> &&impl) : _impl(std::move(impl)) {
}

url url::file_url(std::string const &str) {
    auto url = objc_ptr_with_move_object([[NSURL alloc] initFileURLWithPath:(__bridge NSString *)to_cf_object(str)]);
    return yas::url{std::make_shared<impl>(std::move(url))};
}

std::string url::path() const {
    return to_string((__bridge CFStringRef)(this->_impl->_url.object().path));
}

std::string url::last_path_component() const {
    return to_string((__bridge CFStringRef)(this->_impl->_url.object().lastPathComponent));
}

CFURLRef url::cf_url() const {
    return (__bridge CFURLRef)this->_impl->_url.object();
}

url url::appending(std::string const &str) const {
    auto url = objc_ptr<NSURL *>([this, &str]() {
        return [this->_impl->_url.object() URLByAppendingPathComponent:(__bridge NSString *)to_cf_object(str)];
    });
    return yas::url{std::make_shared<impl>(std::move(url))};
}

url url::deleting_last_path_component() const {
    auto url = objc_ptr<NSURL *>([this]() { return [this->_impl->_url.object() URLByDeletingLastPathComponent]; });
    return yas::url{std::make_shared<impl>(std::move(url))};
}

url url::deleting_path_extension() const {
    auto url = objc_ptr<NSURL *>([this]() { return [this->_impl->_url.object() URLByDeletingPathExtension]; });
    return yas::url{std::make_shared<impl>(std::move(url))};
}

bool url::operator==(url const &rhs) const {
    return this->_impl->is_equal(rhs._impl);
}

bool url::operator!=(url const &rhs) const {
    return !(*this == rhs);
}

#pragma mark -

std::string yas::to_string(url const &url) {
    return url.path();
}

#pragma mark -

std::ostream &operator<<(std::ostream &os, url const &url) {
    os << url.path();
    return os;
}
