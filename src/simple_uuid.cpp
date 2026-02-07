#include "simple_uuid.h"
#include <cstdlib>
#include <cstdio>
#include <ctime>
#include <unistd.h>
#include <string>
#include <cctype>

namespace SimpleUUID {
    std::string generate() {
        uuid_t uu;
        char out[37];
        
        uuid_generate(uu);
        uuid_unparse(uu, out);
        
        return std::string(out);
    }
}

// C implementations
void uuid_generate(uuid_t out) {
    static bool seeded = false;
    if (!seeded) {
        srand(time(NULL) ^ getpid());
        seeded = true;
    }
    
    for (int i = 0; i < 16; i++) {
        out[i] = rand() % 256;
    }
    
    // Set version 4 (random) and variant RFC 4122
    out[6] = (out[6] & 0x0F) | 0x40;
    out[8] = (out[8] & 0x3F) | 0x80;
}

void uuid_unparse_lower(const uuid_t uu, char *out) {
    std::snprintf(out, 37,
           "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
           uu[0], uu[1], uu[2], uu[3], uu[4], uu[5], uu[6], uu[7],
           uu[8], uu[9], uu[10], uu[11], uu[12], uu[13], uu[14], uu[15]);
}

void uuid_unparse(const uuid_t uu, char *out) {
    // uuid_unparse typically produces uppercase
    uuid_unparse_lower(uu, out);
    // Convert to uppercase
    for (int i = 0; i < 36; i++) {
        out[i] = std::toupper(out[i]);
    }
}

int uuid_parse(const char *in, uuid_t uu) {
    unsigned int b[16];
    
    // Try lowercase first
    if (std::sscanf(in,
              "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x",
              &b[0], &b[1], &b[2], &b[3], &b[4], &b[5], &b[6], &b[7],
              &b[8], &b[9], &b[10], &b[11], &b[12], &b[13], &b[14], &b[15]) == 16) {
        for (int i = 0; i < 16; i++) {
            uu[i] = b[i];
        }
        return 0;
    }
    
    // Try uppercase
    if (std::sscanf(in,
              "%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X",
              &b[0], &b[1], &b[2], &b[3], &b[4], &b[5], &b[6], &b[7],
              &b[8], &b[9], &b[10], &b[11], &b[12], &b[13], &b[14], &b[15]) == 16) {
        for (int i = 0; i < 16; i++) {
            uu[i] = b[i];
        }
        return 0;
    }
    
    return -1;
}
