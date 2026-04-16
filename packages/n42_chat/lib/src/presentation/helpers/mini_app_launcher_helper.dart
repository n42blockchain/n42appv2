import 'package:flutter/material.dart';

import '../../domain/entities/mini_app_entity.dart';
import '../pages/mini_app/mini_app_page.dart';

/// Mini App 查找与启动辅助，避免聊天页/扫码页重复维护同一套路由逻辑。
class MiniAppLauncherHelper {
  static const String shopAppId = 'n42_shop';
  static const String creatorPassAppId = 'creator_pass';

  static const List<String> _commerceQuickLaunchIds = [
    shopAppId,
    creatorPassAppId,
  ];

  static MiniAppEntity? findBuiltInAppById(String appId) {
    for (final app in BuiltInMiniApps.all) {
      if (app.id == appId) {
        return app;
      }
    }
    return null;
  }

  static List<MiniAppEntity> commerceQuickLaunchApps() {
    final apps = <MiniAppEntity>[];
    for (final appId in _commerceQuickLaunchIds) {
      final app = findBuiltInAppById(appId);
      if (app != null) {
        apps.add(app);
      }
    }
    return apps;
  }

  static Future<T?> openApp<T>(
    BuildContext context, {
    required MiniAppEntity app,
    required String roomId,
    String? initialUrl,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(
        builder: (_) =>
            MiniAppPage(app: app, roomId: roomId, initialUrl: initialUrl),
      ),
    );
  }

  static Future<bool> openBuiltInAppById(
    BuildContext context, {
    required String appId,
    required String roomId,
    String? initialUrl,
  }) async {
    final app = findBuiltInAppById(appId);
    if (app == null) {
      return false;
    }

    await openApp<void>(
      context,
      app: app,
      roomId: roomId,
      initialUrl: initialUrl,
    );
    return true;
  }
}
