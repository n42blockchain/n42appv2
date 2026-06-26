part of '../../n42_chat.dart';

/// N42Chat 通话管理门面
///
/// 从 N42Chat 主类中提取的通话管理相关字段和方法。
/// 作为 part file 存在，所有成员对 N42Chat 可见。
class _N42CallFacade {
  _N42CallFacade._();

  static CallManager? _callManager;
  static Timer? _turnRefreshTimer;

  /// LiveKit JWT URL，由 well-known 发现填入。
  static String? _liveKitJwtUrl;

  /// 是否已分配运行时资源（dispose 短路检查使用）
  static bool get hasResources => _callManager != null;

  /// 初始化通话管理器
  ///
  /// 登录成功后调用此方法初始化 VoIP 服务
  static Future<void> initializeCallManager() async {
    try {
      final clientManager = getIt<MatrixClientManager>();
      final client = clientManager.client;

      if (client == null) {
        debugLog(
          'N42Chat: Matrix client not initialized, call manager will be initialized later',
        );
        return;
      }

      _turnRefreshTimer?.cancel();
      _turnRefreshTimer = null;
      await _callManager?.dispose();
      _callManager = CallManager();
      await _callManager!.initialize(
        client: client,
        navigatorKey: N42Chat._navigatorKey,
      );

      // 配置 TURN 服务器（从 Matrix 服务器获取）
      try {
        final turnServers = await client.getTurnServer();
        debugLog('N42Chat: TURN servers response: ${turnServers.uris}');
        if (turnServers.uris.isNotEmpty) {
          _callManager!.configureTurn(
            uris: turnServers.uris,
            username: turnServers.username,
            password: turnServers.password,
            ttl: turnServers.ttl,
          );
          _scheduleTurnRefresh(client, turnServers.ttl);
          debugLog('N42Chat: TURN servers configured');
        } else {
          debugLog('N42Chat: No TURN servers available');
        }
      } catch (e) {
        debugLog('N42Chat: Failed to get TURN servers: $e');
      }

      // 从 well-known 获取 LiveKit 配置
      await _discoverLiveKitConfig(client);

      debugLog('N42Chat: Call manager initialized');
    } catch (e) {
      debugLog('N42Chat: Failed to initialize call manager: $e');
    }
  }

  /// 从 well-known 发现 LiveKit 配置
  static Future<void> _discoverLiveKitConfig(matrix.Client client) async {
    try {
      final homeserver = client.homeserver;
      if (homeserver == null) return;

      // 获取 well-known 配置
      final wellKnownUrl = Uri.parse(
        '${homeserver.origin}/.well-known/matrix/client',
      );
      debugLog('N42Chat: Fetching well-known from $wellKnownUrl');

      final response = await client.httpClient.get(wellKnownUrl);
      if (response.statusCode != 200) {
        debugLog('N42Chat: Well-known request failed: ${response.statusCode}');
        return;
      }

      final wellKnown = jsonDecode(response.body) as Map<String, dynamic>;
      debugLog('N42Chat: Well-known response: $wellKnown');

      // 检查 rtc_foci (Matrix VoIP focus 配置)
      final rtcFoci =
          wellKnown['org.matrix.msc4143.rtc_foci'] as List<dynamic>?;
      if (rtcFoci != null && rtcFoci.isNotEmpty) {
        for (final focus in rtcFoci) {
          if (focus is Map<String, dynamic>) {
            final type = focus['type'] as String?;
            if (type == 'livekit') {
              // livekit_service_url 是 JWT 服务 URL，用于获取访问令牌
              final jwtServiceUrl = focus['livekit_service_url'] as String?;
              final liveKitAlias = focus['livekit_alias'] as String?;
              debugLog(
                'N42Chat: Found LiveKit JWT service: $jwtServiceUrl, alias=$liveKitAlias',
              );

              if (jwtServiceUrl != null) {
                // 保存 JWT URL
                _liveKitJwtUrl = jwtServiceUrl;

                // 从 JWT URL 推导 WebSocket URL
                // https://m.si46.world/livekit/jwt -> wss://m.si46.world/livekit/sfu
                final uri = Uri.parse(jwtServiceUrl);
                final wsUrl = 'wss://${uri.host}/livekit/sfu';

                if (_callManager != null) {
                  _callManager!.configureLiveKit(url: wsUrl);
                  debugLog('N42Chat: LiveKit WebSocket configured: $wsUrl');
                }
                break;
              }
            }
          }
        }
      }

      // 备选：检查自定义 LiveKit 配置字段
      final liveKitConfig = wellKnown['n42.livekit'] as Map<String, dynamic>?;
      if (liveKitConfig != null && _callManager != null) {
        final wsUrl = liveKitConfig['ws_url'] as String?;
        final jwtUrl = liveKitConfig['jwt_url'] as String?;
        if (wsUrl != null) {
          _callManager!.configureLiveKit(url: wsUrl);
          debugLog('N42Chat: LiveKit configured from n42.livekit: $wsUrl');
        }
        // 保存 JWT URL 供后续使用
        if (jwtUrl != null) {
          _liveKitJwtUrl = jwtUrl;
          debugLog('N42Chat: LiveKit JWT URL: $jwtUrl');
        }
      }
    } catch (e) {
      debugLog('N42Chat: Failed to discover LiveKit config: $e');
    }
  }

  /// 安排 TURN 凭据到期前自动刷新
  static void _scheduleTurnRefresh(matrix.Client c, int ttl) {
    _turnRefreshTimer?.cancel();
    if (ttl <= 0) return;
    final refreshAfter = Duration(seconds: (ttl - 60).clamp(60, ttl));
    _turnRefreshTimer = Timer(refreshAfter, () async {
      debugLog('N42Chat: Refreshing TURN credentials (TTL expiring)');
      try {
        final client = getIt<MatrixClientManager>().client;
        if (client == null || _callManager == null) return;
        final fresh = await client.getTurnServer();
        if (fresh.uris.isNotEmpty) {
          _callManager!.configureTurn(
            uris: fresh.uris,
            username: fresh.username,
            password: fresh.password,
            ttl: fresh.ttl,
          );
          _scheduleTurnRefresh(client, fresh.ttl);
        }
      } catch (e) {
        debugLog('N42Chat: TURN refresh failed: $e');
      }
    });
  }

  /// 释放通话相关资源（disposeCallManager 是别名）
  static Future<void> dispose() async {
    _turnRefreshTimer?.cancel();
    _turnRefreshTimer = null;
    try {
      await _callManager?.dispose();
    } catch (_) {}
    _callManager = null;
    _liveKitJwtUrl = null;
  }

  static Future<void> disposeCallManager() => dispose();
}
