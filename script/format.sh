#!/bin/sh

export PATH=$PATH:/opt/homebrew/bin
clang-format -i -style=file `find ../cpp_utils ../cpp_utils_tests -type f \( -name *.h -o -name *.cpp -o -name *.hpp -o -name *.m -o -name *.mm \)`
