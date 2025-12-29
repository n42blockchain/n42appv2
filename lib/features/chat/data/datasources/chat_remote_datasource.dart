// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:n42appv2/features/chat/domain/entities/message_entity.dart';
import 'package:n42appv2/features/chat/domain/entities/conversation_entity.dart';

/// Chat Remote Data Source Interface
///
/// Handles remote API interactions for chat functionality.
abstract class ChatRemoteDataSource {
  /// Connect to chat server
  Future<void> connect();

  /// Disconnect from chat server
  Future<void> disconnect();

  /// Check if connected
  bool get isConnected;

  /// Send message to server
  Future<MessageEntity> sendMessage({
    required String conversationId,
    required String content,
    required MessageType type,
    String? replyToId,
    Map<String, dynamic>? extra,
  });

  /// Get messages from server
  Future<List<MessageEntity>> getMessages({
    required String conversationId,
    int page = 1,
    int limit = 20,
    String? beforeMessageId,
  });

  /// Get conversations from server
  Future<List<ConversationEntity>> getConversations();

  /// Create group conversation
  Future<ConversationEntity> createGroup({
    required String name,
    required List<String> memberIds,
    String? avatarUrl,
  });

  /// Add members to group
  Future<void> addGroupMembers({
    required String groupId,
    required List<String> memberIds,
  });

  /// Remove member from group
  Future<void> removeGroupMember({
    required String groupId,
    required String memberId,
  });

  /// Leave group
  Future<void> leaveGroup(String groupId);

  /// Update group info
  Future<ConversationEntity> updateGroupInfo({
    required String groupId,
    String? name,
    String? avatarUrl,
  });

  /// Mark messages as read on server
  Future<void> markAsRead({
    required String conversationId,
    String? untilMessageId,
  });

  /// Upload file and get URL
  Future<String> uploadFile({
    required String filePath,
    required String fileName,
  });

  /// Stream of incoming messages
  Stream<MessageEntity> get messageStream;

  /// Stream of conversation updates
  Stream<ConversationEntity> get conversationStream;

  /// Stream of connection status
  Stream<bool> get connectionStream;
}

