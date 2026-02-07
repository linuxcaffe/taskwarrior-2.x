import re

with open('src/libshared/src/FS.cpp', 'r') as f:
    content = f.read()

# Replace the glob function
new_glob = '''std::vector <std::string> glob (const std::string& pattern)
{
  std::vector <std::string> result;
  
  // ANDROID FIX: No glob on Android
#ifdef __ANDROID__
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
}'''

# Use regex to find and replace
pattern = r'std::vector <std::string> glob \(const std::string& pattern\)\s*\{[^}]*\}'
content = re.sub(pattern, new_glob, content, flags=re.DOTALL)

with open('src/libshared/src/FS.cpp', 'w') as f:
    f.write(content)

print("Replaced glob function")
