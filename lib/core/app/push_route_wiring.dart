import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:n42_wallet/core/app/app_globals.dart';
import 'package:n42_wallet/features/browser/pages/browser_page.dart';
import 'package:n42_wallet/features/home/setting/about_app.dart';
import 'package:n42_wallet/features/home/setting/personal_setting.dart';
import 'package:n42_wallet/features/component/pages/setting_share.dart';
import 'package:n42_wallet/features/wallet/utils/browser/browser_txhash.dart';
import 'package:n42_wallet/shared/utils/push_route_registry.dart';

/// 宿主推送路由接线（composition root）。
///
/// 所有「点击推送 → 打开某个 feature 页面」的映射集中在此注册，
/// 使 `AppPushUtils`（features/utils）不需要 import 任何 feature 页面。
/// 在 main() 中、`AppPushUtils.init()` 之前调用。
void registerHostPushRoutes() {
  PushRouteRegistry.registerAll({
    'transfer': _openTxBrowser,
    'normal_transaction_failed': _openTxBrowser,
    'tell_friends': _openSettingShare,
    'Tell Friends #1_normal': _openSettingShare,
    'Tell Friends #2_normal': _openSettingShare,
    'AboutSettings_normal': (ctx, _) =>
        Navigator.push(ctx, MaterialPageRoute(builder: (_) => AboutApp())),
    'SettingsProfile_normal': (ctx, _) {
      if (AppGlobals.userInfo != null) {
        Navigator.push(
          ctx,
          MaterialPageRoute(builder: (_) => PersonalSetting()),
        );
      }
    },
  });
}

void _openSettingShare(BuildContext ctx, Map<String, dynamic> _) {
  Navigator.push(ctx, MaterialPageRoute(builder: (_) => SettingShare()));
}

/// 解析交易数据并跳转到浏览器查看交易详情
void _openTxBrowser(BuildContext ctx, Map<String, dynamic> data) {
  Map<String, dynamic> txContent = {};
  try {
    txContent = json.decode(data['data']);
  } catch (_) {
    // JSON 解析失败时使用空 map，安全忽略
  }
  String? isTestStr = txContent['network'];
  bool? isTest;
  if (isTestStr != null) {
    isTest = isTestStr == "test";
  }
  final String bUri = getSafeBrowserTxHashUrl(
    txContent['coin'],
    txContent['hash'],
    isTest: isTest,
  );
  if (bUri.isEmpty) return;
  Navigator.push(ctx, MaterialPageRoute(builder: (_) => BrowserPage(bUri)));
}
