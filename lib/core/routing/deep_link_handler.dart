import 'dart:async';

import '../../features/identity/services/id_hub_bind_signer.dart';
import '../platform/deep_link_service.dart';
import '../utils/app_logger.dart';

/// Deep Link 路由处理器
///
/// 监听 DeepLinkService 发出的事件并路由到对应页面
class DeepLinkHandler {
  final DeepLinkService _deepLinkService;
  StreamSubscription<DeepLinkData>? _subscription;

  /// 导航回调 - 由外部注入实际的导航逻辑
  void Function(DeepLinkData data)? onNavigate;

  DeepLinkHandler({required DeepLinkService deepLinkService})
    : _deepLinkService = deepLinkService;

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
    DeepLinkType.friendCard: 'userId',
  };

  void _handleDeepLink(DeepLinkData data) {
    AppLogger.d('DeepLinkHandler', 'handling deep link: $data');

    if (data.type == DeepLinkType.unknown) {
      AppLogger.w('DeepLinkHandler', 'unhandled deep link type: ${data.type}');
      return;
    }

    // 需要 ID 参数的类型先校验参数非空
    final requiredKey = _requiredParamKeys[data.type];
    if (requiredKey != null) {
      final value = data.params[requiredKey] ?? '';
      if (value.isEmpty) return;
      AppLogger.d('DeepLinkHandler', 'navigating to ${data.type.name} $value');
    }

    // walletConnect: 需要 wcUri 参数或 URI scheme 为 wc:
    if (data.type == DeepLinkType.walletConnect) {
      final wcUri = data.params['wcUri'] ?? '';
      final isWcScheme = data.uri.scheme == 'wc';
      if (wcUri.isEmpty && !isWcScheme) return;
    }

    // chatSso: 需要 loginToken / login_token / token 任一存在
    if (data.type == DeepLinkType.chatSso) {
      final hasToken =
          (data.params['loginToken'] ?? '').isNotEmpty ||
          (data.params['login_token'] ?? '').isNotEmpty ||
          (data.params['token'] ?? '').isNotEmpty;
      if (!hasToken) return;
    }

    // idHubBind/idHubAuth: require a session id and an allowlisted hub. This is
    // the anti-phishing gate - a QR whose hub is not on the allowlist is dropped
    // before any signing UI is shown.
    if (data.type == DeepLinkType.idHubBind ||
        data.type == DeepLinkType.idHubAuth) {
      final sid = data.params['sid'] ?? '';
      final hub = data.params['hub'] ?? '';
      if (!IdHubBindSigner.isValidSessionId(sid) ||
          !IdHubBindSigner.isHubAllowed(hub)) {
        AppLogger.w('DeepLinkHandler', 'rejected id-hub link: bad sid/hub');
        return;
      }
    }

    try {
      onNavigate?.call(data);
    } catch (e, s) {
      AppLogger.e(
        'DeepLinkHandler',
        'navigation callback error',
        error: e,
        stackTrace: s,
      );
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
