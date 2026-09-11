import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:n42_wallet/core/utils/app_logger.dart';
import 'package:n42_wallet/shared/utils/wallet_connect_uri.dart';

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

  /// N42 ID Hub 钱包绑定扫码（n42id://bind?sid=...&hub=...）
  idHubBind,

  /// N42 ID Hub 跨设备登录授权扫码（n42id://auth?sid=...&hub=...）
  idHubAuth,

  /// 未知类型
  unknown,
}

/// Deep Link 数据
class DeepLinkData {
  static const Set<String> _sensitiveParams = {
    'logintoken',
    'token',
    'accesstoken',
    'refreshtoken',
    'symkey',
    'wcuri',
    'uri',
    'password',
    'privatekey',
    'mnemonic',
    'sid',
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
    try {
      return uri.replace(
        userInfo: uri.userInfo.isEmpty ? '' : 'redacted',
        queryParameters: uri.hasQuery
            ? uri.queryParametersAll.map(
                (key, values) => MapEntry(
                  key,
                  values.map((value) => _redactParamValue(key, value)).toList(),
                ),
              )
            : null,
        // Fragments can carry raw or nested pairing / login capabilities.
        fragment: uri.hasFragment ? '[redacted]' : null,
      );
    } catch (_) {
      return Uri(scheme: uri.scheme, path: '[redacted]');
    }
  }

  static String _redactParamValue(String key, String value) {
    final normalizedKey = key.toLowerCase().replaceAll(RegExp(r'[_-]'), '');
    return _sensitiveParams.contains(normalizedKey) ? '[redacted]' : value;
  }

  @override
  String toString() =>
      'DeepLinkData(type: $type, uri: $sanitizedUri, params: $sanitizedParams)';
}

/// Deep Link 服务
///
/// 统一处理 Android 和 iOS 的 Deep Link
class DeepLinkService {
  DeepLinkService({
    Future<Uri?> Function()? getInitialLink,
    Stream<Uri>? uriLinkStream,
  }) : _getInitialLink = getInitialLink ?? AppLinks().getInitialLink,
       _uriLinkStream = (() => uriLinkStream ?? AppLinks().uriLinkStream);

  final Future<Uri?> Function() _getInitialLink;
  final Stream<Uri> Function() _uriLinkStream;
  Future<void>? _initialization;
  bool _disposed = false;
  int _receivedRevision = 0;
  StreamSubscription<Uri>? _subscription;

  /// Deep Link 流控制器
  final _deepLinkController = StreamController<DeepLinkData>.broadcast();

  /// Deep Link 流
  Stream<DeepLinkData> get deepLinkStream => _deepLinkController.stream;

  DeepLinkData? _lastDeepLink;

  /// 最后一个 Deep Link
  DeepLinkData? get lastDeepLink => _lastDeepLink;

