import 'package:device_info/device_info.dart';
import 'dart:io';
import 'package:package_info/package_info.dart';
import 'package:bugsnag_flutter_performance/src/device_id_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ResourceAttributesProvider {
  Future<List<Map<String, Object>>> resourceAttributes();
}

class ResourceAttributesProviderImpl implements ResourceAttributesProvider {
  List<Map<String, Object>> _resourceAttributes = [];
  bool _didInitializeAttributes = false;
  final DeviceIdManager _deviceIdManager = DeviceIdManagerImp();

  @override
  Future<List<Map<String, Object>>> resourceAttributes() async {
    if (!_didInitializeAttributes) {
      await _initializeResourceAttributes();
      _didInitializeAttributes = true;
    }
    await _addNetworkStatus();
    return _resourceAttributes;
  }

  Future<void> _addNetworkStatus() async
  {
    String status = "unavailable";
    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      status = "cell";
    } else if (connectivityResult == ConnectivityResult.wifi) {
      status = "wifi";
    }

    Map<String, Object> networkStatusAttribute = {
      'key': 'net.host.connection.type',
      'value': {
        'stringValue': status,
      }
    };

    int existingIndex = _resourceAttributes.indexWhere((attr) => attr['key'] == 'net.host.connection.type');
    if (existingIndex != -1) {
      _resourceAttributes[existingIndex] = networkStatusAttribute;
    } else {
      _resourceAttributes.add(networkStatusAttribute);
    }
  }

  Future<void> _initializeResourceAttributes() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();

    final attributes = [
      {
        'key': 'deployment.environment',
        'value': {
          'stringValue': getDeploymentEnvironment(),
        }
      },
      {
        'key': 'telemetry.sdk.name',
        'value': {
          'stringValue': 'bugsnag.performance.flutter',
        }
      },
      {
        'key': 'telemetry.sdk.version',
        'value': {
          'stringValue': '0.0.1',
        }
      },
      {
        "key": "device.model.identifier",
        "value": {
          "stringValue": await getDeviceModel(deviceInfo),
        }
      },
      {
        "key": "service.version",
        "value": {
          "stringValue": packageInfo.version,
        }
      },
      {
        "key": "bugsnag.app.platform",
        "value": {
          "stringValue": Platform.operatingSystem,
        }
      },
      {
        "key": "device.manufacturer",
        "value": {
          "stringValue": await getDeviceManufacturer(deviceInfo),
        }
      },
      {
        "key": "host.arch",
        "value": {
          "stringValue": await getDeviceArchitecture(deviceInfo),
        }
      },
      {
        "key": "os.version",
        "value": {
          "stringValue": await getOSVersion(deviceInfo),
        }
      },
      {
        "key": Platform.isAndroid
            ? "bugsnag.app.version_code"
            : "bugsnag.app.bundle_version",
        "value": {
          "stringValue": packageInfo.buildNumber,
        }
      },
      {
        "key": "device.id",
        "value": {
          "stringValue": await _deviceIdManager.getDeviceId(),
        }
      }
    ];

    // Add Android-specific attributes
    if (Platform.isAndroid) {
      attributes.add({
        "key": "bugsnag.device.android_api_version",
        "value": {
          "stringValue": await getAndroidAPILevel(deviceInfo),
        }
      });
    }

    _resourceAttributes = attributes;
  }

  static Future<String> getDeviceModel(DeviceInfoPlugin deviceInfo) async {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.model;
    }
    return "Unknown";
  }

  static Future<String> getDeviceManufacturer(
      DeviceInfoPlugin deviceInfo) async {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.manufacturer;
    } else if (Platform.isIOS) {
      return "Apple";
    }
    return "Unknown";
  }

  static Future<String> getDeviceArchitecture(
      DeviceInfoPlugin deviceInfo) async {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.supportedAbis[0];
    } else if (Platform.isIOS) {
      return "arm64";
    }
    return "Unknown";
  }

  static String getDeploymentEnvironment() {
    final environment = Platform.environment['DEPLOYMENT_ENVIRONMENT'];
    return environment ?? 'development';
  }

  static Future<String> getAndroidAPILevel(DeviceInfoPlugin deviceInfo) async {
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt.toString();
  }

  static Future<String> getOSVersion(DeviceInfoPlugin deviceInfo) async {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.release;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.systemVersion;
    }
    return "Unknown";
  }
}
