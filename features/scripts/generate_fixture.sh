#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Cross-version fixture generator (Flutter 3.24 + 3.38+)
# - Uses flutter --version --machine (stable parsing)
# - Runs flutter version detection once
# - Portable sed in-place editing (macOS + Linux)
# - Quotes all paths, avoids rm footguns
# - Batches pub add where possible
# - Uses dependency_overrides for local path (more robust than inline map parsing)
# - Pins package_info_plus to 8.x on older Flutter to avoid AGP/Kotlin requirements in 9.x
###############################################################################

# Prefer fvm if available
if command -v fvm >/dev/null 2>&1; then
  FLUTTER_BIN=(fvm flutter)
else
  FLUTTER_BIN=(flutter)
fi

# Paths
FIXTURE_LOCATION="features/fixtures/mazerunner"
PACKAGE_PATH="$(pwd)/packages/bugsnag_flutter_performance"

EXPORT_OPTIONS="features/fixture_resources/exportOptions.plist" # (unused currently; left for parity)
XCODE_PROJECT="$FIXTURE_LOCATION/ios/Runner.xcodeproj/project.pbxproj"
XCODE_PLIST="$FIXTURE_LOCATION/ios/Runner/Info.plist"
ANDROID_MANIFEST="$FIXTURE_LOCATION/android/app/src/main/AndroidManifest.xml"
PODFILE="$FIXTURE_LOCATION/ios/Podfile"

DART_LOCATION="$FIXTURE_LOCATION/lib"
DART_TEST_LOCATION="features/fixtures/test"
BS_DART_LOCATION="features/fixture_resources/lib"
BS_DART_DESTINATION="$FIXTURE_LOCATION"

# Portable sed -i wrapper (macOS BSD sed vs GNU sed)
sedi() {
  if sed --version >/dev/null 2>&1; then
    # GNU sed
    sed -i "$@"
  else
    # BSD sed (macOS)
    sed -i '' "$@"
  fi
}

# Extract flutter frameworkVersion once (JSON via --machine)
FLUTTER_JSON="$("${FLUTTER_BIN[@]}" --version --machine)"
FLUTTER_VERSION="$(
  printf '%s' "$FLUTTER_JSON" | python3 - <<'PY'
import json, sys
data=json.load(sys.stdin)
print(data.get("frameworkVersion",""))
PY
)"

if [[ -z "$FLUTTER_VERSION" ]]; then
  echo "ERROR: Could not determine Flutter version from --machine output" >&2
  exit 1
fi

echo "Detected Flutter version: $FLUTTER_VERSION"

# Basic semver compare: returns 0 if A >= B, else 1
ver_ge() {
  python3 - "$1" "$2" <<'PY'
import sys, re
def norm(v):
  # keep numeric dot parts only, ignore suffixes like -beta
  v = re.split(r'[-+]', v.strip())[0]
  parts = v.split('.')
  nums = []
  for p in parts:
    m = re.match(r'^(\d+)', p)
    nums.append(int(m.group(1)) if m else 0)
  while len(nums) < 3:
    nums.append(0)
  return tuple(nums[:3])

a = norm(sys.argv[1])
b = norm(sys.argv[2])
sys.exit(0 if a >= b else 1)
PY
}

# Helpers
ensure_in_file() {
  # ensure_in_file "literal line to search" "file"
  local needle="$1"
  local file="$2"
  grep -Fq "$needle" "$file" 2>/dev/null || return 1
}

append_if_missing() {
  # append_if_missing "literal line" "file"
  local line="$1"
  local file="$2"
  if ! grep -Fq "$line" "$file" 2>/dev/null; then
    printf "\n%s\n" "$line" >> "$file"
  fi
}

###############################################################################
# Create fresh fixture
###############################################################################
echo "Remove old fixture: $FIXTURE_LOCATION"
rm -rf "$FIXTURE_LOCATION"

echo "Create blank fixture"
"${FLUTTER_BIN[@]}" create "$FIXTURE_LOCATION" --org com.bugsnag --platforms=ios,android

###############################################################################
# Add dependencies (batch most of them)
###############################################################################
echo "Add dependencies (batched)"

# Add these in one go to reduce churn
"${FLUTTER_BIN[@]}" pub add --directory="$FIXTURE_LOCATION" \
  path_provider \
  http \
  dio \
  bugsnag_flutter \
  bugsnag_http_client \
  bugsnag_flutter_dart_io_http_client \
  bugsnag_flutter_performance

# Make local path override for bugsnag_flutter_performance (more robust than pub-add inline map)
PUBSPEC="$FIXTURE_LOCATION/pubspec.yaml"

if ! grep -qE '^[[:space:]]*dependency_overrides:' "$PUBSPEC"; then
  printf "\ndependency_overrides:\n" >> "$PUBSPEC"
fi

# Remove any existing override stanza for bugsnag_flutter_performance (best-effort)
python3 - "$PUBSPEC" "$PACKAGE_PATH" <<'PY'
import sys, re
pubspec = sys.argv[1]
path = sys.argv[2]

lines = open(pubspec, "r", encoding="utf-8").read().splitlines()

