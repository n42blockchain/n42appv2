import 'bridge_platform.dart';

/// Connection state for a bridge
enum BridgeConnectionStatus {
  /// Not configured on the server
  notAvailable,

  /// Available but user has not logged in
  disconnected,

  /// Login in progress
  connecting,

  /// Connected and bridging messages
  connected,

  /// Connection error (will retry)
  error,

  /// Bridge is reconnecting after a disconnection
  reconnecting,
}

/// Represents the current state of a bridge connection
class BridgeState {
  /// The platform this state belongs to
  final BridgePlatform platform;

  /// Current connection status
  final BridgeConnectionStatus status;

  /// Remote user info (username/phone on the external platform)
  final String? remoteUsername;

  /// Human-readable status message from the bridge bot
  final String? statusMessage;

  /// Error message if status is [BridgeConnectionStatus.error]
  final String? errorMessage;

  /// When the bridge was last connected
  final DateTime? lastConnected;

  /// The Matrix room ID for the management room with this bridge bot
  final String? managementRoomId;

  /// Number of bridged conversations
  final int bridgedConversationCount;

  /// Whether the bridge bot exists on the server
  final bool isAvailable;

  const BridgeState({
    required this.platform,
    this.status = BridgeConnectionStatus.notAvailable,
    this.remoteUsername,
    this.statusMessage,
    this.errorMessage,
    this.lastConnected,
    this.managementRoomId,
    this.bridgedConversationCount = 0,
    this.isAvailable = false,
  });

  /// Whether the bridge is currently connected
  bool get isConnected => status == BridgeConnectionStatus.connected;

  /// Whether the bridge is in a loading/transitioning state
  bool get isLoading =>
      status == BridgeConnectionStatus.connecting ||
      status == BridgeConnectionStatus.reconnecting;

  /// Whether the bridge has an error
  bool get hasError => status == BridgeConnectionStatus.error;

  /// Whether the user can initiate a login
  bool get canLogin =>
      isAvailable && status == BridgeConnectionStatus.disconnected;

  /// Whether the user can disconnect
  bool get canLogout => isConnected;

  /// Creates a copy with the given fields replaced.
  ///
  /// Nullable fields use [Object?] sentinel pattern so they can be
  /// explicitly set to `null` (e.g., clearing remoteUsername on logout).
  BridgeState copyWith({
    BridgeConnectionStatus? status,
    Object? remoteUsername = _sentinel,
    Object? statusMessage = _sentinel,
    Object? errorMessage = _sentinel,
    Object? lastConnected = _sentinel,
    Object? managementRoomId = _sentinel,
    int? bridgedConversationCount,
    bool? isAvailable,
  }) {
    return BridgeState(
      platform: platform,
      status: status ?? this.status,
      remoteUsername: remoteUsername == _sentinel
          ? this.remoteUsername
          : remoteUsername as String?,
      statusMessage: statusMessage == _sentinel
          ? this.statusMessage
          : statusMessage as String?,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      lastConnected: lastConnected == _sentinel
          ? this.lastConnected
          : lastConnected as DateTime?,
      managementRoomId: managementRoomId == _sentinel
          ? this.managementRoomId
          : managementRoomId as String?,
      bridgedConversationCount:
          bridgedConversationCount ?? this.bridgedConversationCount,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  static const Object _sentinel = Object();

  @override
  String toString() =>
      'BridgeState(${platform.name}: $status, remote: $remoteUsername)';
}

/// A command to send to a bridge bot
class BridgeBotCommand {
  /// The command string (e.g., 'login', 'logout', 'status')
  final String command;

  /// Optional arguments
  final List<String> arguments;

  const BridgeBotCommand(this.command, [this.arguments = const []]);

  /// Format as the message to send to the bridge bot
  String toMessage() {
    if (arguments.isEmpty) return command;
    return '$command ${arguments.join(' ')}';
  }

  // Common bridge bot commands
  static const login = BridgeBotCommand('login');
  static const logout = BridgeBotCommand('logout');
  static const status = BridgeBotCommand('status');
  static const help = BridgeBotCommand('help');
  static const ping = BridgeBotCommand('ping');
  static BridgeBotCommand loginQR() => const BridgeBotCommand('login', ['qr']);
  static BridgeBotCommand loginToken(String token) =>
      BridgeBotCommand('login-token', [token]);
  static BridgeBotCommand bridgeRoom(String remoteId) =>
      BridgeBotCommand('bridge', [remoteId]);
  static BridgeBotCommand unbridgeRoom() => const BridgeBotCommand('unbridge');
  static BridgeBotCommand listContacts() => const BridgeBotCommand('list', ['contacts']);
  static BridgeBotCommand listGroups() => const BridgeBotCommand('list', ['groups']);
  static BridgeBotCommand sync() => const BridgeBotCommand('sync');
}

/// Response from a bridge bot command
class BridgeBotResponse {
  /// The raw response text
  final String text;

  /// Parsed connection status (if determinable)
  final BridgeConnectionStatus? detectedStatus;

  /// Whether the response indicates success
  final bool isSuccess;

  /// QR code data URL (if the response contains a QR for login)
  final String? qrCodeUrl;

  /// Parsed remote username from status response
  final String? remoteUsername;

  const BridgeBotResponse({
    required this.text,
    this.detectedStatus,
    this.isSuccess = true,
    this.qrCodeUrl,
    this.remoteUsername,
  });
}
