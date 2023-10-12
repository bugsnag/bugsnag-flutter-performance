#!/usr/bin/env bash
set -o errexit

if [ -z "$FLUTTER_BIN" ]; then
  FLUTTER_BIN="flutter"
fi

FIXTURE_LOCATION="features/fixtures/mazerunner"

PACKAGE_PATH="$(pwd)/packages/bugsnag_flutter_performance" 

EXPORT_OPTIONS="features/fixture_resources/exportOptions.plist"

EXPORT_OPTIONS_DEST="features/fixtures/flutterperformancefixture/ios/exportOptions.plist"

echo "Remove old fixture"

rm -rf $FIXTURE_LOCATION

echo "Create blank fixture"

$FLUTTER_BIN create $FIXTURE_LOCATION  --org com.bugsnag

echo "Add perf sdk dep"

$FLUTTER_BIN pub add --directory="$FIXTURE_LOCATION" "bugsnag_flutter_performance:{'path':'$PACKAGE_PATH'}"

echo "Move Ios Export Options"

cp $EXPORT_OPTIONS $EXPORT_OPTIONS_DEST

echo "Move Fixture Code"