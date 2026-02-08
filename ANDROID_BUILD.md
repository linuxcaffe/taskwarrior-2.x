# Android Build

Run: ./build_android.sh
Test: adb push build-android/src/task /data/local/tmp/
      adb shell chmod +x /data/local/tmp/task
      adb shell 'TASKDATA=/tmp/.task /data/local/tmp/task version'

