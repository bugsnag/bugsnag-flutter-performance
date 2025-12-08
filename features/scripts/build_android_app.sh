#!/usr/bin/env bash
set -o errexit
set -o pipefail
set -o nounset

if [[ -z "${FLUTTER_BIN:-}" ]]; then
  FLUTTER_BIN="flutter"
  echo "FLUTTER_BIN not set; defaulting to 'flutter'"
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
"$FLUTTER_BIN" build apk --no-tree-shake-icons
