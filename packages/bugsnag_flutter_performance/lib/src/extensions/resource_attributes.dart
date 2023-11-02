import 'package:device_info/device_info.dart';
import 'dart:io';
import 'package:package_info/package_info.dart';

class ResourceAttributes {
  static List<Map<String, Object>> resourceAttributes = [];

  static Future<void> initializeResourceAttributes() async {
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
      }
      // {
      //   "key": "device.id",
      //   "value": {
      //     "stringValue": GET FROM PERSISTENCE LAYER
      //   }
      // }
      // TODO add device.id once persistence is added
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

    resourceAttributes = attributes;
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
