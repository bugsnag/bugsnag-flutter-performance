#!/usr/bin/env bash
set -o errexit

if [ -z "$FLUTTER_BIN" ]; then
  FLUTTER_BIN="flutter"
fi

echo "Flutter Bin: $FLUTTER_BIN"

EXPORT_OPTIONS="$(pwd)/features/fixture_resources/exportOptions.plist"

echo "EXPORT OPTIONS: $EXPORT_OPTIONS"

cd features/fixtures/mazerunner/ios



xcodebuild DEVELOPMENT_TEAM=7W9PZ27Y5F
