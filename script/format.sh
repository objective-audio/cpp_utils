#!/bin/sh

clang-format -i -style=file `find cpp_utils cpp_utils_test/cpp_utils_test -type f \( -name *.h -o -name *.cpp -o -name *.hpp -o -name *.m -o -name *.mm \)`
