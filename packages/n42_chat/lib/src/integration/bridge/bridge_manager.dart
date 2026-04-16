import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matrix/matrix.dart' as matrix;

import 'bridge_bot_service.dart';
import 'bridge_platform.dart';
import 'bridge_state.dart';
import '../../core/utils/debug_log.dart';

/// High-level manager for all Mautrix bridge connections.
///
/// Provides a simplified API for bridge discovery, connection management,
/// and state observation. Delegates low-level bot communication to
/// [BridgeBotService].
///
/// Usage:
/// ```dart
/// final manager = BridgeManager(client: matrixClient);
/// await manager.initialize();
///
/// // Observe state changes
/// manager.stateStream.listen((states) {
///   for (final state in states.values) {
///     print('${state.platform}: ${state.status}');
///   }
/// });
///
/// // Connect to WhatsApp
/// final result = await manager.login(BridgePlatform.whatsapp);
/// ```
class BridgeManager {
  final BridgeBotService _botService;

  /// Whether the manager has been initialized
  bool _initialized = false;

  /// Periodic status check timer
  Timer? _statusCheckTimer;

  /// Status check interval
  static const _statusCheckInterval = Duration(minutes: 5);

  BridgeManager({
    required matrix.Client client,
  }) : _botService = BridgeBotService(client: client);

  /// For testing: inject a pre-built BridgeBotService
  @visibleForTesting
  BridgeManager.withService(this._botService);

  /// Whether the manager has been initialized
  bool get isInitialized => _initialized;

  /// Stream of all bridge states
  Stream<Map<BridgePlatform, BridgeState>> get stateStream =>
      _botService.stateStream;

  /// Current bridge states
  Map<BridgePlatform, BridgeState> get states => _botService.states;

  /// Get state for a specific platform
  BridgeState getState(BridgePlatform platform) =>
      _botService.getState(platform);

  /// All connected bridges
  List<BridgeState> get connectedBridges => _botService.connectedBridges;

  /// All available bridges on the server
  List<BridgeState> get availableBridges => _botService.availableBridges;

  /// Total number of connected bridges
  int get connectedCount => connectedBridges.length;

  /// Initialize the bridge manager
  ///
  /// Discovers available bridges and queries their status.
  Future<void> initialize() async {
    if (_initialized) return;

    await _botService.startListening();
    await _botService.discoverBridges();

    // Start periodic status checks
    _statusCheckTimer = Timer.periodic(
      _statusCheckInterval,
      (_) => refreshAllStatuses(),
    );

    _initialized = true;
    debugLog('BridgeManager: Initialized with ${availableBridges.length} available bridges');
  }

  /// Refresh the status of all connected bridges
  Future<void> refreshAllStatuses() async {
    final connected = connectedBridges;
    for (final state in connected) {
      try {
        await _botService.queryStatus(state.platform);
      } catch (e) {
        debugLog('BridgeManager: Failed to refresh ${state.platform}: $e');
      }
    }
  }

  /// Login to a bridge platform
  ///
  /// Returns the bot's response which may include QR code data
  /// or further instructions.
  Future<BridgeBotResponse> login(BridgePlatform platform) async {
    _ensureInitialized();
    final info = BridgePlatformRegistry.getInfo(platform);

    // Choose login method based on platform's preferred auth
    if (info.authMethods.contains(BridgeAuthMethod.qrCode)) {
      return _botService.loginWithQR(platform);
    }
    return _botService.login(platform);
  }

  /// Login with a specific authentication method
  Future<BridgeBotResponse> loginWithMethod(
    BridgePlatform platform,
    BridgeAuthMethod method, {
    String? credentials,
  }) async {
    _ensureInitialized();

    switch (method) {
      case BridgeAuthMethod.qrCode:
        return _botService.loginWithQR(platform);
      case BridgeAuthMethod.apiToken:
        if (credentials == null) {
          return const BridgeBotResponse(
            text: 'API token is required',
            isSuccess: false,
          );
        }
        return _botService.sendCommand(
          platform,
          BridgeBotCommand.loginToken(credentials),
        );
      default:
        return _botService.login(platform);
    }
  }

  /// Logout from a bridge platform
  Future<BridgeBotResponse> logout(BridgePlatform platform) async {
    _ensureInitialized();
    return _botService.logout(platform);
  }

  /// Query the current status of a bridge
  Future<BridgeBotResponse> queryStatus(BridgePlatform platform) async {
    _ensureInitialized();
    return _botService.queryStatus(platform);
  }

  /// Sync contacts from a bridge
  Future<BridgeBotResponse> syncContacts(BridgePlatform platform) async {
    _ensureInitialized();
    return _botService.syncContacts(platform);
  }

  /// List bridged contacts for a platform
  Future<BridgeBotResponse> listContacts(BridgePlatform platform) async {
    _ensureInitialized();
    return _botService.listContacts(platform);
  }

  /// Send a raw command to a bridge bot
  Future<BridgeBotResponse> sendRawCommand(
    BridgePlatform platform,
    String command,
  ) async {
    _ensureInitialized();
    return _botService.sendCommand(
      platform,
      BridgeBotCommand(command),
    );
  }

  /// Check if a specific bridge is available on the server
  bool isBridgeAvailable(BridgePlatform platform) =>
      getState(platform).isAvailable;

  /// Check if a specific bridge is connected
  bool isBridgeConnected(BridgePlatform platform) =>
      getState(platform).isConnected;

  /// Re-discover bridges (e.g., after server configuration changes)
  Future<void> rediscoverBridges() async {
    _ensureInitialized();
    await _botService.discoverBridges();
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'BridgeManager has not been initialized. '
        'Call initialize() first.',
      );
    }
  }

  /// Release resources
  Future<void> dispose() async {
    _statusCheckTimer?.cancel();
    await _botService.dispose();
    _initialized = false;
  }
}
