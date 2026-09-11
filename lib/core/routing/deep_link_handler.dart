import 'dart:async';

import '../../features/identity/services/id_hub_bind_signer.dart';
import '../platform/deep_link_service.dart';
import '../utils/app_logger.dart';
import '../../shared/utils/wallet_connect_uri.dart';

/// Deep Link 路由处理器
///
/// 监听 DeepLinkService 发出的事件并路由到对应页面
class DeepLinkHandler {
  final DeepLinkService _deepLinkService;
  StreamSubscription<DeepLinkData>? _subscription;

  /// 导航回调 - 由外部注入实际的导航逻辑
  FutureOr<void> Function(DeepLinkData data)? onNavigate;

  /// The host resumes the latest pending intent once its navigator is ready.
  bool Function()? canNavigate;
  DeepLinkData? _pending;
  final Set<Uri> _activeUris = {};
  bool _disposed = false;

  DeepLinkHandler({required DeepLinkService deepLinkService})
    : _deepLinkService = deepLinkService;

  /// 开始监听 deep links
  void startListening() {
    if (_disposed) return;
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
    DeepLinkType.groupMining: 'groupId',
  };

  void _handleDeepLink(DeepLinkData data) {
    if (_disposed) return;
    if (identical(_deepLinkService.lastDeepLink, data)) {
      _deepLinkService.clearLastDeepLink();
    }
    AppLogger.d('DeepLinkHandler', 'handling type: ${data.type.name}');

    if (data.type == DeepLinkType.unknown) {
      AppLogger.w('DeepLinkHandler', 'unhandled deep link type: ${data.type}');
      return;
    }

    // 需要 ID 参数的类型先校验参数非空
    final requiredKey = _requiredParamKeys[data.type];
    if (requiredKey != null) {
      final value = data.params[requiredKey] ?? '';
      if (!DeepLinkService.isValidTargetId(value)) return;
    }

    // Validate both parsed events and manually supplied handler events.
    if (data.type == DeepLinkType.walletConnect) {
      final wcUri = data.params['wcUri'] ?? data.uri.toString();
      if (parseWalletConnectUri(wcUri) == null) return;
    }

    // chatSso: 需要 loginToken / login_token / token 任一存在
    if (data.type == DeepLinkType.chatSso) {
      final tokens = ['loginToken', 'login_token', 'token']
          .map((key) => data.params[key] ?? '')
          .where((value) => value.trim().isNotEmpty)
          .toSet();
      if (tokens.length != 1) return;
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
      if (onNavigate == null || !(canNavigate?.call() ?? true)) {
        _pending = data;
        return;
      }
    } catch (error) {
      _pending = data;
      AppLogger.w('DeepLinkHandler', 'readiness error: ${error.runtimeType}');
      return;
    }
    _pending = null;
    if (!_activeUris.add(data.uri)) return;
    unawaited(_navigate(data));
  }

  Future<void> _navigate(DeepLinkData data) async {
    try {
      await onNavigate?.call(data);
    } catch (error, stack) {
      // Exception messages can contain the original URI / capability.
      AppLogger.e(
        'DeepLinkHandler',
        'navigation callback error: ${error.runtimeType}',
        stackTrace: stack,
      );
    } finally {
      _activeUris.remove(data.uri);
    }
  }

  void resumePending() {
    if (_disposed) return;
    final pending = _pending;
    _pending = null;
    if (pending != null) _handleDeepLink(pending);
  }

  /// 生成分享链接
  static String generateChatLink(String roomId) {
    return _generateLink('chat', roomId);
  }

  static String generateUserLink(String userId) {
    return _generateLink('user', userId);
  }

  static String generateGroupLink(String groupId) {
    return _generateLink('group', groupId);
  }

  static String _generateLink(String action, String id) {
    if (!DeepLinkService.isValidTargetId(id)) {
      throw ArgumentError('Invalid deep link target');
    }
    return Uri(scheme: 'n42', host: action, pathSegments: [id]).toString();
  }

  /// 停止监听
  void dispose() {
    _disposed = true;
    _pending = null;
    _activeUris.clear();
    _subscription?.cancel();
    _subscription = null;
  }
}
