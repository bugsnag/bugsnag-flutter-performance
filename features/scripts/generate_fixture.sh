#!/usr/bin/env bash
set -o errexit

if [ -z "$FLUTTER_BIN" ]; then
  FLUTTER_BIN="flutter"
fi

# Common environment
FIXTURE_LOCATION=features/fixtures/mazerunner
PACKAGE_PATH="$(pwd)/packages/bugsnag_flutter_performance"
SRC_DART_LOCATION=features/fixture_resources/lib

# Android environment
ANDROID_MANIFEST=features/fixtures/mazerunner/android/app/src/main/AndroidManifest.xml
SRC_ANDROID_LOCATION=features/fixture_resources/android

# iOS environment
EXPORT_OPTIONS=features/fixture_resources/exportOptions.plist
XCODE_PROJECT=features/fixtures/mazerunner/ios/Runner.xcodeproj/project.pbxproj
SRC_IOS_LOCATION=features/fixture_resources/ios

echo "Remove old fixture"
rm -rf $FIXTURE_LOCATION

echo "Create blank fixture"
$FLUTTER_BIN create $FIXTURE_LOCATION  --org com.bugsnag --platforms=ios,android -i objc -a java

echo "Add dependencies"
$FLUTTER_BIN pub add --directory="$FIXTURE_LOCATION" "bugsnag_flutter_performance:{'path':'$PACKAGE_PATH'}"
$FLUTTER_BIN pub add --directory="$FIXTURE_LOCATION" path_provider
$FLUTTER_BIN pub add --directory="$FIXTURE_LOCATION" http

echo "Add dev team to Xcode project"
sed -i '' "s/ENABLE_BITCODE = NO;/ENABLE_BITCODE = NO;\nDEVELOPMENT_TEAM = 7W9PZ27Y5F;\nCODE_SIGN_STYLE = Automatic;/g" "$XCODE_PROJECT"

echo "Add Android internet permission"
sed -i '' "s/<\/application>/<\/application>\n<uses-permission android:name='android.permission.INTERNET'\/\>/g" "$ANDROID_MANIFEST"

echo "Copy test fixture code"
cp -r $SRC_DART_LOCATION $FIXTURE_LOCATION
cp -r $SRC_ANDROID_LOCATION $FIXTURE_LOCATION
cp -r $SRC_IOS_LOCATION $FIXTURE_LOCATION
