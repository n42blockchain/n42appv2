part of 'mining_v2_provider.dart';

// ============================================================================
// WebSocket Connection Management
//
// Handles native WebSocket lifecycle: connect, disconnect, reconnect with
// exponential back-off, and message routing.
// ============================================================================

mixin _MiningWebSocketMixin on _MiningStateMixin {
  // ==================== Init ====================

  /// Lazily initialise the native WebSocket bridge.
  void initWebSocket() {
    wsBridge ??= NativeWebSocketBridge();
  }

  // ==================== Connect ====================

  /// 连接 / 切换 WebSocket（首连 + 切钱包共用）
  @override
  Future<void> connectWebSocket({
    required String wsUrl,
    required String validatorPubkey,
    required String validatorPrivateKey,
  }) async {
    // Store connection params for reconnection
    lastWsUrl = wsUrl;
    lastValidatorPubkey = validatorPubkey;
    lastValidatorPrivateKey = validatorPrivateKey;

    // Cancel any pending reconnect
    wsReconnectTimer?.cancel();
    wsReconnectTimer = null;

    try {
      wsStateValue = WebSocketState.connecting;
      notifyListeners();

      initWebSocket();

      // Cancel existing subscription before creating new one
      await wsSubscription?.cancel();
      wsSubscription = null;

      // Create new subscription for this connection
      wsSubscription = wsBridge!.messages.listen(
        handleWebSocketMessage,
        onError: (e) {
          debugPrint('WS stream error: $e');
          _handleConnectionLost();
        },
        onDone: () {
          debugPrint('WS stream done');
          _handleConnectionLost();
        },
      );

      await wsBridge!.connect(
        wsUrl: wsUrl,
        validatorPubkey: validatorPubkey,
        validatorPrivateKey: validatorPrivateKey,
      );

      // Connection successful
      wsStateValue = WebSocketState.connected;
      wsConnected = true;
      miningStatus = true;
      wsReconnectAttempts = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('WebSocket connect error: $e');
      _handleConnectionLost();
    }
  }

  // ==================== Disconnect ====================

  /// 用户主动断开（退出挖矿 / 登出）
  @override
  Future<void> disconnectWebSocket() async {
    // Cancel any pending reconnect
    wsReconnectTimer?.cancel();
    wsReconnectTimer = null;
    wsReconnectAttempts = 0;

    // Clear stored connection params
    lastWsUrl = null;
    lastValidatorPubkey = null;
    lastValidatorPrivateKey = null;

    try {
      await wsBridge?.disconnect();
    } catch (e) {
      debugPrint('WebSocket disconnect error: $e');
    }

    wsSubscription?.cancel();
    wsSubscription = null;

    wsStateValue = WebSocketState.disconnected;
    wsConnected = false;
    miningStatus = false;
    notifyListeners();
  }

  // ==================== Reconnect ====================

  /// Handle connection lost - attempt reconnection.
  void _handleConnectionLost() {
    wsStateValue = WebSocketState.disconnected;
    wsConnected = false;
    miningStatus = false;
    notifyListeners();

    if (lastWsUrl != null && wsReconnectAttempts < kMaxReconnectAttempts) {
      _scheduleReconnect();
    }
  }

  /// Schedule reconnection with exponential back-off.
  void _scheduleReconnect() {
    if (wsReconnectTimer != null) return;

    wsReconnectAttempts++;
    final delay = Duration(seconds: wsReconnectAttempts * 5);
    debugPrint('WS: Scheduling reconnect attempt $wsReconnectAttempts in ${delay.inSeconds}s');

    wsStateValue = WebSocketState.reconnecting;
    notifyListeners();

    wsReconnectTimer = Timer(delay, () async {
      wsReconnectTimer = null;
      if (lastWsUrl != null &&
          lastValidatorPubkey != null &&
          lastValidatorPrivateKey != null) {
        await connectWebSocket(
          wsUrl: lastWsUrl!,
          validatorPubkey: lastValidatorPubkey!,
          validatorPrivateKey: lastValidatorPrivateKey!,
        );
      }
    });
  }

  // ==================== Message Handling ====================

  @override
  void handleWebSocketMessage(String message) {
    debugPrint('Received WS: $message');

    switch (message) {
      case 'WebSocket connected':
        wsStateValue = WebSocketState.connected;
        wsConnected = true;
        miningStatus = true;
        wsReconnectAttempts = 0;
        notifyListeners();
        getBeaconValidator(); // immediately refresh beacon status on connect/reconnect
        break;

      case 'onFailure':
      case 'onClosed':
        _handleConnectionLost();
        break;

      default:
        // Normal business message handling
        break;
    }
  }
}
