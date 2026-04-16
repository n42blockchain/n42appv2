import 'protocol_capabilities.dart';
import 'protocol_event.dart';

/// Protocol connection state
enum ProtocolConnectionState {
  /// Not connected to the protocol
  disconnected,

  /// Establishing connection
  connecting,

  /// Successfully connected and operational
  connected,

  /// Lost connection, attempting to reconnect
  reconnecting,

  /// Connection failed with an error
  error,
}

/// Credentials for connecting to a messaging protocol.
///
/// Encapsulates the authentication information needed to establish
/// a connection. The [extra] map allows protocol-specific fields
/// without modifying the core interface.
class ProtocolCredentials {
  final String userId;
  final String? accessToken;
  final String? homeserver;
  final Map<String, dynamic> extra;

  const ProtocolCredentials({
    required this.userId,
    this.accessToken,
    this.homeserver,
    this.extra = const {},
  });
}

/// Parameters for creating a room.
///
/// Provides a protocol-agnostic way to specify room creation options.
/// Each protocol implementation maps these to its native API.
class RoomCreationParams {
  final String? name;
  final String? topic;
  final bool isPublic;
  final bool enableEncryption;
  final List<String> inviteUserIds;
  final bool isDirect;

  const RoomCreationParams({
    this.name,
    this.topic,
    this.isPublic = false,
    this.enableEncryption = true,
    this.inviteUserIds = const [],
    this.isDirect = false,
  });
}

/// Summary of a room from the protocol.
///
/// A lightweight representation of a room, suitable for list views
/// and quick lookups without loading full room state.
class RoomSummary {
  final String id;
  final String? name;
  final String? avatarUrl;
  final int memberCount;
  final String? lastMessage;
  final DateTime? lastActivity;
  final bool isDirect;
  final bool isEncrypted;

  const RoomSummary({
    required this.id,
    this.name,
    this.avatarUrl,
    this.memberCount = 0,
    this.lastMessage,
    this.lastActivity,
    this.isDirect = false,
    this.isEncrypted = false,
  });
}

/// User profile from the protocol.
///
/// A unified representation of a user profile across different
/// messaging protocols.
class ProtocolUserProfile {
  final String userId;
  final String? displayName;
  final String? avatarUrl;
  final bool isOnline;

  const ProtocolUserProfile({
    required this.userId,
    this.displayName,
    this.avatarUrl,
    this.isOnline = false,
  });
}

/// Content of a message to send.
///
/// Provides factory constructors for common message types and
/// a flexible [metadata] map for protocol-specific extensions.
class MessageContent {
  final MessageContentType type;
  final String? text;
  final String? mediaUrl;
  final String? mimeType;
  final String? fileName;
  final int? fileSize;
  final String? thumbnailUrl;
  final Map<String, dynamic>? metadata;

  const MessageContent({
    required this.type,
    this.text,
    this.mediaUrl,
    this.mimeType,
    this.fileName,
    this.fileSize,
    this.thumbnailUrl,
    this.metadata,
  });

  /// Create a text message
  factory MessageContent.text(String body) => MessageContent(
        type: MessageContentType.text,
        text: body,
      );

  /// Create an image message
  factory MessageContent.image({
    required String url,
    String? mimeType,
    String? fileName,
    int? fileSize,
    String? thumbnailUrl,
  }) =>
      MessageContent(
        type: MessageContentType.image,
        mediaUrl: url,
        mimeType: mimeType ?? 'image/jpeg',
        fileName: fileName,
        fileSize: fileSize,
        thumbnailUrl: thumbnailUrl,
      );
}

/// Supported message content types
enum MessageContentType {
  text,
  image,
  video,
  audio,
  file,
  location,
  sticker,
  custom,
}

/// Core messaging protocol interface.
///
/// Abstracts the underlying messaging protocol (Matrix, XMTP, Waku, etc.)
/// to allow pluggable protocol implementations. Each protocol provides
/// its own implementation that maps unified operations to protocol-specific
/// SDK calls.
///
/// Usage:
/// ```dart
/// final protocol = MatrixProtocol(...);
/// await protocol.connect(credentials);
/// await protocol.sendMessage(roomId, MessageContent.text('Hello'));
/// ```
abstract class IMessagingProtocol {
  /// Protocol identifier (e.g., 'matrix', 'xmtp', 'waku')
  String get protocolId;

  /// Protocol capabilities declaration
  ProtocolCapabilities get capabilities;

  // ─── Connection Management ───────────────────────────────────────

  /// Connect to the protocol with given credentials
  Future<void> connect(ProtocolCredentials credentials);

  /// Disconnect from the protocol
  Future<void> disconnect();

  /// Stream of connection state changes
  Stream<ProtocolConnectionState> get connectionState;

  /// Whether currently connected
  bool get isConnected;

  // ─── Messaging ───────────────────────────────────────────────────

  /// Send a message to a room.
  ///
  /// Returns the event/message ID assigned by the protocol.
  Future<String> sendMessage(String roomId, MessageContent content);

  /// Stream of protocol events (messages, state changes, etc.)
  Stream<ProtocolEvent> get eventStream;

  // ─── Room Management ─────────────────────────────────────────────

  /// Create a new room.
  ///
  /// Returns the room ID of the newly created room.
  Future<String> createRoom(RoomCreationParams params);

  /// Get list of joined rooms
  Future<List<RoomSummary>> getRooms();

  /// Join a room by ID or alias
  Future<void> joinRoom(String roomId);

  /// Leave a room
  Future<void> leaveRoom(String roomId);

  // ─── User Management ─────────────────────────────────────────────

  /// Get a user's profile
  Future<ProtocolUserProfile> getUserProfile(String userId);

  /// Search for users by query string
  Future<List<ProtocolUserProfile>> searchUsers(String query);
}
