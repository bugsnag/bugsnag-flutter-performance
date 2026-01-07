#!/usr/bin/env bash
set -o errexit

# Select Flutter binary
# Prefer fvm if available, otherwise fall back to system flutter
if command -v fvm >/dev/null 2>&1; then
  FLUTTER_BIN="fvm flutter"
else
  FLUTTER_BIN="flutter"
fi

echo "--- 📦 Bundle Install"
if ! bundle install; then
  echo "Warning: bundle install failed but continuing"
fi

echo "--- 🔧 Generate Fixture"
echo "Running generate_fixture.sh script"
./features/scripts/generate_fixture.sh

echo "--- 🚀 Building Flutter APK"
cd features/fixtures/mazerunner
$FLUTTER_BIN build apk --no-tree-shake-icons
