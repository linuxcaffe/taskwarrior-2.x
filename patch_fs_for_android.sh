#!/bin/bash

# Find the glob function
start_line=$(grep -n "std::vector.*FS::glob" src/libshared/src/FS.cpp | head -1 | cut -d: -f1)
if [ -z "$start_line" ]; then
    echo "Could not find glob function"
    exit 1
fi

# Find the end of the function
end_line=$(awk -v start="$start_line" 'NR >= start && /^}/ {print NR; exit}' src/libshared/src/FS.cpp)
if [ -z "$end_line" ]; then
    echo "Could not find end of glob function"
    exit 1
fi

echo "Glob function from line $start_line to $end_line"

# Create the patched function
cat > /tmp/patched_glob_function.cpp << 'FUNCTIONPATCH'
std::vector <std::string> FS::glob (const std::string& pattern)
{
  std::vector <std::string> result;
  
#ifdef __ANDROID__
  // Android doesn't have glob - return pattern as-is
  result.push_back(pattern);
#else
  glob_t g;
#ifdef SOLARIS
  if (!::glob (pattern.c_str (), GLOB_ERR, nullptr, &g))
#else
  if (!::glob (pattern.c_str (), GLOB_ERR | GLOB_BRACE | GLOB_TILDE, nullptr, &g))
#endif
  {
    for (unsigned int i = 0; i < g.gl_pathc; ++i)
      result.push_back (g.gl_pathv[i]);
  }

  globfree (&g);
#endif
  
  return result;
}
FUNCTIONPATCH

# Replace the function
echo "Patching FS.cpp..."
sed -i "${start_line},${end_line}c\$(cat /tmp/patched_glob_function.cpp)" src/libshared/src/FS.cpp

echo "Done!"
