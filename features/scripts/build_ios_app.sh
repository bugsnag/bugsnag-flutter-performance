#!/usr/bin/env bash
set -o errexit

if [ -z "$FLUTTER_BIN" ]; then
  FLUTTER_BIN="flutter"
fi

EXPORT_OPTIONS="$(pwd)/features/fixture_resources/exportOptions.plist"

cd features/fixtures/mazerunner/ios

$FLUTTER_BIN build ipa --export-options-plist=$EXPORT_OPTIONS --no-tree-shake-icons

ls

cd ..

cd build/ios/ipa

ls