#!/bin/bash

# Fix util.h - replace the conditional includes
sed -i '35,45c\
#if defined(FREEBSD) || defined(OPENBSD)\
#ifdef HAVE_LIBUUID\
#include <uuid.h>\
#endif\
#else\
#ifdef HAVE_LIBUUID\
#include <uuid/uuid.h>\
#endif\
#endif\
#include <Table.h>\
\
// util.cpp\
int confirm4 (const std::string&);' src/util.h

# Find and fix ALL uuid includes
echo "Searching for uuid includes..."
for file in $(find src -name "*.cpp" -o -name "*.h"); do
  if grep -q "#include.*uuid" "$file"; then
    echo "Fixing $file"
    # Handle different include styles
    sed -i 's/#include <uuid\.h>/#ifdef HAVE_LIBUUID\n#include <uuid.h>\n#endif/g' "$file"
    sed -i 's/#include <uuid\/uuid\.h>/#ifdef HAVE_LIBUUID\n#include <uuid\/uuid.h>\n#endif/g' "$file"
  fi
done
