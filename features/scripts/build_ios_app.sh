#!/usr/bin/env bash
set -o errexit

if [ -z "$FLUTTER_BIN" ]; then
  FLUTTER_BIN="flutter"
fi

echo "Flutter Bin: $FLUTTER_BIN"

EXPORT_OPTIONS="$(pwd)/features/fixture_resources/exportOptions.plist"

echo "EXPORT OPTIONS: $EXPORT_OPTIONS"

cd features/fixtures/mazerunner

$FLUTTER_BIN build ipa --export-options-plist=$EXPORT_OPTIONS --no-tree-shake-icons
