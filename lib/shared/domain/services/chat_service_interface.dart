// Copyright 2021-2026 N42 Inc. All rights reserved.

import 'package:n42appv2/src/chat/models/chat_message_model.dart';
import 'package:n42appv2/src/chat/models/friend_info.dart';
import 'package:n42appv2/src/chat/models/group_info.dart';

/// Chat Service Interface
///
/// Provides abstraction layer for chat operations to reduce coupling
/// with concrete implementations and Provider dependencies.
abstract class IChatService {
  /// Send a message to a user
  Future<bool> sendMessage({
    required String toUserId,
    required String content,
    required int messageType,
  });

  /// Send a message to a group
  Future<bool> sendGroupMessage({
    required String groupId,
    required String content,
    required int messageType,
  });

  /// Get chat history with a user
  Future<List<ChatMessageModel>> getChatHistory({
    required String targetId,
    int? lastTimestamp,
    int pageSize = 20,
  });

  /// Get conversation list
  Future<List<ChatMessageModel>> getConversationList();

  /// Delete conversation
  Future<bool> deleteConversation(String targetId);

  /// Mark messages as read
  Future<void> markAsRead(String targetId);
}

/// Chat Contact Service Interface
///
/// Handles friend/contact operations
abstract class IChatContactService {
  /// Get friend list
  Future<List<FriendInfo>> getFriendList();

  /// Get friend info by ID
  Future<FriendInfo?> getFriendInfo(String friendId);

  /// Add friend request
  Future<bool> addFriend({
    required String friendId,
    String? message,
  });

  /// Accept friend request
  Future<bool> acceptFriend(String friendId);

  /// Reject friend request
  Future<bool> rejectFriend(String friendId);

  /// Remove friend
  Future<bool> removeFriend(String friendId);
}

/// Chat Group Service Interface
///
/// Handles group operations
abstract class IChatGroupService {
  /// Get group list
  Future<List<GroupInfo>> getGroupList();

  /// Get group info by ID
  Future<GroupInfo?> getGroupInfo(String groupId);

  /// Create a new group
  Future<GroupInfo?> createGroup({
    required String name,
    required List<String> memberIds,
    String? avatar,
  });

  /// Join a group
  Future<bool> joinGroup(String groupId);

  /// Leave a group
  Future<bool> leaveGroup(String groupId);

  /// Get group members
  Future<List<String>> getGroupMembers(String groupId);

  /// Update group info
  Future<bool> updateGroupInfo(GroupInfo groupInfo);
}

/// Chat WebSocket Service Interface
///
/// Handles real-time messaging connection
abstract class IChatWebSocketService {
  /// Connection state
  bool get isConnected;

  /// Connect to WebSocket server
  Future<void> connect();

  /// Disconnect from WebSocket server
  Future<void> disconnect();

  /// Send a message through WebSocket
  void sendMessage(dynamic data);

  /// Stream of incoming messages
  Stream<ChatMessageModel> get messageStream;

  /// Stream of connection state changes
  Stream<bool> get connectionStateStream;
}
