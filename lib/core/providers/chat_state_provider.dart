// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Chat conversation info for state management
class ChatConversationInfo {
  final String targetId;
  final int conversationType; // 0: single, 1: group
  final String? name;
  final String? avatarUrl;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool isUnread;

  const ChatConversationInfo({
    required this.targetId,
    required this.conversationType,
    this.name,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.isUnread = false,
  });

  ChatConversationInfo copyWith({
    String? targetId,
    int? conversationType,
    String? name,
    String? avatarUrl,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? isUnread,
  }) {
    return ChatConversationInfo(
      targetId: targetId ?? this.targetId,
      conversationType: conversationType ?? this.conversationType,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      isUnread: isUnread ?? this.isUnread,
    );
  }

  bool get isSingleChat => conversationType == 0;
  bool get isGroupChat => conversationType == 1;
}

/// Chat state
class ChatState {
  final List<ChatConversationInfo> conversations;
  final String? currentChatTargetId;
  final int unreadCount;
  final int newFriendRequestCount;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.conversations = const [],
    this.currentChatTargetId,
    this.unreadCount = 0,
    this.newFriendRequestCount = 0,
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatConversationInfo>? conversations,
    String? currentChatTargetId,
    int? unreadCount,
    int? newFriendRequestCount,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      conversations: conversations ?? this.conversations,
      currentChatTargetId: currentChatTargetId ?? this.currentChatTargetId,
      unreadCount: unreadCount ?? this.unreadCount,
      newFriendRequestCount: newFriendRequestCount ?? this.newFriendRequestCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get conversation by target ID
  ChatConversationInfo? getConversation(String targetId) {
    try {
      return conversations.firstWhere((c) => c.targetId == targetId);
    } catch (_) {
      return null;
    }
  }

  /// Has unread messages
  bool get hasUnread => unreadCount > 0;

  /// Has new friend requests
  bool get hasNewFriendRequest => newFriendRequestCount > 0;
}

/// Chat state notifier
class ChatStateNotifier extends StateNotifier<ChatState> {
  ChatStateNotifier() : super(const ChatState());

  /// Set loading state
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// Set conversations list
  void setConversations(List<ChatConversationInfo> conversations) {
    state = state.copyWith(conversations: conversations);
    _updateUnreadCount();
  }

  /// Add or update a conversation
  void updateConversation(ChatConversationInfo conversation) {
    final index = state.conversations.indexWhere(
      (c) => c.targetId == conversation.targetId,
    );

    List<ChatConversationInfo> newList;
    if (index >= 0) {
      newList = List.from(state.conversations);
      newList[index] = conversation;
    } else {
      newList = [conversation, ...state.conversations];
    }

    state = state.copyWith(conversations: newList);
    _updateUnreadCount();
  }

  /// Remove a conversation
  void removeConversation(String targetId) {
    final newList = state.conversations
        .where((c) => c.targetId != targetId)
        .toList();
    state = state.copyWith(conversations: newList);
    _updateUnreadCount();
  }

  /// Set current chat target
  void setCurrentChatTarget(String? targetId) {
    state = state.copyWith(currentChatTargetId: targetId);
  }

  /// Mark conversation as read
  void markAsRead(String targetId) {
    final index = state.conversations.indexWhere(
      (c) => c.targetId == targetId,
    );

    if (index >= 0) {
      final newList = List<ChatConversationInfo>.from(state.conversations);
      newList[index] = newList[index].copyWith(isUnread: false);
      state = state.copyWith(conversations: newList);
      _updateUnreadCount();
    }
  }

  /// Update unread count
  void _updateUnreadCount() {
    final count = state.conversations.where((c) => c.isUnread).length;
    state = state.copyWith(unreadCount: count);
  }

  /// Set new friend request count
  void setNewFriendRequestCount(int count) {
    state = state.copyWith(newFriendRequestCount: count);
  }

  /// Increment new friend request count
  void incrementNewFriendRequestCount() {
    state = state.copyWith(
      newFriendRequestCount: state.newFriendRequestCount + 1,
    );
  }

  /// Set error
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// Clear all data
  void clear() {
    state = const ChatState();
  }

  /// Refresh (notify listeners)
  void refresh() {
    state = state.copyWith();
  }
}

/// Chat state provider
///
/// This is the new Riverpod-based chat state management.
/// It coexists with the legacy ChatMessageProvider for gradual migration.
///
/// Usage:
/// ```dart
/// // Read state
/// final chatState = ref.watch(chatStateProvider);
/// final conversations = chatState.conversations;
///
/// // Modify state
/// ref.read(chatStateProvider.notifier).setCurrentChatTarget('user-123');
/// ref.read(chatStateProvider.notifier).markAsRead('user-123');
/// ```
final chatStateProvider =
    StateNotifierProvider<ChatStateNotifier, ChatState>((ref) {
  return ChatStateNotifier();
});

/// Unread count provider (derived)
final chatUnreadCountProvider = Provider<int>((ref) {
  return ref.watch(chatStateProvider).unreadCount;
});

/// New friend request count provider (derived)
final newFriendRequestCountProvider = Provider<int>((ref) {
  return ref.watch(chatStateProvider).newFriendRequestCount;
});

/// Has unread messages provider (derived)
final hasUnreadMessagesProvider = Provider<bool>((ref) {
  return ref.watch(chatStateProvider).hasUnread;
});

/// Conversations list provider (derived)
final chatConversationsProvider = Provider<List<ChatConversationInfo>>((ref) {
  return ref.watch(chatStateProvider).conversations;
});

/// Current chat target provider (derived)
final currentChatTargetProvider = Provider<String?>((ref) {
  return ref.watch(chatStateProvider).currentChatTargetId;
});
