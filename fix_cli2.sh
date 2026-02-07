#!/bin/bash

# Restore original CLI2.cpp
git checkout src/CLI2.cpp

# Now apply the correct fix
# Find the problematic section and replace it
sed -i '218,235c\
  // If there are arguments, try to find \"--\" among them.\
  if (argc)\
  {\
    std::reverse_iterator<const char**> rlast(argv + argc);\
    std::reverse_iterator<const char**> rfirst(argv);\
    auto rit = std::find(rfirst, rlast, std::string(\"--\"));\
    if (rit != rlast)\
    {\
      // Convert reverse iterator to forward iterator\
      auto it = rit.base() - 1;\
      const int count = it - argv;\
      for (int i = 0; i < count; ++i)\
        _args.push_back (argv[i]);\
    }\
    else\
    {\
      for (int i = 0; i < argc; ++i)\
        _args.push_back (argv[i]);\
    }\
  }' src/CLI2.cpp
