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
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;
  
  /// Deep Link 流控制器
  final _deepLinkController = StreamController<DeepLinkData>.broadcast();
  
  /// Deep Link 流
  Stream<DeepLinkData> get deepLinkStream => _deepLinkController.stream;
  
  /// 最后一个 Deep Link
  DeepLinkData? _lastDeepLink;
  DeepLinkData? get lastDeepLink => _lastDeepLink;

  DeepLinkService() {
    _appLinks = AppLinks();
  }

  /// 初始化服务
  Future<void> init() async {
    // 处理应用启动时的 Deep Link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (e) {
      debugPrint('Failed to get initial link: $e');
    }

    // 监听运行时的 Deep Link
    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (e) {
        debugPrint('Deep link stream error: $e');
      },
    );
  }

  /// 处理 URI
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

  /// 解析 URI
  DeepLinkData _parseUri(Uri uri) {
    // 处理 WalletConnect
    if (_isWalletConnectUri(uri)) {
      return DeepLinkData(
        type: DeepLinkType.walletConnect,
        uri: uri,
        params: {'wcUri': uri.toString()},
      );
    }

    // 处理 n42:// scheme
    if (uri.scheme == 'n42' || uri.scheme == 'n42app') {
      return _parseN42Uri(uri);
    }

    // 处理应用 scheme (astraapp://)
    if (uri.scheme == 'astraapp') {
      return _parseAstraAppUri(uri);
    }

    return DeepLinkData(
      type: DeepLinkType.unknown,
      uri: uri,
      params: uri.queryParameters,
    );
  }

  /// 检查是否是 WalletConnect URI
  ///
  /// WalletConnect v2 URI 格式: wc:{topic}@2?relay-protocol=irn&symKey=...
  /// 也支持通过其他 scheme 传入的 WC URI（query 中包含 relay-protocol + symKey）
  bool _isWalletConnectUri(Uri uri) {
    if (uri.scheme == 'wc') return true;
    final uriString = uri.toString();
    return uriString.contains('relay-protocol') &&
           uriString.contains('symKey');
  }

  /// 解析 AstraApp URI
  DeepLinkData _parseAstraAppUri(Uri uri) {
    final params = uri.queryParameters;
    final type = params['type'];

    switch (type) {
      case 'group_mining':
        return DeepLinkData(
          type: DeepLinkType.groupMining,
          uri: uri,
          params: {
            'groupId': params['id'] ?? '',
          },
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
        return DeepLinkData(
          type: DeepLinkType.unknown,
          uri: uri,
          params: params,
        );
    }
  }

  /// 解析 N42 URI
  ///
  /// 支持格式:
  /// - n42://chat/{roomId} - 打开指定聊天
  /// - n42://user/{userId} - 打开用户主页
  /// - n42://group/{groupId} - 打开群组
  DeepLinkData _parseN42Uri(Uri uri) {
    // Dart Uri 解析 n42://chat/roomId 时，host='chat', path='/roomId'
    // 优先使用 host 作为 action（这是 n42://action/id 格式的标准行为）
    const knownActions = {'chat', 'user', 'group'};
    final host = uri.host;

    String action;
    String id;

    if (host.isNotEmpty && knownActions.contains(host)) {
      // n42://chat/roomId 格式: host 是 action，path 第一段是 id
      action = host;
      final pathSegments = uri.pathSegments;
      id = pathSegments.isNotEmpty ? pathSegments.first : '';
    } else if (uri.pathSegments.isNotEmpty) {
      // 路径式格式: n42:///chat/roomId 或 host 不是已知 action
      action = uri.pathSegments.first;
      id = uri.pathSegments.length > 1 ? uri.pathSegments[1] : '';
    } else {
      return DeepLinkData(
        type: DeepLinkType.unknown,
        uri: uri,
        params: uri.queryParameters,
      );
    }

    switch (action) {
      case 'chat':
        return DeepLinkData(
          type: DeepLinkType.chat,
          uri: uri,
          params: {'roomId': id, ...uri.queryParameters},
        );
      case 'user':
        return DeepLinkData(
          type: DeepLinkType.user,
          uri: uri,
          params: {'userId': id, ...uri.queryParameters},
        );
      case 'group':
        return DeepLinkData(
          type: DeepLinkType.group,
          uri: uri,
          params: {'groupId': id, ...uri.queryParameters},
        );
      default:
        return DeepLinkData(
          type: DeepLinkType.unknown,
          uri: uri,
          params: uri.queryParameters,
        );
    }
  }

  /// 手动处理 URI
  void handleUri(Uri uri) {
    _handleUri(uri);
  }

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

