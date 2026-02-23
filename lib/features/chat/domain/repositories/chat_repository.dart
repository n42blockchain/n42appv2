// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:dartz/dartz.dart';
import 'package:n42_wallet/core/error/failures.dart';
import 'package:n42_wallet/features/chat/domain/entities/message_entity.dart';
import 'package:n42_wallet/features/chat/domain/entities/conversation_entity.dart';

/// Chat Repository Interface
///
/// Defines the contract for chat data operations.
abstract class ChatRepository {
  /// Get all conversations
  Future<Either<Failure, List<ConversationEntity>>> getConversations();

  /// Get conversation by ID
  Future<Either<Failure, ConversationEntity?>> getConversation(String conversationId);

  /// Create or get existing conversation
  Future<Either<Failure, ConversationEntity>> getOrCreateConversation({
    required String participantId,
    bool isGroup = false,
  });

  /// Get messages for conversation
  Future<Either<Failure, List<MessageEntity>>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 20,
  });

  /// Send message
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String conversationId,
    required String content,
    required MessageType type,
    String? replyToId,
    Map<String, dynamic>? extra,
  });

  /// Delete message
  Future<Either<Failure, void>> deleteMessage({
    required String conversationId,
    required String messageId,
  });

  /// Mark messages as read
  Future<Either<Failure, void>> markAsRead({
    required String conversationId,
    String? untilMessageId,
  });

  /// Get unread count
  Future<Either<Failure, int>> getUnreadCount();

  /// Get unread count for conversation
  Future<Either<Failure, int>> getConversationUnreadCount(String conversationId);

  /// Delete conversation
  Future<Either<Failure, void>> deleteConversation(String conversationId);

  /// Mute conversation
  Future<Either<Failure, void>> muteConversation({
    required String conversationId,
    required bool mute,
  });

  /// Pin conversation
  Future<Either<Failure, void>> pinConversation({
    required String conversationId,
    required bool pin,
  });

  /// Stream of new messages
  Stream<MessageEntity> get messageStream;

  /// Stream of conversation updates
  Stream<ConversationEntity> get conversationStream;
}

