import 'package:equatable/equatable.dart';

import 'message_entity.dart';

class ScheduledMessageDraft extends Equatable {
  final String messageId;
  final String? roomId;
  final String text;
  final MessageType type;
  final DateTime scheduledAt;
  final DateTime createdAt;
  final List<String> mentionedUserIds;
  final bool mentionsRoom;
  final int? selfDestructAfter;
  final Map<String, dynamic> payload;

  const ScheduledMessageDraft({
    required this.messageId,
    required this.text,
    required this.type,
    required this.scheduledAt,
    required this.createdAt,
    this.roomId,
    this.mentionedUserIds = const [],
    this.mentionsRoom = false,
    this.selfDestructAfter,
    this.payload = const {},
  });

  factory ScheduledMessageDraft.fromJson(Map<String, dynamic> json) {
    final rawPayload = json['payload'];
    final rawType = json['type'] as String?;

    return ScheduledMessageDraft(
      messageId: json['messageId'] as String? ?? '',
      roomId: json['roomId'] as String?,
      text: json['text'] as String? ?? '',
      type: _parseMessageType(rawType),
      scheduledAt: DateTime.tryParse(json['scheduledAt'] as String? ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      mentionedUserIds:
          (json['mentionedUserIds'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList(growable: false) ??
          const [],
      mentionsRoom: json['mentionsRoom'] as bool? ?? false,
      selfDestructAfter: json['selfDestructAfter'] as int?,
      payload: rawPayload is Map<String, dynamic>
          ? rawPayload
          : rawPayload is Map
          ? Map<String, dynamic>.from(rawPayload)
          : const {},
    );
  }

  Map<String, dynamic> toJson() => {
    'messageId': messageId,
    'text': text,
    'type': type.name,
    'scheduledAt': scheduledAt.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    'mentionedUserIds': mentionedUserIds,
    'mentionsRoom': mentionsRoom,
    'selfDestructAfter': selfDestructAfter,
    'payload': payload,
    if (roomId != null) 'roomId': roomId,
  };

  ScheduledMessageDraft copyWith({
    String? roomId,
    Map<String, dynamic>? payload,
  }) {
    return ScheduledMessageDraft(
      messageId: messageId,
      roomId: roomId ?? this.roomId,
      text: text,
      type: type,
      scheduledAt: scheduledAt,
      createdAt: createdAt,
      mentionedUserIds: mentionedUserIds,
      mentionsRoom: mentionsRoom,
      selfDestructAfter: selfDestructAfter,
      payload: payload ?? this.payload,
    );
  }

  List<String> get pollOptions =>
      (payload['options'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList(growable: false) ??
      const [];

  int get pollMaxSelections => payload['maxSelections'] as int? ?? 1;

  bool get isGif => (payload['gifUrl'] as String?)?.isNotEmpty == true;

  bool get hasLocalAttachment =>
      (payload['localPath'] as String?)?.isNotEmpty == true &&
      attachmentFilename.isNotEmpty;

  String? get localAttachmentPath => payload['localPath'] as String?;

  String get attachmentFilename =>
      (payload['filename'] as String?)?.trim().isNotEmpty == true
      ? (payload['filename'] as String).trim()
      : text.trim();

  String? get attachmentMimeType => payload['mimeType'] as String?;

  int? get attachmentFileSize => (payload['fileSize'] as num?)?.toInt();

  String get typeLabel {
    if (isGif) {
      return 'GIF';
    }

    switch (type) {
      case MessageType.image:
        return hasLocalAttachment ? 'Photo' : 'Message';
      case MessageType.video:
        return 'Video';
      case MessageType.file:
        return 'File';
      case MessageType.poll:
        return 'Poll';
      case MessageType.sticker:
        return 'Sticker';
      default:
        return 'Message';
    }
  }

  String get timelinePreviewText {
    if (isGif) {
      return text.isEmpty ? '[GIF]' : '[GIF] $text';
    }

    switch (type) {
      case MessageType.image:
        final label = attachmentFilename.isNotEmpty ? attachmentFilename : text;
        return label.isEmpty ? '[Photo]' : '[Photo] $label';
      case MessageType.video:
        final label = attachmentFilename.isNotEmpty ? attachmentFilename : text;
        return label.isEmpty ? '[Video]' : '[Video] $label';
      case MessageType.file:
        final label = attachmentFilename.isNotEmpty ? attachmentFilename : text;
        return label.isEmpty ? '[File]' : '[File] $label';
      case MessageType.poll:
        return '[Poll] $text';
      case MessageType.sticker:
        return text.isEmpty ? '[Sticker]' : '[Sticker] $text';
      default:
        return text;
    }
  }

  MessageEntity toPreviewMessage({
    required String roomId,
    required String senderId,
    String senderName = 'Me',
  }) {
    return MessageEntity(
      id: messageId,
      roomId: roomId,
      senderId: senderId,
      senderName: senderName,
      content: timelinePreviewText,
      type: MessageType.text,
      timestamp: createdAt,
      status: MessageStatus.sending,
      isFromMe: true,
      scheduledAt: scheduledAt,
      selfDestructAfter: selfDestructAfter,
      mentionedUserIds: mentionedUserIds,
      mentionsRoom: mentionsRoom,
    );
  }

  @override
  List<Object?> get props => [
    messageId,
    roomId,
    text,
    type,
    scheduledAt,
    createdAt,
    mentionedUserIds,
    mentionsRoom,
    selfDestructAfter,
    payload,
  ];

  static MessageType _parseMessageType(String? rawType) {
    if (rawType == null || rawType.isEmpty) {
      return MessageType.text;
    }

    for (final type in MessageType.values) {
      if (type.name == rawType) {
        return type;
      }
    }

    return MessageType.text;
  }
}
