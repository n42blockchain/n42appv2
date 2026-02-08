import 'dart:async';

import 'package:flutter/foundation.dart';

import '../platform/deep_link_service.dart';

/// Deep Link 路由处理器
///
/// 监听 DeepLinkService 发出的事件并路由到对应页面
class DeepLinkHandler {
  final DeepLinkService _deepLinkService;
  StreamSubscription<DeepLinkData>? _subscription;

  /// 导航回调 - 由外部注入实际的导航逻辑
  void Function(DeepLinkData data)? onNavigate;

  DeepLinkHandler({
    required DeepLinkService deepLinkService,
  }) : _deepLinkService = deepLinkService;

  /// 开始监听 deep links
  void startListening() {
    _subscription?.cancel();
    _subscription = _deepLinkService.deepLinkStream.listen(_handleDeepLink);

    // 处理启动时的 deep link
    final initial = _deepLinkService.lastDeepLink;
    if (initial != null) {
      _handleDeepLink(initial);
      _deepLinkService.clearLastDeepLink();
    }
  }

  /// 需要 ID 参数校验的类型及对应参数名
  static const _requiredParamKeys = {
    DeepLinkType.chat: 'roomId',
    DeepLinkType.user: 'userId',
    DeepLinkType.group: 'groupId',
  };

  void _handleDeepLink(DeepLinkData data) {
    debugPrint('DeepLinkHandler: Handling deep link: $data');

    if (data.type == DeepLinkType.unknown) {
      debugPrint('DeepLinkHandler: Unhandled deep link type: ${data.type}');
      return;
    }

    // 需要 ID 参数的类型先校验参数非空
    final requiredKey = _requiredParamKeys[data.type];
    if (requiredKey != null) {
      final value = data.params[requiredKey] ?? '';
      if (value.isEmpty) return;
      debugPrint('DeepLinkHandler: Navigating to ${data.type.name} $value');
    }

    try {
      onNavigate?.call(data);
    } catch (e) {
      debugPrint('DeepLinkHandler: Navigation callback error: $e');
    }
  }

  /// 生成分享链接
  static String generateChatLink(String roomId) {
    return 'n42://chat/$roomId';
  }

  static String generateUserLink(String userId) {
    return 'n42://user/$userId';
  }

  static String generateGroupLink(String groupId) {
    return 'n42://group/$groupId';
  }

  /// 停止监听
  void dispose() {
    _subscription?.cancel();
  }
}
