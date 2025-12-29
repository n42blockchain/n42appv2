// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:n42appv2/features/chat/domain/entities/message_entity.dart';
import 'package:n42appv2/features/chat/domain/entities/conversation_entity.dart';

/// Chat Local Data Source Interface
///
/// Handles local storage of chat messages and conversations.
abstract class ChatLocalDataSource {
  /// Save message to local database
  Future<void> saveMessage(MessageEntity message);

  /// Save multiple messages
  Future<void> saveMessages(List<MessageEntity> messages);

  /// Get messages for conversation from local database
  Future<List<MessageEntity>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 20,
  });

  /// Get message by ID
  Future<MessageEntity?> getMessage(String messageId);

  /// Delete message from local database
  Future<void> deleteMessage(String messageId);

  /// Delete all messages in conversation
  Future<void> deleteConversationMessages(String conversationId);

  /// Save conversation
  Future<void> saveConversation(ConversationEntity conversation);

  /// Get all conversations
  Future<List<ConversationEntity>> getConversations();

  /// Get conversation by ID
  Future<ConversationEntity?> getConversation(String conversationId);

  /// Delete conversation
  Future<void> deleteConversation(String conversationId);

  /// Update conversation last message
  Future<void> updateConversationLastMessage({
    required String conversationId,
    required MessageEntity message,
  });

  /// Update unread count
  Future<void> updateUnreadCount({
    required String conversationId,
    required int count,
  });

  /// Get total unread count
  Future<int> getTotalUnreadCount();

  /// Clear all chat data
  Future<void> clearAll();
}