out = []
i = 0
while i < len(lines):
    line = lines[i]
    # Remove an existing override block:
    #   bugsnag_flutter_performance:
    #     path: ...
    if re.match(r'^\s*bugsnag_flutter_performance:\s*$', line):
        # If the previous non-empty is within dependency_overrides, remove this entry (and possible indented children)
        # We'll just skip this line + following indented children.
        i += 1
        while i < len(lines) and (lines[i].startswith("  ") or lines[i].startswith("\t")):
            # keep dependency_overrides itself; only remove this package entry
            if re.match(r'^\s*dependency_overrides:\s*$', lines[i]):
                break
            i += 1
        continue
    out.append(line)
    i += 1

# Ensure dependency_overrides exists
if not any(re.match(r'^\s*dependency_overrides:\s*$', l) for l in out):
    out.append("")
    out.append("dependency_overrides:")

# Append our override at the end (safe + predictable)
out.append("  bugsnag_flutter_performance:")
out.append(f"    path: {path}")

open(pubspec, "w", encoding="utf-8").write("\n".join(out) + "\n")
PY

###############################################################################
# Work around package_info_plus 9.x on older Flutter (3.24)
# package_info_plus 9.x requires newer AGP/Gradle/Kotlin; pin to 8.x for older Flutter.
###############################################################################
if ! ver_ge "$FLUTTER_VERSION" "3.38.0"; then
  echo "Pin package_info_plus to 8.x for older Flutter (<3.38)"
  "${FLUTTER_BIN[@]}" pub add --directory="$FIXTURE_LOCATION" "package_info_plus:^8.3.1"
fi

###############################################################################
# native_flutter_proxy version + import paths
# < 3.20.0             -> pin to 0.1.15
# >= 3.20.0 < 3.30.0   -> pin to 0.2.3 (and patch imports)
# >= 3.30.0            -> latest (and patch imports)
###############################################################################
update_native_flutter_proxy_imports() {
  # These edits are applied to the source that you copy into the fixture later
  # (features/fixture_resources/lib/main.dart).
  local target="$BS_DART_LOCATION/main.dart"
  if [[ -f "$target" ]]; then
    sedi "s|import 'package:native_flutter_proxy/custom_proxy.dart';|import 'package:native_flutter_proxy/src/custom_proxy.dart';|g" "$target"
    sedi "s|import 'package:native_flutter_proxy/native_proxy_reader.dart';|import 'package:native_flutter_proxy/src/native_proxy_reader.dart';|g" "$target"
  fi
}

echo "Configure native_flutter_proxy based on Flutter version"
if ver_ge "$FLUTTER_VERSION" "3.30.0"; then
  "${FLUTTER_BIN[@]}" pub add --directory="$FIXTURE_LOCATION" native_flutter_proxy
  update_native_flutter_proxy_imports
elif ver_ge "$FLUTTER_VERSION" "3.20.0"; then
  "${FLUTTER_BIN[@]}" pub add --directory="$FIXTURE_LOCATION" "native_flutter_proxy:0.2.3"
  update_native_flutter_proxy_imports
else
  "${FLUTTER_BIN[@]}" pub add --directory="$FIXTURE_LOCATION" "native_flutter_proxy:0.1.15"
fi

###############################################################################
# Android: minSdk + Gradle/AGP compatibility tweaks
###############################################################################
echo "Update Android minSdk to 19"

if [[ -f "$FIXTURE_LOCATION/android/app/build.gradle" ]]; then
  sedi 's/minSdkVersion flutter\.minSdkVersion/minSdkVersion 19/g' "$FIXTURE_LOCATION/android/app/build.gradle"
  # sanity check
  grep -qE 'minSdkVersion[[:space:]]+19' "$FIXTURE_LOCATION/android/app/build.gradle" || {
    echo "WARN: minSdk patch may not have applied (build.gradle)" >&2
  }
elif [[ -f "$FIXTURE_LOCATION/android/app/build.gradle.kts" ]]; then
  sedi 's/minSdk[[:space:]]*=[[:space:]]*flutter\.minSdkVersion/minSdk = 19/g' "$FIXTURE_LOCATION/android/app/build.gradle.kts"
  grep -qE 'minSdk[[:space:]]*=[[:space:]]*19' "$FIXTURE_LOCATION/android/app/build.gradle.kts" || {
    echo "WARN: minSdk patch may not have applied (build.gradle.kts)" >&2
  }
fi

echo "Fix Android root build.gradle evaluationDependsOn issues (line-only removal)"
# safer than deleting whole blocks: drop only the offending lines
if [[ -f "$FIXTURE_LOCATION/android/build.gradle" ]]; then
  sedi '/evaluationDependsOn/d' "$FIXTURE_LOCATION/android/build.gradle"
fi
if [[ -f "$FIXTURE_LOCATION/android/build.gradle.kts" ]]; then
  sedi '/evaluationDependsOn/d' "$FIXTURE_LOCATION/android/build.gradle.kts"
fi

