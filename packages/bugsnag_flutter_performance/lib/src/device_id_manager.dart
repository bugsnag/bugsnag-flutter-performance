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
    return {'id': id};
  }
}

class IosDeviceIdModel {
  String deviceID;

  IosDeviceIdModel({required this.deviceID});

  factory IosDeviceIdModel.fromJson(Map<String, dynamic> json) {
    return IosDeviceIdModel(deviceID: json['deviceID']);
  }

  Map<String, dynamic> toJson() {
    return {'deviceID': deviceID};
  }
}

abstract class DeviceIdManager {
  Future<String> getDeviceId();
}

class DeviceIdManagerImp extends DeviceIdManager {
  final String _androidDeviceIdFileName = '/device-id';
  final String _iosDeviceIdFileName = '/device-id.json';
  String _androidDeviceIdFilePath = '';
  String _iosDeviceIdFilePath = '';

  @override
  Future<String> getDeviceId() async {
    String deviceId = await _readDeviceIdFile();
    if (deviceId.isEmpty) {
      await _createNewDeviceId();
      deviceId = await _readDeviceIdFile();
    }
    return deviceId;
  }

  Future<String> _getDeviceIdFilePath() async {
    if (Platform.isAndroid) {
      return await _getAndroidDeviceIdFilePath();
    } else if (Platform.isIOS) {
      return await _getIosDeviceIdFilePath();
    }
    return '';
  }

  Future<String> _getAndroidDeviceIdFilePath() async {
    if (_androidDeviceIdFilePath.isNotEmpty) {
      return _androidDeviceIdFilePath;
    }
    final directory = await getApplicationSupportDirectory();
    _androidDeviceIdFilePath = directory.path + _androidDeviceIdFileName;
    return _androidDeviceIdFilePath;
  }

  Future<String> _getIosDeviceIdFilePath() async {
    if (_iosDeviceIdFilePath.isNotEmpty) {
      return _iosDeviceIdFilePath;
    }
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final directory = await getApplicationSupportDirectory();
    _iosDeviceIdFilePath =
        '${directory.path}/bugsnag-shared-${packageInfo.packageName}$_iosDeviceIdFileName';
    return _iosDeviceIdFilePath;
  }

  Future<String> _readDeviceIdFile() async {
    try {
      final path = await _getDeviceIdFilePath();
      final file = File(path);
      bool fileExists = await file.exists();

      if (!fileExists) {
        return '';
      }

      final fileContents = await file.readAsString();

      return fileContents.isEmpty ? '' : _getDeviceIdFromJson(fileContents);
    } catch (e) {
      //print('Error reading device ID file: $e');
      return '';
    }
  }

  String _getDeviceIdFromJson(String json) {
    try {
      Map<String, dynamic> jsonMap = jsonDecode(json);
      if (Platform.isIOS) {
        return IosDeviceIdModel.fromJson(jsonMap).deviceID;
      } else if (Platform.isAndroid) {
        return AndroidDeviceIdModel.fromJson(jsonMap).id;
      }
      return '';
    } catch (e) {
      //print('Error decoding JSON: $e');
      return '';
    }
  }

  String _generateNewDeviceId() {
    return const Uuid().v4().replaceAll('-', '');
  }

  Future<void> _createNewDeviceId() async {
    final deviceId = _generateNewDeviceId();
    final deviceModel = Platform.isAndroid
        ? AndroidDeviceIdModel(id: deviceId)
        : IosDeviceIdModel(deviceID: deviceId);
    try {
      final json = jsonEncode(deviceModel);
      await _writeDeviceIdFile(json);
    } catch (e) {
      //print('Error encoding JSON: $e');
    }
  }

  Future<void> _writeDeviceIdFile(String json) async {
    try {
      final path = await _getDeviceIdFilePath();
      final file = File(path);

      // Create directory if it doesn't exist
      final directory = Directory(file.parent.path);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      await file.writeAsString(json);
    } catch (e) {
      //print('Error writing device ID file: $e');
    }
  }
}
