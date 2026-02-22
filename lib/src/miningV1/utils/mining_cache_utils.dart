import 'dart:io';

import 'package:n42appv2/src/miningV1/api/mining_config.dart';
import 'package:n42appv2/src/miningV1/utils/mining_utils.dart';
import 'package:n42appv2/core/storage/sp_util.dart';
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
    final List<Locale> systemLocales = WidgetsBinding.instance.window.locales;
    String? isoCountryCode = systemLocales.first.countryCode;
    debugPrint("isoCountryCode: $isoCountryCode");
    return isoCountryCode;
  }

  /// 获取当前节点IP
  static Future<String> getCurrentMiningNodeIp() async {
    Map? nodeMap = await SPUtil().getCurrNodeAddress();
    String? address = nodeMap?['ipAddress'];
    debugPrint("current mining node address ip: $address");
    if (address != null && address.isNotEmpty) return address;
    late String astServiceUrl;
    if (await MiningUtils.isMainChainMining()) {
      List<Map> list = miningNodeMap["main"] as List<Map>;
      astServiceUrl = list[0]["ipAddress"];
    } else {
      List<Map> list = miningNodeMap["test"] as List<Map>;
      astServiceUrl = list[0]["ipAddress"];
    }
    return astServiceUrl;
  }


  /// 获取当前socket地址
  static Future<String> getCurrentSocketUrl() async {
    Map? nodeMap = await SPUtil().getCurrNodeAddress();
    String? address = nodeMap?['socket'];
    if (address != null && address.isNotEmpty) return address;
    late String astServiceUrl;
    if (await MiningUtils.isMainChainMining()) {
      List<Map> list = miningNodeMap["main"] as List<Map>;
      astServiceUrl = list[0]["socket"];
    } else {
      List<Map> list = miningNodeMap["test"] as List<Map>;
      astServiceUrl = list[0]["socket"];
    }
    return astServiceUrl;
  }
}