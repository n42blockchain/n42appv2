import 'dart:io';
import 'dart:math';

import 'package:n42_wallet/core/security/secure_storage.dart';
import 'package:n42_wallet/features/utils/data_utils.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoUtil {
  Future<Map<String, dynamic>?> getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return {
          "mobileModel": androidInfo.version.release,
          "mobileName": androidInfo.brand.toString().toLowerCase(),
          "os": "android",
        };
      }
      final iosInfo = await deviceInfo.iosInfo;
      return {
        "mobileModel": DataUtils().formatNum(
          double.parse(iosInfo.systemVersion),
          1,
        ),
        "mobileName": "Apple",
        "os": iosInfo.systemName,
      };
    } catch (e) {
      return null;
    }
  }

  Future<String> getOrCreateDeviceId() async {
    final storage = SecureStorage();
    final deviceId = await storage.getDeviceId();
    if (deviceId != null && deviceId.isNotEmpty) return deviceId;

    final newId = _generateUuidV4();
    await storage.saveDeviceId(newId);
    return newId;
  }

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

  static String _generateUuidV4() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    String hex(int byte) => byte.toRadixString(16).padLeft(2, '0');
    return '${hex(bytes[0])}${hex(bytes[1])}${hex(bytes[2])}${hex(bytes[3])}-'
        '${hex(bytes[4])}${hex(bytes[5])}-'
        '${hex(bytes[6])}${hex(bytes[7])}-'
        '${hex(bytes[8])}${hex(bytes[9])}-'
        '${hex(bytes[10])}${hex(bytes[11])}${hex(bytes[12])}${hex(bytes[13])}${hex(bytes[14])}${hex(bytes[15])}';
  }
}
