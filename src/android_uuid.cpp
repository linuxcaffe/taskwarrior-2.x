#include "android_uuid.h"
#include <cstring>
#include <ctime>
#include <cstdlib>
#include <cstdio>

void uuid_generate(uuid_t out) {
    // Simple random UUID generator for Android
    srand(time(NULL));
    for (int i = 0; i < 16; i++) {
        out[i] = rand() % 256;
    }
    
    // Set version bits (version 4 = random)
    out[6] = (out[6] & 0x0F) | 0x40;
    out[8] = (out[8] & 0x3F) | 0x80;
}

void uuid_unparse_lower(const uuid_t uu, char *out) {
    sprintf(out,
           "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
           uu[0], uu[1], uu[2], uu[3], uu[4], uu[5], uu[6], uu[7],
           uu[8], uu[9], uu[10], uu[11], uu[12], uu[13], uu[14], uu[15]);
}

int uuid_parse(const char *in, uuid_t uu) {
    // Simple parser for UUID strings
    if (strlen(in) != 36) return -1;
    
    unsigned int bytes[16];
    if (sscanf(in,
              "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
              &bytes[0], &bytes[1], &bytes[2], &bytes[3],
              &bytes[4], &bytes[5], &bytes[6], &bytes[7],
              &bytes[8], &bytes[9], &bytes[10], &bytes[11],
              &bytes[12], &bytes[13], &bytes[14], &bytes[15]) != 16) {
        return -1;
    }
    
    for (int i = 0; i < 16; i++) {
        uu[i] = bytes[i];
    }
    
    return 0;
}
