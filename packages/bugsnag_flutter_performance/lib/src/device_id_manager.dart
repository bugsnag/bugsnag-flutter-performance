import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';

import 'package:path_provider/path_provider.dart';

class DeviceIdModel {
  String id;

  DeviceIdModel({required this.id});

  factory DeviceIdModel.fromJson(Map<String, dynamic> json) {
    return DeviceIdModel(id: json['id']);
  }
}

class DeviceIdManager {

  static const String _androidDeviceIdFileName = "/device-id";
  static String _androidDeviceIdFilePath = "";

  static const String _iosDeviceIdFileName = "/device-id";
  static String _iosDeviceIdFilePath = "";

  static Future<String> getDeviceId() async {
    String deviceId = await readDeviceIdFile();
    if(deviceId.isEmpty) {
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

    final directory = await getApplicationSupportDirectory();
    _iosDeviceIdFilePath = directory.path + _iosDeviceIdFileName;
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
    return DeviceIdModel.fromJson(jsonMap).id;
  }

  static Future<void> createNewDeviceId() async {
    final deviceId = Uuid().v4();
    final deviceModel = DeviceIdModel(id: deviceId);
    final json = jsonEncode(deviceModel);
    await writeDeviceIdFile(json);
  }

  static Future<void> writeDeviceIdFile(String json) async {
    final path = await getDeviceIdFilePath();
    final file = File(path);
    await file.writeAsString(json);
  }

}