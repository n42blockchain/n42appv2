//获取设备信息
import 'dart:io';
import 'dart:math';

import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoUtil{
  //手机名称、系统、手机型号
  Future<Map<String, dynamic>?> getDeviceInfo() async {
    try{
      Map<String,dynamic> rMap={};
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if(Platform.isAndroid){
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        rMap["mobileModel"]=androidInfo.version.release;//DataUtils.formatNum(double.parse(androidInfo.version.release), 1);
        rMap["mobileName"]=androidInfo.brand.toString().toLowerCase();
        rMap["os"]="android";
      }
      else{
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        rMap["mobileModel"]=DataUtils().formatNum(double.parse(iosInfo.systemVersion), 1);
        rMap["mobileName"]="Apple";
        rMap["os"]=iosInfo.systemName;
      }
      return rMap;
    }catch(e){
      return null;
    }
  }

  /// 获取或创建设备唯一标识
  /// 首次调用时生成 UUID v4 并持久化到 SecureStorage
  Future<String> getOrCreateDeviceId() async {
    final storage = SecureStorage();
    String? deviceId = await storage.getDeviceId();
    if (deviceId != null && deviceId.isNotEmpty) {
      return deviceId;
    }
    deviceId = _generateUuidV4();
    await storage.saveDeviceId(deviceId);
    return deviceId;
  }

  /// 获取完整设备信息（用于登录 API 传参）
  Future<Map<String, dynamic>> getFullDeviceInfo() async {
    final deviceId = await getOrCreateDeviceId();
    final info = await getDeviceInfo();
    return {
      'device_id': deviceId,
      'device_brand': info?['mobileName'] ?? '',
      'device_model': info?['mobileModel'] ?? '',
      'device_os': info?['os'] ?? (Platform.isAndroid ? 'android' : 'iOS'),
    };
  }

  /// 使用 dart:math 生成 UUID v4
  static String _generateUuidV4() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    // 设置版本号 (version 4)
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    // 设置变体 (variant 1)
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    String hex(int byte) => byte.toRadixString(16).padLeft(2, '0');
    return '${hex(bytes[0])}${hex(bytes[1])}${hex(bytes[2])}${hex(bytes[3])}-'
        '${hex(bytes[4])}${hex(bytes[5])}-'
        '${hex(bytes[6])}${hex(bytes[7])}-'
        '${hex(bytes[8])}${hex(bytes[9])}-'
        '${hex(bytes[10])}${hex(bytes[11])}${hex(bytes[12])}${hex(bytes[13])}${hex(bytes[14])}${hex(bytes[15])}';
  }
}
