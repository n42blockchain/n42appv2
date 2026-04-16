import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matrix/matrix.dart' as matrix;

import 'bridge_platform.dart';
import 'bridge_state.dart';
import '../../core/utils/debug_log.dart';

/// Service for interacting with Mautrix bridge bots via Matrix messages.
///
/// Each Mautrix bridge exposes a management room where the user can
/// send commands like `login`, `logout`, `status`, etc.
class BridgeBotService {
  final matrix.Client _client;
  final String _homeserverDomain;

  static final RegExp _usernameRegex = RegExp(
    r'logged in as (.+?)(?:[\s\n]|$)',
    caseSensitive: false,
  );
  static final RegExp _mxcRegex = RegExp(r'mxc://[^\s]+');

  /// Stream controller for bridge state changes
  final _stateController =
      StreamController<Map<BridgePlatform, BridgeState>>.broadcast();

  /// Current states for all platforms
  final Map<BridgePlatform, BridgeState> _states = {};

  /// Management room IDs keyed by platform
  final Map<BridgePlatform, String> _managementRoomIds = {};

  /// Pending response completers for bot commands
  final Map<String, Completer<BridgeBotResponse>> _pendingResponses = {};

  /// Subscription for listening to Matrix timeline events
  StreamSubscription<matrix.Event>? _eventSubscription;

  BridgeBotService({required matrix.Client client})
    : _client = client,
      _homeserverDomain = _extractDomain(client.homeserver) {
    _initializeStates();
  }

  static String _extractDomain(Uri? homeserver) {
    if (homeserver == null) return 'localhost';
    return homeserver.host;
  }

  /// Stream of bridge state changes
  Stream<Map<BridgePlatform, BridgeState>> get stateStream =>
      _stateController.stream;

  /// Get current states
  Map<BridgePlatform, BridgeState> get states => Map.unmodifiable(_states);

  /// Get state for a specific platform
  BridgeState getState(BridgePlatform platform) {
    return _states[platform] ?? BridgeState(platform: platform);
  }

  /// Initialize states for all platforms
  void _initializeStates() {
    for (final platform in BridgePlatform.values) {
      _states[platform] = BridgeState(platform: platform);
    }
  }

  /// Start listening for bridge bot messages
  Future<void> startListening() async {
    await _eventSubscription?.cancel();
    _eventSubscription = _client.onTimelineEvent.stream.listen(
      _handleTimelineEvent,
    );
  }

  /// Discover which bridges are available on the homeserver
  ///
  /// Checks for bridge bot user existence in parallel for faster discovery.
  Future<void> discoverBridges() async {
    // Check all platforms in parallel for faster discovery
    await Future.wait(
      BridgePlatform.values.map((platform) => _discoverPlatform(platform)),
    );

    _notifyStateChange();

    // For available bridges with management rooms, query status
    for (final entry in _managementRoomIds.entries) {
      try {
        await queryStatus(entry.key);
      } catch (e) {
        debugLog('BridgeBotService: Failed to query ${entry.key}: $e');
      }
    }
  }

  /// Discover a single bridge platform
  Future<void> _discoverPlatform(BridgePlatform platform) async {
    final info = BridgePlatformRegistry.getInfo(platform);
    final botUserId = info.botUserId(_homeserverDomain);

    try {
      // Check if the bridge bot user exists by fetching profile
      await _client.getProfileFromUserId(botUserId);

      // Bot exists - check if we have a management room
      final managementRoomId = _findManagementRoom(botUserId);

      _states[platform] = BridgeState(
        platform: platform,
        status: BridgeConnectionStatus.disconnected,
        isAvailable: true,
        managementRoomId: managementRoomId,
      );

      if (managementRoomId != null) {
        _managementRoomIds[platform] = managementRoomId;
      }
    } catch (e) {
      // Bot doesn't exist or not reachable
      _states[platform] = BridgeState(
        platform: platform,
        status: BridgeConnectionStatus.notAvailable,
        isAvailable: false,
      );
    }
  }

  /// Find an existing management room with a bridge bot
  String? _findManagementRoom(String botUserId) {
    for (final room in _client.rooms) {
      if (room.isDirectChat) {
        final directChatMatrixID = room.directChatMatrixID;
        if (directChatMatrixID == botUserId) {
          return room.id;
        }
      }
    }
    return null;
  }

