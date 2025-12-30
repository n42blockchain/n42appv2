// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:equatable/equatable.dart';

/// Message Entity
///
/// Core domain entity representing a chat message.
class MessageEntity extends Equatable {
  /// Unique message identifier
  final int id;

  /// Server-assigned message ID
  final int? serverMessageId;

  /// Conversation type (0: private, 1: group)
  final ConversationType conversationType;

  /// Message direction (incoming/outgoing)
  final MessageDirection direction;

  /// Sender's user ID
  final String fromUser;

  /// Target (conversation ID or user ID)
  final String target;

  /// Message timestamp
  final DateTime timestamp;

  /// Message status
  final MessageStatus status;

  /// Message content
  final MessageContent content;

  /// Whether this is a reply to another message
  final int? replyToId;

  /// Whether current user is mentioned
  final bool isMentioned;

  /// List of mentioned user IDs
  final List<String> mentionedUserIds;

  const MessageEntity({
    required this.id,
    this.serverMessageId,
    required this.conversationType,
    required this.direction,
    required this.fromUser,
    required this.target,
    required this.timestamp,
    required this.status,
    required this.content,
    this.replyToId,
    this.isMentioned = false,
    this.mentionedUserIds = const [],
  });

  /// Check if message is from current user
  bool isFromMe(String currentUserId) => fromUser == currentUserId;

  /// Check if message is pending
  bool get isPending => status == MessageStatus.sending;

  /// Check if message failed to send
  bool get isFailed => status == MessageStatus.failed;

  MessageEntity copyWith({
    int? id,
    int? serverMessageId,
    ConversationType? conversationType,
    MessageDirection? direction,
    String? fromUser,
    String? target,
    DateTime? timestamp,
    MessageStatus? status,
    MessageContent? content,
    int? replyToId,
    bool? isMentioned,
    List<String>? mentionedUserIds,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      serverMessageId: serverMessageId ?? this.serverMessageId,
      conversationType: conversationType ?? this.conversationType,
      direction: direction ?? this.direction,
      fromUser: fromUser ?? this.fromUser,
      target: target ?? this.target,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      content: content ?? this.content,
      replyToId: replyToId ?? this.replyToId,
      isMentioned: isMentioned ?? this.isMentioned,
      mentionedUserIds: mentionedUserIds ?? this.mentionedUserIds,
    );
  }

  @override
  List<Object?> get props => [
        id,
        serverMessageId,
        conversationType,
        direction,
        fromUser,
        target,
        timestamp,
        status,
        content,
        replyToId,
        isMentioned,
        mentionedUserIds,
      ];
}

/// Conversation Type
enum ConversationType {
  private,
  group,
}

/// Message Direction
enum MessageDirection {
  incoming,
  outgoing,
}

/// Message Status
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

/// Message Type
enum MessageType {
  text,
  image,
  file,
  redPocket,
  system,
  voice,
  video,
}

/// Message Content Base Class
abstract class MessageContent extends Equatable {
  const MessageContent();

  /// Content type identifier
  String get type;
}

/// Text Message Content
class TextContent extends MessageContent {
  final String text;

  const TextContent(this.text);

  @override
  String get type => 'text';

  @override
  List<Object?> get props => [text];
}

/// Image Message Content
class ImageContent extends MessageContent {
  final String url;
  final String? thumbnailUrl;
  final int? width;
  final int? height;

  const ImageContent({
    required this.url,
    this.thumbnailUrl,
    this.width,
    this.height,
  });

  @override
  String get type => 'image';

  @override
  List<Object?> get props => [url, thumbnailUrl, width, height];
}

/// File Message Content
class FileContent extends MessageContent {
  final String url;
  final String fileName;
  final int fileSize;
  final String? mimeType;

  const FileContent({
    required this.url,
    required this.fileName,
    required this.fileSize,
    this.mimeType,
  });

  @override
  String get type => 'file';

  @override
  List<Object?> get props => [url, fileName, fileSize, mimeType];
}

/// Red Pocket Message Content
class RedPocketContent extends MessageContent {
  final String redPocketId;
  final String blessing;
  final double amount;
  final String tokenSymbol;
  final bool isClaimed;

  const RedPocketContent({
    required this.redPocketId,
    required this.blessing,
    required this.amount,
    required this.tokenSymbol,
    this.isClaimed = false,
  });

  @override
  String get type => 'red_pocket';

  @override
  List<Object?> get props => [redPocketId, blessing, amount, tokenSymbol, isClaimed];
}

