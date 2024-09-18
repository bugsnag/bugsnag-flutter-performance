Changelog
=========

## 1.2.1 (2024-09-18)

### Bug fixes

* Fixed an exception thrown when no source of cryptographically secure random numbers is available [86](https://github.com/bugsnag/bugsnag-flutter-performance/pull/86)

## 1.2.0 (2024-09-13)

### Enhancements

* A fixed `samplingProbability` can now be set on `start` [78](https://github.com/bugsnag/bugsnag-flutter-performance/pull/78)

* `service.name` can now be set on `start` [80](https://github.com/bugsnag/bugsnag-flutter-performance/pull/80)

* Updated default url
  [81](https://github.com/bugsnag/bugsnag-flutter-performance/pull/81)

### Bug fixes

* Fixed PathNotFoundException thrown when retry queue flush is triggered multiple times [82](https://github.com/bugsnag/bugsnag-flutter-performance/pull/82)

* The correct package version is reported in the `telemetry.sdk.version` attribute [83](https://github.com/bugsnag/bugsnag-flutter-performance/pull/83)

## 1.1.0 (2024-08-14)

### Enhancements

* View load instrumentation
  [65](https://github.com/bugsnag/bugsnag-flutter-performance/pull/65)
  
* Replaced the dependency on `device_info` with the new `device_info_plus` package [72](https://github.com/bugsnag/bugsnag-flutter-performance/pull/72)
  
* Auto-inject traceparent headers into HTTP requests [73](https://github.com/bugsnag/bugsnag-flutter-performance/pull/73)

* Provide the correlation trace ID and span ID through `bugsnag_bridge` for `bugsnag_flutter` to add them to events [74](https://github.com/bugsnag/bugsnag-flutter-performance/pull/74)

### Bug fixes

* Fixed FormatException thrown when the data in sampling probability cache file is corrupted [75](https://github.com/bugsnag/bugsnag-flutter-performance/pull/75)

## 1.0.0 (2024-04-11)

Initial release
