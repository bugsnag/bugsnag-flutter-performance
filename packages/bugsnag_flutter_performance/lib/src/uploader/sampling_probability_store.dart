import 'dart:convert';
import 'dart:io';

import 'package:bugsnag_flutter_performance/src/util/clock.dart';
import 'package:path_provider/path_provider.dart';

abstract class SamplingProbabilityStore {
  Future<double?> get samplingProbability;
  Future<void> store(
    double samplingProbability,
    DateTime expireDate,
  );
}

class SamplingProbabilityStoreImpl implements SamplingProbabilityStore {
  static const String _cacheDirectoryName = 'bugsnag-performance/v1/sampling';
  static const String _fileName = 'samplingProbability.json';

  final BugsnagClock clock;

  double? _samplingProbability;
  DateTime? _expireDate;
  var _isInitialized = false;

  SamplingProbabilityStoreImpl(this.clock);

  @override
  Future<double?> get samplingProbability async {
    await _initializeIfNeeded();
    if (_expireDate != null && _expireDate!.isBefore(clock.now())) {
      return null;
    }
    return _samplingProbability;
  }

  @override
  Future<void> store(
    double samplingProbability,
    DateTime expireDate,
  ) async {
    await _initializeIfNeeded();
    if (_samplingProbability != null &&
        _samplingProbability! < samplingProbability) {
      return;
    }
    _samplingProbability = samplingProbability;
    _expireDate = expireDate;
    _writeToFile(samplingProbability, expireDate);
  }

  Future<void> _initializeIfNeeded() async {
    if (_isInitialized) {
      return;
    }
    final file = await _getFile();
    if (file.existsSync()) {
      final content = jsonDecode(await file.readAsString());
      final expireDate = DateTime.tryParse(content['expireDate']);
      if (expireDate != null && expireDate.isAfter(clock.now())) {
        _samplingProbability = double.tryParse(content['value']);
        _expireDate = expireDate;
      }
    }

    _isInitialized = true;
  }

  Future<void> _writeToFile(
    double samplingProbability,
    DateTime expireDate,
  ) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode({
      'value': samplingProbability.toString(),
      'expireDate': expireDate.toIso8601String(),
    }));
  }

  Future<File> _getFile() async {
    final cacheDirectory = await _getCacheDirectory();
    if (!cacheDirectory.existsSync()) {
      cacheDirectory.createSync(recursive: true);
    }
    return File('${cacheDirectory.path}/$_fileName');
  }

  Future<Directory> _getCacheDirectory() async {
    final appCacheDir = await getApplicationSupportDirectory();
    return Directory('${appCacheDir.path}/$_cacheDirectoryName');
  }
}
