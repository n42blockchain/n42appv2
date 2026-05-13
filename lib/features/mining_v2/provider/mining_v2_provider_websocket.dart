part of 'mining_v2_provider.dart';

/// WebSocket connection management mixin.
///
/// Handles native WebSocket lifecycle: connect, disconnect, reconnect with
/// exponential back-off, and message routing.
mixin _MiningWebSocketMixin on _MiningStateMixin {
  /// Lazily initialise the native WebSocket bridge.
  void initWebSocket() {
    wsBridge ??= NativeWebSocketBridge();
  }

  /// Connect or switch WebSocket (used for both initial connect and wallet switch).
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
          AppLogger.w('MiningWS', 'stream error: $e');
          _handleConnectionLost();
        },
        onDone: () {
          AppLogger.d('MiningWS', 'stream done');
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
      AppLogger.w('MiningWS', 'connect error: $e');
      _handleConnectionLost();
    }
  }

  /// User-initiated disconnect (exit mining / logout).
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

    // Stop the SDK runClient (new SDK approach)
    try {
      await mining.stopClient();
    } catch (e) {
      AppLogger.w('MiningWS', 'MiningStopClient error: $e');
    }

    // Also stop legacy WebSocket bridge if active
    try {
      await wsBridge?.disconnect();
    } catch (e) {
      AppLogger.w('MiningWS', 'disconnect error: $e');
    }

    wsSubscription?.cancel();
    wsSubscription = null;

    wsStateValue = WebSocketState.disconnected;
    wsConnected = false;
    miningStatus = false;
    notifyListeners();
  }

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
    AppLogger.d('MiningWS', 'scheduling reconnect attempt $wsReconnectAttempts in ${delay.inSeconds}s');

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

  @override
  void handleWebSocketMessage(String message) {
    AppLogger.d('MiningWS', 'received: $message');

    switch (message) {
      case 'WebSocket connected':
        wsStateValue = WebSocketState.connected;
        wsConnected = true;
        miningStatus = true;
        wsReconnectAttempts = 0;
        notifyListeners();
        getBeaconValidator();
      case 'onFailure' || 'onClosed':
        _handleConnectionLost();
      default:
        break;
    }
  }
}
