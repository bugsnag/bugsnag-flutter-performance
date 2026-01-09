#!/usr/bin/env bash
set -o errexit

# Select Flutter binary
# Use FLUTTER_BIN if provided by CI, otherwise default to flutter
FLUTTER_BIN="${FLUTTER_BIN:-flutter}"

echo "Using Flutter binary: $FLUTTER_BIN"

echo "--- 📦 Bundle Install"
if ! bundle install; then
  echo "Warning: bundle install failed but continuing"
fi

echo "--- 🔧 Generate Fixture"
./features/scripts/generate_fixture.sh

echo "--- 🚀 Building Flutter APK"
cd features/fixtures/mazerunner
$FLUTTER_BIN build apk --no-tree-shake-icons