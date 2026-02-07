#!/bin/bash

# Find the function containing make_reverse_iterator
line_num=$(grep -n "make_reverse_iterator" src/CLI2.cpp | head -1 | cut -d: -f1)
if [ -z "$line_num" ]; then
    echo "No make_reverse_iterator found"
    exit 0
fi

echo "Found make_reverse_iterator at line $line_num"

# Get more context
start_func=$(grep -n "CLI2::handleArgs" src/CLI2.cpp | cut -d: -f1)
echo "Function starts at line $start_func"

# Show the function
sed -n "${start_func},$((start_func+50))p" src/CLI2.cpp

# Create a simple fix - just remove the problematic section for now
# We'll use a simpler approach
sed -i 's/std::make_reverse_iterator/std::reverse_iterator/g' src/CLI2.cpp

# Also fix the specific usage
sed -i '/auto last = std::reverse_iterator (argv);/,/auto first = std::reverse_iterator (argv + argc);/c\
  // Simple argument handling for Android\
  for (int i = 0; i < argc; ++i) {\
    _args.push_back(argv[i]);\
  }' src/CLI2.cpp
