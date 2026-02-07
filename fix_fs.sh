#!/bin/bash

# Restore original FS.cpp
git checkout src/libshared/src/FS.cpp

# Now replace just the glob function
# First find the exact lines of the glob function
start_line=$(grep -n "^std::vector <std::string> FS::glob" src/libshared/src/FS.cpp | cut -d: -f1)
echo "glob function starts at line: $start_line"

if [ -n "$start_line" ]; then
  # Create the fixed function
  cat > /tmp/new_glob.cxx << 'GLOBFUNC'
std::vector <std::string> FS::glob (const std::string& pattern)
{
  std::vector <std::string> result;
#ifndef __ANDROID__
  glob_t g;
  if (!::glob (pattern.c_str (), GLOB_ERR | GLOB_BRACE | GLOB_TILDE, nullptr, &g))
  {
    for (unsigned int i = 0; i < g.gl_pathc; ++i)
      result.push_back (g.gl_pathv[i]);
  }

  globfree (&g);
#else
  // Android doesn't have glob function
  // Simple implementation that returns the pattern
  result.push_back(pattern);
#endif
  return result;
}
GLOBFUNC

  # Find the end of the function (next line with just '}')
  # Look from start_line to start_line+50
  end_line=$(tail -n +$start_line src/libshared/src/FS.cpp | head -50 | grep -n "^}" | head -1 | cut -d: -f1)
  end_line=$((start_line + end_line - 1))
  
  echo "Replacing lines $start_line to $end_line"
  sed -i "${start_line},${end_line}c\$(cat /tmp/new_glob.cxx)" src/libshared/src/FS.cpp
fi
