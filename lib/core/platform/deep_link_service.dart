import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:n42_wallet/features/wallet_connect/wallet_connect_uri.dart';

/// Deep Link 类型
enum DeepLinkType {
  /// WalletConnect
  walletConnect,

  /// 群组挖矿
  groupMining,

  /// 全节点
  fullNode,

  /// 好友名片
  friendCard,

  /// 打开指定聊天
  chat,

  /// 打开用户主页
  user,

  /// 打开群组
  group,

  /// Chat SSO/OIDC 登录回调
  chatSso,

  /// 未知类型
  unknown,
}

/// Deep Link 数据
class DeepLinkData {
  static const Set<String> _sensitiveParams = {
    'loginToken',
    'login_token',
    'token',
    'access_token',
    'symKey',
    'wcUri',
    'password',
    'privateKey',
    'mnemonic',
  };

  /// 链接类型
  final DeepLinkType type;

  /// 原始 URI
  final Uri uri;

  /// 解析的参数
  final Map<String, String> params;

  const DeepLinkData({
    required this.type,
    required this.uri,
    required this.params,
  });

  Uri get sanitizedUri => redactUri(uri);

  Map<String, String> get sanitizedParams =>
      params.map((key, value) => MapEntry(key, _redactParamValue(key, value)));

  static Uri redactUri(Uri uri) {
    if (uri.queryParameters.isEmpty) return uri;
    return uri.replace(
      queryParameters: uri.queryParameters.map(
        (key, value) => MapEntry(key, _redactParamValue(key, value)),
      ),
    );
  }

  static String _redactParamValue(String key, String value) {
    if (key == 'wcUri' || key == 'uri') {
      final normalizedWcUri = normalizeWalletConnectUriString(value);
      if (normalizedWcUri != null) {
        final nestedUri = Uri.tryParse(normalizedWcUri);
        if (nestedUri != null) {
          return redactUri(nestedUri).toString();
        }
        return '[redacted]';
      }
    }
    if (_sensitiveParams.contains(key)) {
      return '[redacted]';
    }
    return value;
  }

  @override
  String toString() =>
      'DeepLinkData(type: $type, uri: $sanitizedUri, params: $sanitizedParams)';
}

/// Deep Link 服务
///
/// 统一处理 Android 和 iOS 的 Deep Link
class DeepLinkService {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  /// Deep Link 流控制器
  final _deepLinkController = StreamController<DeepLinkData>.broadcast();

  /// Deep Link 流
  Stream<DeepLinkData> get deepLinkStream => _deepLinkController.stream;

  DeepLinkData? _lastDeepLink;

  /// 最后一个 Deep Link
  DeepLinkData? get lastDeepLink => _lastDeepLink;

