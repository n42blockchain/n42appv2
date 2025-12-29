// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.
//
// Author: Jiang Yiwei

import 'package:equatable/equatable.dart';

import 'message_entity.dart';

/// Conversation Entity
///
/// Represents a chat conversation (private or group).
class ConversationEntity extends Equatable {
  /// Unique conversation identifier
  final String id;

  /// Conversation type
  final ConversationType type;

  /// Conversation title/name
  final String title;

  /// Avatar URL
  final String? avatarUrl;

  /// Last message in conversation
  final MessageEntity? lastMessage;

  /// Unread message count
  final int unreadCount;

  /// Whether conversation is pinned
  final bool isPinned;

  /// Whether conversation is muted
  final bool isMuted;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Group member count (for group conversations)
  final int? memberCount;

  /// Target user ID (for private conversations)
  final String? targetUserId;

  const ConversationEntity({
    required this.id,
    required this.type,
    required this.title,
    this.avatarUrl,
    this.lastMessage,
    this.unreadCount = 0,
    this.isPinned = false,
    this.isMuted = false,
    required this.updatedAt,
    this.memberCount,
    this.targetUserId,
  });

  /// Check if has unread messages
  bool get hasUnread => unreadCount > 0;

  /// Get display unread count (99+ for large numbers)
  String get displayUnreadCount {
    if (unreadCount > 99) return '99+';
    return unreadCount.toString();
  }

  ConversationEntity copyWith({
    String? id,
    ConversationType? type,
    String? title,
    String? avatarUrl,
    MessageEntity? lastMessage,
    int? unreadCount,
    bool? isPinned,
    bool? isMuted,
    DateTime? updatedAt,
    int? memberCount,
    String? targetUserId,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      updatedAt: updatedAt ?? this.updatedAt,
      memberCount: memberCount ?? this.memberCount,
      targetUserId: targetUserId ?? this.targetUserId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        avatarUrl,
        lastMessage,
        unreadCount,
        isPinned,
        isMuted,
        updatedAt,
        memberCount,
        targetUserId,
      ];
}

/// Group Info Entity
class GroupInfoEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? avatarUrl;
  final String ownerId;
  final List<GroupMember> members;
  final DateTime createdAt;
  final GroupSettings settings;

  const GroupInfoEntity({
    required this.id,
    required this.name,
    this.description,
    this.avatarUrl,
    required this.ownerId,
    required this.members,
    required this.createdAt,
    required this.settings,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        avatarUrl,
        ownerId,
        members,
        createdAt,
        settings,
      ];
}

/// Group Member
class GroupMember extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final GroupRole role;
  final DateTime joinedAt;

  const GroupMember({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.role,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [id, name, avatarUrl, role, joinedAt];
}

/// Group Role
enum GroupRole {
  owner,
  admin,
  member,
}

/// Group Settings
class GroupSettings extends Equatable {
  final bool allowMemberInvite;
  final bool muteAllMembers;
  final bool requireApproval;

  const GroupSettings({
    this.allowMemberInvite = true,
    this.muteAllMembers = false,
    this.requireApproval = false,
  });

  @override
  List<Object?> get props => [allowMemberInvite, muteAllMembers, requireApproval];
}

