# Developer Guide

Everything a new developer needs to know to work on **bugsnag-flutter-performance**.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Repository Layout](#repository-layout)
4. [Prerequisites](#prerequisites)
5. [Initial Setup](#initial-setup)
6. [Building the Project](#building-the-project)
7. [Running Tests](#running-tests)
8. [Code Quality](#code-quality)
9. [Key Source Files](#key-source-files)
10. [End-to-End Tests](#end-to-end-tests)
11. [Example App](#example-app)
12. [Release Process](#release-process)

---

## Project Overview

`bugsnag-flutter-performance` is a [pub.dev](https://pub.dev) Flutter package that monitors the performance of Flutter apps running on iOS and Android. It collects **spans** (timed operations) for events such as:

- App start-up time
- Screen navigation / view load times
- HTTP network requests (`http`, `dart:io`, `dio`)
- Custom spans defined by the host application

Spans are batched and sent to the [BugSnag](https://www.bugsnag.com) ingestion endpoint in [OpenTelemetry](https://opentelemetry.io) format.

The public integration guide lives at: <https://docs.bugsnag.com/performance/integration-guides/flutter/>

---

## Architecture

The SDK is **pure Dart/Flutter** — there is no native (Kotlin/Swift) code in the main package itself. Native functionality (e.g. device info) is accessed through published Dart packages (`device_info_plus`, `package_info_plus`, etc.) and through the internal `bugsnag_bridge` package.

High-level data flow:

```
Host app (Flutter)
       │
       ▼
BugsnagPerformance (public API singleton)
       │
       ▼
Client ──► Instrumentation (app start / navigation / view load / network)
       │
       ▼
Span  ──► SpanAttributes ──► SpanControl (per-span customisation hooks)
       │
       ▼
SpanBatch ──► Uploader (HTTP POST to ingestion endpoint)
                  │
                  └──► RetryQueue (persists failed batches to disk)
```

Key sub-systems:

| Sub-system | Location | Purpose |
|---|---|---|
| Public API | `lib/bugsnag_flutter_performance.dart` | Singleton entry-point exposed to host apps |
| Client | `lib/src/client.dart` | Coordinates span lifecycle, batching, upload |
| Configuration | `lib/src/configuration.dart` | All user-configurable options |
| Span | `lib/src/span.dart` | Core span class; start/end lifecycle |
| SpanAttributes | `lib/src/span_attributes.dart` | Key/value metadata attached to spans |
| SpanContext | `lib/src/span_context.dart` | OpenTelemetry trace/span ID container |
| Instrumentation | `lib/src/instrumentation/` | Auto-capture: app start, navigation, view load |
| SpanControl | `lib/src/span_control/` | Allow apps to mutate spans before upload |
| Uploader | `lib/src/uploader/` | Batch serialisation, HTTP upload, retry logic |
| DeviceIdManager | `lib/src/device_id_manager.dart` | Generate and persist a stable device ID |
| Widgets | `lib/src/widgets/` | Flutter widgets (e.g. `BugsnagPerformanceNavigationContainer`) |
| Extensions | `lib/src/extensions/` | Internal Dart extension methods and resource attributes |

---

## Repository Layout

```
bugsnag-flutter-performance/
├── .buildkite/                   # Buildkite CI pipeline definition
├── .github/                      # PR / issue templates and support docs
├── docs/                         # Developer documentation (this file)
├── example/                      # Standalone example Flutter application
│   └── bugsnag_performance_example/
├── features/                     # End-to-end (Maze Runner) test suite
│   ├── *.feature                 # Cucumber feature files
│   ├── fixture_resources/        # Dart code shared by E2E fixtures
│   ├── scripts/                  # Shell scripts to build test fixtures
│   ├── steps/                    # Cucumber step definitions (Ruby)
│   └── support/                  # Maze Runner support files
├── packages/
│   ├── bugsnag_flutter_performance/  # ← Main SDK package
│   │   ├── lib/
│   │   │   ├── bugsnag_flutter_performance.dart  # Public API
│   │   │   └── src/              # Private implementation
│   │   ├── test/                 # Unit tests
│   │   ├── pubspec.yaml
│   │   └── analysis_options.yaml
│   └── bugsnag-flutter-common/   # Git submodule – shared utilities
├── CHANGELOG.md
├── CONTRIBUTING.md
├── Gemfile                       # Ruby gems (CocoaPods, Maze Runner)
├── Makefile                      # Build automation (see below)
├── VERSION                       # Current SDK version string
└── docker-compose.yml            # Maze Runner E2E test environment
```

---

## Prerequisites

| Tool | Minimum version | Notes |
|---|---|---|
| Flutter SDK | 3.24.0 | Dart SDK ≥ 3.5.0 is bundled |
| Xcode | 26.1.1 | Required for iOS builds |
| Java | 17 | Required for Android builds |
| Ruby | system | Required for `bundle install` (CocoaPods, Maze Runner) |
| Docker & Docker Compose | any recent | Required for local E2E testing only |

Check your Flutter version:
```bash
flutter --version
```

---

## Initial Setup

```bash
# 1. Clone the repository (with submodules)
git clone --recurse-submodules https://github.com/bugsnag/bugsnag-flutter-performance.git
cd bugsnag-flutter-performance

# 2. If you already cloned without --recurse-submodules, initialise the submodule
git submodule update --init --recursive

# 3. Install Ruby gems (CocoaPods + Maze Runner for E2E testing)
bundle install

# 4. Fetch Flutter dependencies for the SDK package
cd packages/bugsnag_flutter_performance && flutter pub get && cd ../..

# 5. Fetch Flutter dependencies for the example app
cd example/bugsnag_performance_example && flutter pub get && cd ../..
```

All subsequent build/test commands can be run through the `Makefile` from the repository root.

---

## Building the Project

The `Makefile` provides all common workflows. You can override the Flutter binary with `FLUTTER_BIN=<path>`.

```bash
# Format → build → lint → test (full validation, same as CI)
make all

# Build only
make build                          # Android AAR + example iOS & Android

# Build Android AAR only
make aar

# Build the example app only (APK + unsigned iOS)
make example/bugsnag_performance_example

# Remove all build artefacts and generated files
make clean
```

### Manual Flutter commands

```bash
# Android AAR
cd packages/bugsnag_flutter_performance
flutter build aar --suppress-analytics

# iOS (unsigned)
cd example/bugsnag_performance_example
flutter build ios --no-codesign --suppress-analytics --no-tree-shake-icons
```

---

## Running Tests

### Unit tests

```bash
make test
# Equivalent to:
cd packages/bugsnag_flutter_performance && flutter test -r expanded --suppress-analytics
```

Test files live in `packages/bugsnag_flutter_performance/test/src/`:

| File | What it covers |
|---|---|
| `client_test.dart` | Core client span lifecycle |
| `span_test.dart` | Span creation and attribute management |
| `span_context_test.dart` | OpenTelemetry trace/span IDs |
| `endpoint_test.dart` | Endpoint URL construction |
| `uploader/span_batch_test.dart` | Batch serialisation |
| `uploader/retry_queue_test.dart` | Disk-based retry queue |

When adding new functionality, add a corresponding test file in the same directory following the existing patterns.

### End-to-end tests

E2E tests are run in CI via Buildkite on real devices (Bitbar cloud). Locally they require Docker:

```bash
# Build the Android test fixture first
bash features/scripts/build_android_app.sh

# Then run Maze Runner (requires Docker + Bugsnag API key / maze-runner credentials)
bundle exec maze-runner --app=<path-to-apk> features/<feature>.feature
```

See the [End-to-End Tests](#end-to-end-tests) section for more detail.

---

## Code Quality

### Formatting

Dart code must be formatted with `dart format` before committing.

```bash
make format
# Equivalent to:
dart format packages/bugsnag_flutter_performance example features/fixture_resources/lib
```

### Linting

```bash
make lint
# Equivalent to:
cd packages/bugsnag_flutter_performance && flutter analyze --suppress-analytics
```

Lint rules are defined in `packages/bugsnag_flutter_performance/analysis_options.yaml` which extends `package:flutter_lints/flutter.yaml`. No additional custom rules are applied.

CI will fail if either formatting or linting produces any output, so always run both before opening a PR.

---

## Key Source Files

### Public API

`lib/bugsnag_flutter_performance.dart` — the single import that host apps use. Exposes:
- `BugsnagPerformance.start(config)` — initialise the SDK
- `BugsnagPerformance.startSpan(name)` — begin a custom span
- Navigation observer and network request wrappers

### `lib/src/client.dart`

The central coordinator. Responsibilities:
- Owns the current sampling probability
- Manages the span queue and batching timer
- Calls instrumentation sub-systems on startup
- Delegates to the `Uploader` for network delivery

### `lib/src/configuration.dart`

All user-facing configuration options (API key, endpoint URL, release stage, sampling, attribute limits, callbacks, etc.). Extend this file when adding a new configuration option.

### `lib/src/span.dart` & `lib/src/span_attributes.dart`

`Span` tracks a timed operation: start timestamp, end timestamp, name, kind, and a map of typed attributes. `SpanAttributes` enforces the configurable limits on attribute count and string length.

### `lib/src/instrumentation/`

Three auto-instrumentation sub-systems:

| Directory | What it instruments |
|---|---|
| `app_start/` | Time between process launch and first frame |
| `navigation/` | Flutter route push/pop events |
| `view_load/` | Widget build and layout time |

### `lib/src/span_control/`

Before a span is included in an upload batch, every registered `SpanControlProvider` is called and can modify or discard the span. Host apps can register their own providers via `BugsnagPerformance.addSpanControlProvider(...)`.

### `lib/src/uploader/`

Handles span serialisation (JSON in OpenTelemetry format), HTTP POSTing to the configured endpoint, sampling-probability header parsing, and persistent retry on failure (`RetryQueue` writes batches to the device's application support directory).

### `lib/src/extensions/resource_attributes.dart`

Collects static device/app metadata (OS version, device model, service name, SDK version, etc.) sent as OTLP resource attributes with every batch. The SDK version string is hardcoded here and updated automatically by `make bump`.

---

## End-to-End Tests

E2E tests use [Maze Runner](https://github.com/bugsnag/maze-runner), a BugSnag-internal Cucumber framework. They exercise real device behaviour on iOS and Android.

### Structure

```
features/
├── *.feature              # Cucumber scenarios (one file per feature area)
├── fixture_resources/lib/ # Dart code used by the test fixture app
├── scripts/               # build_ios_app.sh, build_android_app.sh
├── steps/                 # Ruby step definitions
└── support/               # Maze Runner hooks and helpers
```

### Feature files

Each `.feature` file corresponds to a testable area:

| Feature file | Area |
|---|---|
| `automatic_spans.feature` | App start, navigation, view load auto-instrumentation |
| `manual_span.feature` | Custom span API |
| `network_spans.feature` | HTTP network instrumentation |
| `nested_spans.feature` | Parent/child span relationships |
| `configuration.feature` | Configuration options |
| `correlation.feature` | Trace context propagation |
| `span_control.feature` | SpanControl callbacks |
| `persistence.feature` | Retry queue persistence |
| `resource_attributes.feature` | OTLP resource attribute values |
| `initial-p-value.feature` | Initial sampling probability |

### CI matrix

The Buildkite pipeline tests against:
- **Flutter versions**: 3.24.4 and latest stable
- **iOS**: 17, 18, 26
- **Android**: 13, 14, 15, 16

---

## Example App

`example/bugsnag_performance_example/` is a minimal Flutter app that imports the SDK. It is used:

1. During development, to manually test changes on a simulator/device
2. As the test fixture app for E2E tests (via `features/scripts/`)

To run it locally:

```bash
cd example/bugsnag_performance_example
flutter pub get
flutter run   # requires a connected device or running simulator
```

---

## Release Process

### Versioning

The SDK version is stored in `VERSION` (plain text) and mirrored in:
- `packages/bugsnag_flutter_performance/pubspec.yaml` (`version:`)
- `packages/bugsnag_flutter_performance/lib/src/extensions/resource_attributes.dart` (`_getSDKVersion`)

Never edit these manually — use:

```bash
make VERSION=<x.y.z> bump
```

### Step-by-step release

1. **Create a release branch** from `next`:
   ```bash
   git checkout next && git pull
   git checkout -b releases/v<version>
   ```

2. **Bump the version** and inspect the result:
   ```bash
   make VERSION=<version> bump
   # Review: CHANGELOG.md, pubspec.yaml, resource_attributes.dart, VERSION
   ```

3. **Open a PR** from `releases/v<version>` → `main` and wait for CI to pass.

4. **After the PR is merged**, pull `main` and create the pub.dev staging directory:
   ```bash
   git checkout main && git pull
   git clean -df
   make stage
   ```

5. **Dry-run publish** to catch any issues:
   ```bash
   make publish_dry
   ```

6. **Publish to pub.dev**:
   ```bash
   cd staging/bugsnag_flutter_performance && flutter pub publish
   ```

7. **Tag the release** and create the GitHub Release at
   <https://github.com/bugsnag/bugsnag-flutter-performance/releases>:
   ```bash
   make release
   ```
   This also merges `main` into `next`.

8. **Merge any outstanding documentation PRs** related to the release.

> **Tip:** The `make prerelease VERSION=<x.y.z>` target automates steps 1–3 (bump, stage, dry-run, create branch, open PR) in a single command.