echo "Gradle/AGP compatibility"
if ver_ge "$FLUTTER_VERSION" "3.38.0"; then
  echo "Flutter 3.38+: set Gradle wrapper to 8.13 (leave AGP as template provides)"
  sedi 's/gradle-[0-9.]*-all\.zip/gradle-8.13-all.zip/g' \
    "$FIXTURE_LOCATION/android/gradle/wrapper/gradle-wrapper.properties"
else
  echo "Older Flutter (<3.38): set Gradle wrapper to 8.7 and AGP to 8.3.0"
  sedi 's/gradle-[0-9.]*-all\.zip/gradle-8.7-all.zip/g' \
    "$FIXTURE_LOCATION/android/gradle/wrapper/gradle-wrapper.properties"

  if [[ -f "$FIXTURE_LOCATION/android/build.gradle" ]]; then
    sedi 's/com\.android\.tools\.build:gradle:[0-9.]\+/com.android.tools.build:gradle:8.3.0/g' \
      "$FIXTURE_LOCATION/android/build.gradle"
  fi

  if [[ -f "$FIXTURE_LOCATION/android/settings.gradle" ]]; then
    # Flutter templates vary; this catches the common plugins block line
    sedi 's/id "com\.android\.application" version "[0-9.]\+"/id "com.android.application" version "8.3.0"/g' \
      "$FIXTURE_LOCATION/android/settings.gradle"
  fi
fi

###############################################################################
# iOS: Podfile min platform + signing + ATS
###############################################################################
echo "Set iOS minimum platform to 12.0 in Podfile"
if [[ -f "$PODFILE" ]]; then
  sedi "s/# platform :ios, '11\.0'/platform :ios, '12.0'/g" "$PODFILE"
  # Some templates use different commented line; fall back to inserting if needed
  if ! grep -qE '^platform :ios, .12\.0.' "$PODFILE"; then
    # Insert near top
    sedi "1s|^|platform :ios, '12.0'\n|" "$PODFILE"
  fi
fi

echo "Add Development Team and code signing settings to Xcode project"
if [[ -f "$XCODE_PROJECT" ]]; then
  # Best-effort: add after ENABLE_BITCODE = NO; if present
  if grep -q 'ENABLE_BITCODE = NO;' "$XCODE_PROJECT"; then
    sedi "s/ENABLE_BITCODE = NO;/ENABLE_BITCODE = NO;\nDEVELOPMENT_TEAM = 7W9PZ27Y5F;\nCODE_SIGN_STYLE = Automatic;/g" "$XCODE_PROJECT"
  else
    echo "WARN: ENABLE_BITCODE = NO; not found in Xcode project; skipping signing inject" >&2
  fi
fi

echo "Allow cleartext (ATS) in Info.plist"
if [[ -f "$XCODE_PLIST" ]]; then
  # Insert ATS dict before CFBundleDevelopmentRegion (best-effort)
  if ! grep -q 'NSAppTransportSecurity' "$XCODE_PLIST"; then
    sedi "s/<key>CFBundleDevelopmentRegion<\/key>/<key>NSAppTransportSecurity<\/key><dict><key>NSAllowsArbitraryLoads<\/key><true\/><\/dict>\n<key>CFBundleDevelopmentRegion<\/key>/g" \
      "$XCODE_PLIST"
  fi
fi

###############################################################################
# Android Manifest: INTERNET + usesCleartextTraffic
###############################################################################
echo "Patch AndroidManifest.xml"

if [[ -f "$ANDROID_MANIFEST" ]]; then
  # Ensure INTERNET permission exists (prefer above <application>, but easiest: append near end if missing)
  if ! grep -q 'android.permission.INTERNET' "$ANDROID_MANIFEST"; then
    # Insert before closing </manifest> if present, else after </application> as your original did
    if grep -q '</manifest>' "$ANDROID_MANIFEST"; then
      sedi 's|</manifest>|<uses-permission android:name="android.permission.INTERNET"/>\n</manifest>|g' "$ANDROID_MANIFEST"
    else
      sedi 's|</application>|</application>\n<uses-permission android:name="android.permission.INTERNET"/>|g' "$ANDROID_MANIFEST"
    fi
  fi

  # Ensure usesCleartextTraffic is present on <application ...>
  if ! grep -q 'usesCleartextTraffic' "$ANDROID_MANIFEST"; then
    sedi 's|<application\([^>]*\)>|<application\1 android:usesCleartextTraffic="true">|g' "$ANDROID_MANIFEST"
  fi
else
  echo "WARN: AndroidManifest.xml not found at $ANDROID_MANIFEST" >&2
fi

###############################################################################
# Fetch deps once after all edits
###############################################################################
echo "Run pub get"
"${FLUTTER_BIN[@]}" pub get --directory="$FIXTURE_LOCATION"

###############################################################################
# Copy fixture Dart code
###############################################################################
echo "Copy test fixture code"
rm -rf "$DART_TEST_LOCATION"
rm -rf "$DART_LOCATION"

# Copy resources/lib into fixture root (creates lib/)
cp -r "$BS_DART_LOCATION" "$BS_DART_DESTINATION"

echo "Done: $FIXTURE_LOCATION"