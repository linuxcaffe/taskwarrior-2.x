#!/usr/bin/env python3
import re

with open('src/CLI2.cpp', 'r') as f:
    content = f.read()

# Fix 1: Replace make_reverse_iterator calls
# Original: auto last = std::make_reverse_iterator (argv);
# Should be: auto last = std::reverse_iterator<const char**>(argv + argc);
# Original: auto first = std::make_reverse_iterator (argv + argc);
# Should be: auto first = std::reverse_iterator<const char**>(argv);

content = re.sub(
    r'auto last = std::make_reverse_iterator \(argv\);',
    r'auto last = std::reverse_iterator<const char**>(argv + argc);',
    content
)

content = re.sub(
    r'auto first = std::make_reverse_iterator \(argv \+ argc\);',
    r'auto first = std::reverse_iterator<const char**>(argv);',
    content
)

# Also need to fix the other make_reverse_iterator in applyOverrides
content = re.sub(
    r'auto last = std::make_reverse_iterator \(argv\);',
    r'auto last = std::reverse_iterator<const char**>(argv + argc);',
    content
)

content = re.sub(
    r'auto first = std::make_reverse_iterator \(argv \+ argc\);', 
    r'auto first = std::reverse_iterator<const char**>(argv);',
    content
)

with open('src/CLI2.cpp', 'w') as f:
    f.write(content)

print("Fixed CLI2.cpp")
