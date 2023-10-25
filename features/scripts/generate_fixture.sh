#!/usr/bin/env bash
set -o errexit

if [ -z "$FLUTTER_BIN" ]; then
  FLUTTER_BIN="flutter"
fi

FIXTURE_LOCATION=features/fixtures/mazerunner

PACKAGE_PATH="$(pwd)/packages/bugsnag_flutter_performance" 

EXPORT_OPTIONS=features/fixture_resources/exportOptions.plist

XCODE_PROJECT=features/fixtures/mazerunner/ios/Runner.xcodeproj/project.pbxproj

DART_LOCATION=features/fixtures/mazerunner/lib

DART_TEST_LOCATION=features/fixtures/test

BS_DART_LOACTION=features/fixture_resources/lib

BS_DART_DESTINATION=features/fixtures/mazerunner

echo "Remove old fixture"

rm -rf $FIXTURE_LOCATION

echo "Create blank fixture"

$FLUTTER_BIN create $FIXTURE_LOCATION  --org com.bugsnag --platforms=ios,android

echo "Add deps"

$FLUTTER_BIN pub add --directory="$FIXTURE_LOCATION" "bugsnag_flutter_performance:{'path':'$PACKAGE_PATH'}"

$FLUTTER_BIN pub add --directory="$FIXTURE_LOCATION" path_provider

$FLUTTER_BIN pub add --directory="$FIXTURE_LOCATION" http

echo "Add dev team to xcode project"

sed -i '' "s/ENABLE_BITCODE = NO;/ENABLE_BITCODE = NO;\nDEVELOPMENT_TEAM = 7W9PZ27Y5F;\nCODE_SIGN_STYLE = Automatic;/g" "$XCODE_PROJECT"

echo "copy over dart code"

rm -rf $DART_TEST_LOCATION

rm -rf $DART_LOCATION

cp -r $BS_DART_LOACTION $BS_DART_DESTINATION