  /// 初始化服务
  Future<void> init() async {
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) _handleUri(initialUri);
    } catch (e) {
      debugPrint('Failed to get initial link: $e');
    }

    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (e) => debugPrint('Deep link stream error: $e'),
    );
  }

  void _handleUri(Uri uri) {
    // Deep link 诊断日志只在 debug 下输出，且默认脱敏 query 参数。
    assert(() {
      debugPrint('Received deep link: ${DeepLinkData.redactUri(uri)}');
      return true;
    }());

    final data = _parseUri(uri);
    _lastDeepLink = data;
    _deepLinkController.add(data);
  }

  DeepLinkData _parseUri(Uri uri) {
    // Scheme whitelist: only process known safe schemes
    const allowedSchemes = {'n42', 'n42app', 'astraapp', 'https', 'http', 'wc', ''};
    if (!allowedSchemes.contains(uri.scheme.toLowerCase())) {
      assert(() {
        debugPrint('Rejected deep link with unknown scheme: ${uri.scheme}');
        return true;
      }());
      return _unknownLink(uri, uri.queryParameters);
    }

    final parsedWcUri = parseWalletConnectUri(uri.toString());
    if (parsedWcUri != null) {
      return DeepLinkData(
        type: DeepLinkType.walletConnect,
        uri: uri,
        params: {'wcUri': parsedWcUri.toString()},
      );
    }
    if (uri.scheme == 'n42' || uri.scheme == 'n42app') {
      return _parseN42Uri(uri);
    }
    if (uri.scheme == 'astraapp') {
      return _parseAstraAppUri(uri);
    }
    return _unknownLink(uri, uri.queryParameters);
  }

  DeepLinkData _parseAstraAppUri(Uri uri) {
    final params = uri.queryParameters;
    switch (params['type']) {
      case 'group_mining':
        return DeepLinkData(
          type: DeepLinkType.groupMining,
          uri: uri,
          params: {'groupId': params['id'] ?? ''},
        );
      case 'full_node':
        return DeepLinkData(
          type: DeepLinkType.fullNode,
          uri: uri,
          params: params,
        );
      case 'friendCard':
        return DeepLinkData(
          type: DeepLinkType.friendCard,
          uri: uri,
          params: {
            'userId': params['userid'] ?? '',
            'email': params['email'] ?? '',
          },
        );
      default:
        return _unknownLink(uri, params);
    }
  }

  /// 支持格式:
  /// - n42://chat/{roomId} - 打开指定聊天
  /// - n42://user/{userId} - 打开用户主页
  /// - n42://group/{groupId} - 打开群组
  DeepLinkData _parseN42Uri(Uri uri) {
    if (uri.host == 'auth' &&
        uri.pathSegments.isNotEmpty &&
        uri.pathSegments.first == 'sso') {
      return DeepLinkData(
        type: DeepLinkType.chatSso,
        uri: uri,
        params: uri.queryParameters,
      );
    }

    const actionConfig = {
      'chat': (type: DeepLinkType.chat, key: 'roomId'),
      'user': (type: DeepLinkType.user, key: 'userId'),
      'group': (type: DeepLinkType.group, key: 'groupId'),
    };

    // Dart Uri 解析 n42://chat/roomId 时，host='chat', path='/roomId'
    // 优先使用 host 作为 action（这是 n42://action/id 格式的标准行为）
    final host = uri.host;

    String action;
    String id;

    if (host.isNotEmpty && actionConfig.containsKey(host)) {
      action = host;
      id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
    } else if (uri.pathSegments.isNotEmpty) {
      action = uri.pathSegments.first;
      id = uri.pathSegments.length > 1 ? uri.pathSegments[1] : '';
    } else {
      return _unknownLink(uri, uri.queryParameters);
    }

    final config = actionConfig[action];
    if (config == null) return _unknownLink(uri, uri.queryParameters);

    // Sanitize the ID to prevent path traversal or injection attacks.
    // IDs should be alphanumeric identifiers, not contain path separators.
    final sanitizedId = _sanitizeId(id);

    return DeepLinkData(
      type: config.type,
      uri: uri,
      params: {config.key: sanitizedId, ...uri.queryParameters},
    );
  }

  /// Sanitize an ID parameter from a deep link to prevent injection attacks.
  /// Strips path separators and control characters; keeps alphanumeric,
  /// hyphens, underscores, dots, colons, and @ (for Matrix-style IDs).
  static final RegExp _unsafeIdChars = RegExp(r'[^a-zA-Z0-9._\-:@!]');

  static String _sanitizeId(String id) {
    return id.replaceAll(_unsafeIdChars, '');
  }

  DeepLinkData _unknownLink(Uri uri, Map<String, String> params) =>
      DeepLinkData(type: DeepLinkType.unknown, uri: uri, params: params);

  /// 手动处理 URI
  void handleUri(Uri uri) => _handleUri(uri);

  /// 清除最后一个 Deep Link
  void clearLastDeepLink() {
    _lastDeepLink = null;
  }

  /// 销毁服务
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _deepLinkController.close();
  }
}
