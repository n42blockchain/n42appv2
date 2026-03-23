import 'dart:io';

import 'package:n42_wallet/features/mining_v1/api/mining_config.dart';
import 'package:n42_wallet/features/mining_v1/utils/mining_utils.dart';
import 'package:n42_wallet/core/storage/sp_util.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MiningCacheUtils{
  static Future<String?> getMiningCachePath() async {
    Directory? tempDir;
    if (Platform.isIOS) {
      tempDir = await getApplicationSupportDirectory();
    } else {
      if (await Permission.storage.status.isGranted) {
        tempDir = await getExternalStorageDirectory();
      } else {
        tempDir = await getApplicationDocumentsDirectory();
      }
    }
    return tempDir?.path;
  }



  /// 获取国家code
  /// CN(中国)
  static String? getCountryCode() {
    final List<Locale> systemLocales = WidgetsBinding.instance.platformDispatcher.locales;
    String? isoCountryCode = systemLocales.first.countryCode;
    debugPrint("isoCountryCode: $isoCountryCode");
    return isoCountryCode;
  }

  /// 从节点配置获取指定 key 的值（ipAddress / socket）
  static Future<String> _getNodeValue(String key) async {
    Map? nodeMap = await SPUtil().getCurrNodeAddress();
    String? address = nodeMap?[key];
    if (address != null && address.isNotEmpty) return address;
    final isMain = await MiningUtils.isMainChainMining();
    final List<Map> list = miningNodeMap[isMain ? "main" : "test"] as List<Map>;
    return list[0][key];
  }

  /// 获取当前节点IP
  static Future<String> getCurrentMiningNodeIp() async {
    final ip = await _getNodeValue('ipAddress');
    debugPrint("current mining node address ip: $ip");
    return ip;
  }

  /// 获取当前socket地址
  static Future<String> getCurrentSocketUrl() => _getNodeValue('socket');
}