  /// 初始化服务
  Future<void> init() {
    if (_disposed) return Future.value();
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    // Subscribe first: a live link received while awaiting startup wins over
    // an older initial link. Repeated init calls share this subscription.
    final revision = _receivedRevision;
    // A handler may already have consumed the cached intent before init.
    final hadPendingLink = _receivedRevision > 0;
    _subscription = _uriLinkStream().listen(
      _handleUri,
      onError: (Object error) {
        AppLogger.w('DeepLink', 'stream error: ${error.runtimeType}');
      },
    );
    try {
      final initialUri = await _getInitialLink().timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      if (!_disposed &&
          !hadPendingLink &&
          revision == _receivedRevision &&
          initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (error) {
      AppLogger.w('DeepLink', 'initial link error: ${error.runtimeType}');
    }
  }

  void _handleUri(Uri uri) {
    if (_disposed) return;
    _receivedRevision++;
    DeepLinkData data;
    try {
      final invalid =
          uri.toString().length > 16384 ||
          uri.queryParametersAll.values.any(
            (values) =>
                values.length != 1 ||
                values.any(
                  (value) => RegExp(r'[\x00-\x1f\x7f]').hasMatch(value),
                ),
          );
      data = invalid ? _unknownLink(uri, const {}) : _parseUri(uri);
    } catch (_) {
      data = _unknownLink(uri, const {});
    }
    // Never log inbound URIs: pairing and login links contain capabilities.
    AppLogger.d('DeepLink', 'received type: ${data.type.name}');
    _lastDeepLink = data;
    _deepLinkController.add(data);
  }

  DeepLinkData _parseUri(Uri uri) {
    // Scheme whitelist: only process known safe schemes
    const allowedSchemes = {
      'n42',
      'n42app',
      'n42wallet',
      'n42id',
      'astraapp',
      'https',
      'http',
      'wc',
      '',
    };
    if (!allowedSchemes.contains(uri.scheme.toLowerCase())) {
      AppLogger.w(
        'DeepLink',
        'rejected deep link with unknown scheme: ${uri.scheme}',
      );
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
    if (uri.scheme == 'n42' ||
        uri.scheme == 'n42app' ||
        uri.scheme == 'n42wallet') {
      if (uri.userInfo.isNotEmpty || uri.hasPort) {
        return _unknownLink(uri, const {});
      }
      return _parseN42Uri(uri);
    }
    if (uri.scheme == 'n42id') {
      if (uri.userInfo.isNotEmpty ||
          uri.hasPort ||
          (uri.path.isNotEmpty && uri.path != '/')) {
        return _unknownLink(uri, const {});
      }
      return _parseN42IdUri(uri);
    }
    if (uri.scheme == 'astraapp') {
      if (uri.userInfo.isNotEmpty || uri.hasPort) {
        return _unknownLink(uri, const {});
      }
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
          params: {'groupId': _sanitizeId(params['id'] ?? '')},
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
            'userId': _sanitizeId(params['userid'] ?? ''),
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
        uri.pathSegments.length == 1 &&
        uri.pathSegments.single == 'sso') {
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

    if (host.isNotEmpty &&
        actionConfig.containsKey(host) &&
        uri.pathSegments.length == 1) {
      action = host;
      id = uri.pathSegments.single;
    } else if (host.isEmpty && uri.pathSegments.length == 2) {
      action = uri.pathSegments.first;
      id = uri.pathSegments[1];
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
      params: {...uri.queryParameters, config.key: sanitizedId},
    );
  }

  /// N42 ID Hub scan-to-sign links:
  /// - n42id://bind?sid=...&hub=https://id.n42.ai (wallet binding)
  /// - n42id://auth?sid=...&hub=https://id.n42.ai (cross-device login)
  ///
  /// Only sid + hub are carried; the message to sign is fetched from the hub
  /// later (never embedded here). The hub host is validated downstream against
  /// the allowlist before any signature is sent.
  DeepLinkData _parseN42IdUri(Uri uri) {
    final type = switch (uri.host) {
      'bind' => DeepLinkType.idHubBind,
      'auth' => DeepLinkType.idHubAuth,
      _ => DeepLinkType.unknown,
    };
    if (type == DeepLinkType.unknown) {
      return _unknownLink(uri, uri.queryParameters);
    }
    return DeepLinkData(
      type: type,
      uri: uri,
      params: {
        // Preserve exact capability / origin values for downstream validation.
        'sid': uri.queryParameters['sid'] ?? '',
        'hub': uri.queryParameters['hub'] ?? '',
      },
    );
  }

  /// Reject malformed identifiers instead of silently selecting another target.
  /// Retains the existing identifier alphabet, including Matrix-style IDs.
  static final RegExp _unsafeIdChars = RegExp(r'[^a-zA-Z0-9._\-:@!]');

  static bool isValidTargetId(String id) =>
      id.isNotEmpty &&
      id.length <= 1024 &&
      id != '.' &&
      id != '..' &&
      !_unsafeIdChars.hasMatch(id);

  static String _sanitizeId(String id) => isValidTargetId(id) ? id : '';

  DeepLinkData _unknownLink(Uri uri, Map<String, String> params) =>
      DeepLinkData(type: DeepLinkType.unknown, uri: uri, params: params);

  /// 手动处理 URI
  void handleUri(Uri uri) => _handleUri(uri);

  /// 清除最后一个 Deep Link
  void clearLastDeepLink() {
    _lastDeepLink = null;
  }

  /// 销毁服务。允许重复调用——同一服务可能同时被 [deepLinkServiceProvider]
  /// 的 onDispose 与 `_N42AppV2State.dispose` 持有引用，两者都会触发销毁。
  Future<void> dispose() async {
    _disposed = true;
    _lastDeepLink = null;
    await _subscription?.cancel();
    _subscription = null;
    if (!_deepLinkController.isClosed) {
      await _deepLinkController.close();
    }
  }
}
