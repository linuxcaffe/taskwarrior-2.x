#ifndef SIMPLE_UUID_H
#define SIMPLE_UUID_H

#include <string>

// Simple UUID implementation for Android
namespace SimpleUUID {
    std::string generate();
}

// C interface for compatibility
#ifdef __cplusplus
extern "C" {
#endif

typedef unsigned char uuid_t[16];
void uuid_generate(uuid_t out);
void uuid_unparse(const uuid_t uu, char *out);
void uuid_unparse_lower(const uuid_t uu, char *out);
int uuid_parse(const char *in, uuid_t uu);

#ifdef __cplusplus
}
#endif

#endif
