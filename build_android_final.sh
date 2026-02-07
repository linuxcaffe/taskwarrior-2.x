#!/bin/bash
set -e

echo "=== Building Taskwarrior for Android ==="

# Setup
export NDK=$HOME/android-ndk-r25c
BUILD_DIR="build-android"
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# Configure
echo "1. Configuring..."
cmake .. \
  -DCMAKE_TOOLCHAIN_FILE=$NDK/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-21 \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=14 \
  -DENABLE_SYNC=OFF \
  -DHAVE_GNUTLS=OFF \
  -DHAVE_LIBUUID=1 \
  2>&1 | tee configure.log

echo "2. Patching source files for Android..."

# Patch FS.cpp for Android (glob function)
cd ..
if [ -f "src/libshared/src/FS.cpp" ]; then
    echo "  Patching FS.cpp..."
    cp src/libshared/src/FS.cpp src/libshared/src/FS.cpp.bak
    
    # Create patched version
    cat > /tmp/fs_patched.cpp << 'FSPATCH'
#include "FS.h"
#include <string>
#include <vector>

#ifndef __ANDROID__
#include <glob.h>
#include <wordexp.h>
#endif

namespace libshared {
namespace FS {

std::vector <std::string> glob (const std::string& pattern)
{
#ifdef __ANDROID__
  // Android doesn't have glob
  std::vector <std::string> result;
  result.push_back(pattern);
  return result;
#else
  std::vector <std::string> result;
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
  return result;
#endif
}

} // namespace FS
} // namespace libshared
FSPATCH
    
    # Replace just the glob function
    # Find start of glob function
    start_line=$(grep -n "std::vector <std::string> glob" src/libshared/src/FS.cpp | head -1 | cut -d: -f1)
    if [ -n "$start_line" ]; then
        # Find end of function (next } at start of line)
        end_line=$(tail -n +$start_line src/libshared/src/FS.cpp | grep -n "^}" | head -1 | cut -d: -f1)
        end_line=$((start_line + end_line - 1))
        
        # Replace the function
        sed -i "${start_line},${end_line}c\$(cat /tmp/fs_patched.cpp)" src/libshared/src/FS.cpp
        echo "    Patched glob function"
    fi
fi

cd $BUILD_DIR

echo "3. Building..."
make -j4 2>&1 | tee build.log

if [ -f "src/task" ]; then
    echo "=== SUCCESS: Binary created! ==="
    file src/task
    ls -lh src/task
    
    echo "=== Testing on Android ==="
    echo "To test: adb push src/task /data/local/tmp/"
    echo "         adb shell chmod +x /data/local/tmp/task"
    echo "         adb shell /data/local/tmp/task version"
else
    echo "=== BUILD FAILED ==="
    echo "Last 50 lines of build.log:"
    tail -50 build.log | grep -B5 -A5 "error:\|Error:"
fi
