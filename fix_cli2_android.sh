#!/bin/bash

# Find the handleArgs function
start_line=$(grep -n "CLI2::handleArgs" src/CLI2.cpp | cut -d: -f1)
if [ -z "$start_line" ]; then
    echo "Could not find handleArgs function"
    exit 1
fi

# Find the end of the function (look for the next '}' at same indentation)
end_line=$(tail -n +$start_line src/CLI2.cpp | grep -n "^  }" | head -1 | cut -d: -f1)
end_line=$((start_line + end_line - 1))

echo "Function from line $start_line to $end_line"

# Create a fixed version
cat > /tmp/fixed_handleargs.cpp << 'FUNCTIONFIX'
////////////////////////////////////////////////////////////////////////////////
void CLI2::handleArgs (int argc, const char** argv)
{
  // If there are arguments, try to find '--' among them.
  if (argc)
  {
#ifndef __ANDROID__
    // Original code with make_reverse_iterator
    auto last = std::make_reverse_iterator (argv);
    auto first = std::make_reverse_iterator (argv + argc);
    auto rit = std::find (first, last, std::string ("--"));
#else
    // Android-compatible version
    std::reverse_iterator<const char**> last(argv);
    std::reverse_iterator<const char**> first(argv + argc);
    auto rit = std::find (first, last, std::string ("--"));
#endif
    if (rit != last)
    {
      // Convert reverse iterator to forward iterator
      auto it = rit.base () - 1;
      const int count = it - argv;
      for (int i = 0; i < count; ++i)
        _args.push_back (argv[i]);
    }
    else
    {
      for (int i = 0; i < argc; ++i)
        _args.push_back (argv[i]);
    }
  }
}
FUNCTIONFIX

# Replace the function in the source file
echo "Replacing function..."
sed -i "${start_line},${end_line}c\$(cat /tmp/fixed_handleargs.cpp)" src/CLI2.cpp

echo "Fixed CLI2.cpp for Android"
