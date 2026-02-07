/^std::vector <std::string> glob/,/^}/ {
    /^std::vector <std::string> glob/ {
        a\
#ifdef __ANDROID__\
  // Android doesn't have glob\
  std::vector <std::string> result;\
  result.push_back(pattern);\
  return result;\
#else
    }
    /^}/ {
        i\
#endif
    }
}
