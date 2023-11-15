import 'dart:convert';
import 'dart:io';
import 'package:package_info/package_info.dart';
import 'package:uuid/uuid.dart';

import 'package:path_provider/path_provider.dart';

class AndroidDeviceIdModel {
  String id;
  AndroidDeviceIdModel({required this.id});
  factory AndroidDeviceIdModel.fromJson(Map<String, dynamic> json) {
    return AndroidDeviceIdModel(id: json['id']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

class IosDeviceIdModel {
  String deviceID;
  IosDeviceIdModel({required this.deviceID});
  factory IosDeviceIdModel.fromJson(Map<String, dynamic> json) {
    return IosDeviceIdModel(deviceID: json['deviceID']);
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceID': deviceID,
    };
  }
}

class DeviceIdManager {
  static const String _androidDeviceIdFileName = "/device-id";
  static String _androidDeviceIdFilePath = "";

  static const String _iosDeviceIdFileName = "/device-id.json";
  static String _iosDeviceIdFilePath = "";

  static Future<String> getDeviceId() async {
    String deviceId = await readDeviceIdFile();
    if (deviceId.isEmpty) {
      await createNewDeviceId();
      deviceId = await readDeviceIdFile();
    }
    return deviceId;
  }

  static Future<String> getAndroidDeviceIdFilePath() async {
    if (_androidDeviceIdFilePath.isNotEmpty) {
      return _androidDeviceIdFilePath;
    }
    final directory = await getApplicationSupportDirectory();
    _androidDeviceIdFilePath = directory.path + _androidDeviceIdFileName;
    return _androidDeviceIdFilePath;
  }

  static Future<String> getIosDeviceIdFilePath() async {
    if (_iosDeviceIdFilePath.isNotEmpty) {
      return _iosDeviceIdFilePath;
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final directory = await getApplicationSupportDirectory();
    _iosDeviceIdFilePath =
        "${directory.path}/bugsnag-shared-${packageInfo.packageName}$_iosDeviceIdFileName";
    return _iosDeviceIdFilePath;
  }

  static Future<String> getDeviceIdFilePath() async {
    if (Platform.isAndroid) {
      return await getAndroidDeviceIdFilePath();
    } else if (Platform.isIOS) {
      return await getIosDeviceIdFilePath();
    }
    return "";
  }

  static Future<String> readDeviceIdFile() async {
    try {
      final path = await getDeviceIdFilePath();
      final file = File(path);
      bool fileExists = await file.exists();

      if (!fileExists) {
        return "";
      }

      final fileContents = await file.readAsString();

      return fileContents.isEmpty ? "" : getDeviceIdFromJson(fileContents);
    } catch (e) {
      return "";
    }
  }

  static String getDeviceIdFromJson(String json) {
    Map<String, dynamic> jsonMap = jsonDecode(json);
    if (Platform.isIOS) {
      return IosDeviceIdModel.fromJson(jsonMap).deviceID;
    } else if (Platform.isAndroid) {
      return AndroidDeviceIdModel.fromJson(jsonMap).id;
    }
    return "";
  }

  static String generateNewDeviceId() {
    return const Uuid().v4().replaceAll("-", "");
  }

  static Future<void> createNewDeviceId() async {
    final deviceId = generateNewDeviceId();
    final deviceModel = Platform.isAndroid
        ? AndroidDeviceIdModel(id: deviceId)
        : IosDeviceIdModel(deviceID: deviceId);
    try {
      final json = jsonEncode(deviceModel);
      await writeDeviceIdFile(json);
    } catch (e) {
      print('Error encoding JSON: $e');
    }
  }

  static Future<void> writeDeviceIdFile(String json) async {
    final path = await getDeviceIdFilePath();
    final file = File(path);
    await file.writeAsString(json);
  }
}
