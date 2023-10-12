#!/usr/bin/env bash
set -o errexit

if [ -z "$FLUTTER_BIN" ]; then
  FLUTTER_BIN="flutter"
fi

echo "Flutter Bin: $FLUTTER_BIN"

cd features/fixtures/mazerunner

$FLUTTER_BIN build ipa --export-options-plist="$(pwd)/features/fixture_resources/exportOptions.plist" --no-tree-shake-icons
