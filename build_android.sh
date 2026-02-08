#!/bin/bash
# Build Taskwarrior 2.6.2 for Android

set -e

export NDK=$HOME/android-ndk-r25c
export BUILD_DIR=build-android

echo "Building for Android..."
echo "NDK: $NDK"

# Clean and configure
rm -rf $BUILD_DIR
mkdir -p $BUILD_DIR
cd $BUILD_DIR

cmake .. \
  -DCMAKE_TOOLCHAIN_FILE=$NDK/build/cmake/android.toolchain.cmake \
  -DANDROID_ABI=arm64-v8a \
  -DANDROID_PLATFORM=android-21 \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_STANDARD=14 \
  -DENABLE_SYNC=OFF \
  -DHAVE_GNUTLS=OFF \
  -DHAVE_LIBUUID=1 \
  -DCMAKE_CXX_FLAGS="-D__ANDROID__"

# Build
make -j$(nproc)

echo "Build complete: $(pwd)/src/task"
echo "To test on Android:"
echo "  adb push src/task /data/local/tmp/"
echo "  adb shell chmod +x /data/local/tmp/task"
echo "  adb shell 'TASKDATA=/tmp/.task /data/local/tmp/task version'"