  /// Get or create a management room with a bridge bot
  Future<String> _ensureManagementRoom(BridgePlatform platform) async {
    // Check existing
    if (_managementRoomIds.containsKey(platform)) {
      return _managementRoomIds[platform]!;
    }

    final info = BridgePlatformRegistry.getInfo(platform);
    final botUserId = info.botUserId(_homeserverDomain);

    // Check if there's already a DM room
    final existingRoom = _findManagementRoom(botUserId);
    if (existingRoom != null) {
      _managementRoomIds[platform] = existingRoom;
      return existingRoom;
    }

    // Create a new DM room with the bot
    final roomId = await _client.createRoom(
      isDirect: true,
      invite: [botUserId],
      preset: matrix.CreateRoomPreset.trustedPrivateChat,
    );

    _managementRoomIds[platform] = roomId;
    _updateState(platform, (s) => s.copyWith(managementRoomId: roomId));

    return roomId;
  }

  /// Send a command to a bridge bot and wait for response
  Future<BridgeBotResponse> sendCommand(
    BridgePlatform platform,
    BridgeBotCommand command, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final roomId = await _ensureManagementRoom(platform);
    final room = _client.getRoomById(roomId);
    if (room == null) {
      return const BridgeBotResponse(
        text: 'Management room not found',
        isSuccess: false,
      );
    }

    if (_pendingResponses.containsKey(roomId)) {
      return const BridgeBotResponse(
        text: 'Another bridge command is already in progress',
        isSuccess: false,
      );
    }

    // Create a completer for the response
    final completer = Completer<BridgeBotResponse>();
    _pendingResponses[roomId] = completer;

    // Send the command message
    final message = command.toMessage();
    debugLog('BridgeBotService: Sending to ${platform.name}: $message');

    await room.sendTextEvent(message);

    // Wait for response with timeout
    try {
      final response = await completer.future.timeout(timeout);
      return response;
    } on TimeoutException {
      _pendingResponses.remove(roomId);
      return const BridgeBotResponse(
        text: 'Command timed out',
        isSuccess: false,
      );
    }
  }

  /// Login to a bridge platform
  Future<BridgeBotResponse> login(BridgePlatform platform) async {
    _updateState(
      platform,
      (s) => s.copyWith(status: BridgeConnectionStatus.connecting),
    );
    _notifyStateChange();

    final response = await sendCommand(platform, BridgeBotCommand.login);
    _processStatusResponse(platform, response);
    return response;
  }

  /// Login with QR code
  Future<BridgeBotResponse> loginWithQR(BridgePlatform platform) async {
    _updateState(
      platform,
      (s) => s.copyWith(status: BridgeConnectionStatus.connecting),
    );
    _notifyStateChange();

    final response = await sendCommand(platform, BridgeBotCommand.loginQR());
    _processStatusResponse(platform, response);
    return response;
  }

  /// Logout from a bridge platform
  Future<BridgeBotResponse> logout(BridgePlatform platform) async {
    final response = await sendCommand(platform, BridgeBotCommand.logout);

    _updateState(
      platform,
      (s) => s.copyWith(
        status: BridgeConnectionStatus.disconnected,
        remoteUsername: null,
        statusMessage: null,
        errorMessage: null,
      ),
    );
    _notifyStateChange();

    return response;
  }

  /// Query the current status of a bridge
  Future<BridgeBotResponse> queryStatus(BridgePlatform platform) async {
    final response = await sendCommand(
      platform,
      BridgeBotCommand.status,
      timeout: const Duration(seconds: 10),
    );
    _processStatusResponse(platform, response);
    return response;
  }

  /// Sync contacts from a bridge
  Future<BridgeBotResponse> syncContacts(BridgePlatform platform) async {
    return sendCommand(platform, BridgeBotCommand.sync());
  }

  /// List bridged contacts
  Future<BridgeBotResponse> listContacts(BridgePlatform platform) async {
    return sendCommand(platform, BridgeBotCommand.listContacts());
  }

