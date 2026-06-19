// N42 Live —— 独立直播 App 入口（开发期：flutter run -t lib/main_live.dart）
//
// 与主钱包 App 同仓，复用 core/themes/l10n 与 n42_chat（Matrix 弹幕 + 自部署
// LiveKit 直播底座）。功能成熟后再合入主 App 底部 tab。

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/features/live/presentation/pages/live_app.dart';
import 'package:n42_wallet/features/live/services/live_bootstrap.dart';

/// 独立直播 App 的全局 ProviderContainer（供非 widget 消费者使用）。
late ProviderContainer liveProviderContainer;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 直播客户端仅竖屏（抖音式全屏直播间）。
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Firebase 用于 n42_chat 推送/崩溃上报；MVP 不强依赖，失败则继续。
  try {
    await Firebase.initializeApp();
  } catch (e) {
    AppLogger.w('main_live', 'Firebase init failed (continuing): $e');
  }

  liveProviderContainer = ProviderContainer();

  // 后台初始化 n42_chat（Matrix）——弹幕通道 + LiveKit 配置发现来源。
  // 不阻塞首帧；房间页会再次 await ensureLiveChatReady() 确保就绪后再进房。
  unawaited(
    ensureLiveChatReady()
        .then((_) => AppLogger.i('main_live', 'N42Chat ready for live client'))
        .catchError(
          (Object e) => AppLogger.e('main_live', 'N42Chat init failed: $e'),
        ),
  );

  runApp(
    UncontrolledProviderScope(
      container: liveProviderContainer,
      child: const LiveApp(),
    ),
  );
}
