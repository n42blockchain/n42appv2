import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

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

  /// 未知类型
  unknown,
}

/// Deep Link 数据
class DeepLinkData {
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

  @override
  String toString() => 'DeepLinkData(type: $type, uri: $uri, params: $params)';
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
    // 仅在 debug 模式打印完整 URI，避免 release 模式泄露 symKey 等敏感参数
    assert(() {
      debugPrint('Received deep link: $uri');
      return true;
    }());

    final data = _parseUri(uri);
    _lastDeepLink = data;
    _deepLinkController.add(data);
  }

  DeepLinkData _parseUri(Uri uri) {
    if (_isWalletConnectUri(uri)) {
      return DeepLinkData(
        type: DeepLinkType.walletConnect,
        uri: uri,
        params: {'wcUri': uri.toString()},
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

  /// WalletConnect v2 URI 格式: wc:{topic}@2?relay-protocol=irn&symKey=...
  /// 也支持通过其他 scheme 传入的 WC URI（query 中包含 relay-protocol + symKey）
  bool _isWalletConnectUri(Uri uri) {
    if (uri.scheme == 'wc') return true;
    final s = uri.toString();
    return s.contains('relay-protocol') && s.contains('symKey');
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

    return DeepLinkData(
      type: config.type,
      uri: uri,
      params: {config.key: id, ...uri.queryParameters},
    );
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