  /// Handle incoming Matrix timeline events
  void _handleTimelineEvent(matrix.Event event) {
    // Only process messages from management rooms
    final roomId = event.roomId;
    if (roomId == null || !_pendingResponses.containsKey(roomId)) return;

    if (event.type != 'm.room.message') return;

    final body = event.body;
    if (body.isEmpty) return;

    // Check if this is from a bridge bot (not from us)
    if (event.senderId == _client.userID) return;

    final response = _parseResponse(body);
    final completer = _pendingResponses.remove(roomId);
    completer?.complete(response);
  }

  /// Parse a response message from a bridge bot
  BridgeBotResponse _parseResponse(String text) {
    final lowerText = text.toLowerCase();

    // Detect status
    BridgeConnectionStatus? detectedStatus;
    String? remoteUsername;
    String? qrCodeUrl;
    bool isSuccess = true;

    if (lowerText.contains('logged in') || lowerText.contains('connected')) {
      detectedStatus = BridgeConnectionStatus.connected;
      remoteUsername = _usernameRegex.firstMatch(text)?.group(1);
    } else if (lowerText.contains('not logged in') ||
        lowerText.contains('not connected') ||
        lowerText.contains('disconnected')) {
      detectedStatus = BridgeConnectionStatus.disconnected;
    } else if (lowerText.contains('error') || lowerText.contains('failed')) {
      detectedStatus = BridgeConnectionStatus.error;
      isSuccess = false;
    } else if (lowerText.contains('scan') || lowerText.contains('qr')) {
      detectedStatus = BridgeConnectionStatus.connecting;
    }

    qrCodeUrl = _mxcRegex.firstMatch(text)?.group(0);

    return BridgeBotResponse(
      text: text,
      detectedStatus: detectedStatus,
      isSuccess: isSuccess,
      qrCodeUrl: qrCodeUrl,
      remoteUsername: remoteUsername,
    );
  }

  /// Process a status response and update bridge state
  void _processStatusResponse(
    BridgePlatform platform,
    BridgeBotResponse response,
  ) {
    if (response.detectedStatus != null) {
      _updateState(
        platform,
        (s) => s.copyWith(
          status: response.detectedStatus,
          remoteUsername: response.remoteUsername ?? s.remoteUsername,
          statusMessage: response.text,
          errorMessage: response.detectedStatus == BridgeConnectionStatus.error
              ? response.text
              : null,
          lastConnected:
              response.detectedStatus == BridgeConnectionStatus.connected
              ? DateTime.now()
              : s.lastConnected,
        ),
      );
    } else {
      _updateState(platform, (s) => s.copyWith(statusMessage: response.text));
    }
    _notifyStateChange();
  }

  /// Update state for a platform
  void _updateState(
    BridgePlatform platform,
    BridgeState Function(BridgeState) updater,
  ) {
    _states[platform] = updater(
      _states[platform] ?? BridgeState(platform: platform),
    );
  }

  /// Notify listeners of state changes
  void _notifyStateChange() {
    if (!_stateController.isClosed) {
      _stateController.add(Map.unmodifiable(_states));
    }
  }

  /// Get all connected bridges
  List<BridgeState> get connectedBridges =>
      _states.values.where((s) => s.isConnected).toList();

  /// Get all available bridges
  List<BridgeState> get availableBridges =>
      _states.values.where((s) => s.isAvailable).toList();

  @visibleForTesting
  void registerManagementRoomForTest(BridgePlatform platform, String roomId) {
    _managementRoomIds[platform] = roomId;
    _updateState(
      platform,
      (state) => state.copyWith(
        managementRoomId: roomId,
        isAvailable: true,
        status: BridgeConnectionStatus.disconnected,
      ),
    );
  }

  @visibleForTesting
  void injectResponseForTest({required String roomId, required String text}) {
    final completer = _pendingResponses.remove(roomId);
    completer?.complete(_parseResponse(text));
  }

  /// Release resources
  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    if (_stateController.isClosed) {
      _pendingResponses.clear();
      return;
    }
    for (final completer in _pendingResponses.values) {
      if (!completer.isCompleted) {
        completer.complete(
          const BridgeBotResponse(
            text: 'Bridge service disposed',
            isSuccess: false,
          ),
        );
      }
    }
    _pendingResponses.clear();
    await _stateController.close();
  }
}
