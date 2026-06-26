import 'package:equatable/equatable.dart';

/// Unified protocol event types
enum ProtocolEventType {
  /// A new message was received
  message,

  /// A message was edited
  messageEdited,

  /// A message was deleted
  messageDeleted,

  /// A reaction was added/removed
  reaction,

  /// A user started/stopped typing
  typing,

  /// Room membership changed (join/leave/invite)
  membership,

  /// Room state changed (name, topic, avatar, etc.)
  roomState,

  /// Read receipt updated
  readReceipt,

  /// Presence update (online/offline)
  presence,

  /// Encryption-related event
  encryption,

  /// Custom/unknown event
  custom,
}

/// A unified event from the messaging protocol.
///
/// Wraps protocol-specific events into a common format that
/// the application layer can process uniformly, regardless
/// of the underlying protocol (Matrix, XMTP, Waku, etc.).
class ProtocolEvent extends Equatable {
  /// Event type
  final ProtocolEventType type;

  /// Unique event ID
  final String eventId;

  /// Room ID where the event occurred
  final String? roomId;

  /// User who triggered the event
  final String? senderId;

  /// Display name of the sender
  final String? senderName;

  /// Event timestamp
  final DateTime timestamp;

  /// Text content (for messages)
  final String? content;

  /// Media URL (for media messages)
  final String? mediaUrl;

  /// MIME type (for media messages)
  final String? mimeType;

  /// Additional event-specific data
  final Map<String, dynamic> data;

  const ProtocolEvent({
    required this.type,
    required this.eventId,
    this.roomId,
    this.senderId,
    this.senderName,
    required this.timestamp,
    this.content,
    this.mediaUrl,
    this.mimeType,
    this.data = const {},
  });

  /// Create a message event
  factory ProtocolEvent.message({
    required String eventId,
    required String roomId,
    required String senderId,
    String? senderName,
    required String content,
    String? mediaUrl,
    String? mimeType,
    DateTime? timestamp,
  }) =>
      ProtocolEvent(
        type: ProtocolEventType.message,
        eventId: eventId,
        roomId: roomId,
        senderId: senderId,
        senderName: senderName,
        content: content,
        mediaUrl: mediaUrl,
        mimeType: mimeType,
        timestamp: timestamp ?? DateTime.now(),
      );

  /// Create a typing event
  factory ProtocolEvent.typing({
    required String roomId,
    required String senderId,
    required bool isTyping,
  }) =>
      ProtocolEvent(
        type: ProtocolEventType.typing,
        eventId: 'typing_${senderId}_${DateTime.now().millisecondsSinceEpoch}',
        roomId: roomId,
        senderId: senderId,
        timestamp: DateTime.now(),
        data: {'isTyping': isTyping},
      );

  /// Create a membership event
  factory ProtocolEvent.membership({
    required String eventId,
    required String roomId,
    required String userId,
    required String membership,
  }) =>
      ProtocolEvent(
        type: ProtocolEventType.membership,
        eventId: eventId,
        roomId: roomId,
        senderId: userId,
        timestamp: DateTime.now(),
        data: {'membership': membership},
      );

  @override
  List<Object?> get props => [
        type,
        eventId,
        roomId,
        senderId,
        senderName,
        timestamp,
        content,
        mediaUrl,
        mimeType,
        data,
      ];
}
