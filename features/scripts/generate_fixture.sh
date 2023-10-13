#!/usr/bin/env bash
set -o errexit

if [ -z "$FLUTTER_BIN" ]; then
  FLUTTER_BIN="flutter"
fi

FIXTURE_LOCATION="features/fixtures/app"

PACKAGE_PATH="$(pwd)/packages/bugsnag_flutter_performance" 

EXPORT_OPTIONS="features/fixture_resources/exportOptions.plist"

XCODE_PROJECT=features/fixtures/app/ios/Runner.xcodeproj/project.pbxproj

echo "Remove old fixture"

rm -rf $FIXTURE_LOCATION

echo "Create blank fixture"

$FLUTTER_BIN create $FIXTURE_LOCATION  --org com.bugsnag --platforms=ios,android

echo "Add perf sdk dep"

$FLUTTER_BIN pub add --directory="$FIXTURE_LOCATION" "bugsnag_flutter_performance:{'path':'$PACKAGE_PATH'}"

sed -i '' "s/ENABLE_BITCODE = NO;/ENABLE_BITCODE = NO;\nDEVELOPMENT_TEAM = 7W9PZ27Y5F;/g" "$XCODE_PROJECT"