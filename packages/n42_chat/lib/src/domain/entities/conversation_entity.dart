import 'package:equatable/equatable.dart';

/// 会话类型
enum ConversationType {
  /// 私聊
  direct,

  /// 群聊
  group,

  /// 空间 (Space)
  space,
}

final _whitespaceRegExp = RegExp(r'\s+');

/// 会话通知模式
enum ConversationNotificationMode {
  /// 所有消息都提醒
  allMessages,

  /// 仅 @提及 或 @room 时提醒
  mentionsOnly,

  /// 完全静音
  muted,
}

/// 会话实体
///
/// 表示一个聊天会话（Matrix房间）
class ConversationEntity extends Equatable {
  /// Matrix房间ID
  final String id;

  /// 会话名称
  final String name;

  /// 头像URL
  final String? avatarUrl;

  /// 最后一条消息内容
  final String? lastMessage;

  /// 最后一条消息时间
  final DateTime? lastMessageTime;

  /// 最后一条消息发送者ID
  final String? lastMessageSenderId;

  /// 最后一条消息发送者名称
  final String? lastMessageSenderName;

  /// 未读消息数量
  final int unreadCount;

  /// 高亮未读数（@提及）
  final int highlightCount;

  /// 会话类型
  final ConversationType type;

  /// 是否已加密
  final bool isEncrypted;

  /// 是否置顶
  final bool isPinned;

  /// 是否静音
  final bool isMuted;

  /// 是否开启强提醒
  final bool isStrongReminder;

  /// 是否标记为已读
  final bool isMarkedAsRead;

  /// 房间主题/公告
  final String? topic;

  /// 成员数量
  final int memberCount;

  /// 群成员头像URL列表（用于九宫格头像）
  final List<String?>? memberAvatarUrls;

  /// 群成员名称列表（用于九宫格头像）
  final List<String>? memberNames;

  /// 群成员用户ID列表
  final List<String>? memberIds;

  /// 是否有人正在输入
  final bool hasTypingUsers;

  /// 正在输入的用户列表
  final List<String> typingUsers;

  /// 草稿消息
  final String? draft;

  /// 是否是低优先级（如历史房间）
  final bool isLowPriority;

  /// 是否被邀请但未加入
  final bool isInvite;

  /// 私聊对方的用户ID（仅私聊有效）
  final String? directUserId;

  /// 是否被隐藏
  final bool isHidden;

  const ConversationEntity({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSenderId,
    this.lastMessageSenderName,
    this.unreadCount = 0,
    this.highlightCount = 0,
    this.type = ConversationType.direct,
    this.isEncrypted = false,
    this.isPinned = false,
    this.isMuted = false,
    this.isStrongReminder = false,
    this.isMarkedAsRead = false,
    this.topic,
    this.memberCount = 0,
    this.memberAvatarUrls,
    this.memberNames,
    this.memberIds,
    this.hasTypingUsers = false,
    this.typingUsers = const [],
    this.draft,
    this.isLowPriority = false,
    this.isInvite = false,
    this.directUserId,
    this.isHidden = false,
  });

  /// 是否是私聊
  bool get isDirect => type == ConversationType.direct;

  /// 是否是群聊
  bool get isGroup => type == ConversationType.group;

  /// 是否有未读消息
  bool get hasUnread => unreadCount > 0 && !isMuted;

  /// 获取显示的未读数
  /// 超过99显示99+
  String get displayUnreadCount {
    if (unreadCount <= 0) return '';
    if (unreadCount > 99) return '99+';
    return unreadCount.toString();
  }

  /// 获取最后消息预览
  String get lastMessagePreview {
    if (hasTypingUsers) {
      if (typingUsers.length == 1) {
        return '${typingUsers.first} is typing...';
      }
      return '${typingUsers.length} people are typing...';
    }

    if (draft != null && draft!.isNotEmpty) {
      return '[Draft] $draft';
    }

    if (lastMessage == null || lastMessage!.isEmpty) {
      return '';
    }

    // 群聊显示发送者
    if (isGroup && lastMessageSenderName != null) {
      return '$lastMessageSenderName: $lastMessage';
    }

    return lastMessage!;
  }

  /// 获取名称首字母（用于头像）
  String get initials {
    if (name.isEmpty) return '?';

    final words = name.trim().split(_whitespaceRegExp);
    if (words.length == 1) {
      return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
    }

    return words
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
  }

  @override
  List<Object?> get props => [
    id,
    name,
    avatarUrl,
    lastMessage,
    lastMessageTime,
    lastMessageSenderId,
    lastMessageSenderName,
    unreadCount,
    highlightCount,
    type,
    isEncrypted,
    isPinned,
    isMuted,
    isStrongReminder,
    isMarkedAsRead,
    topic,
    memberCount,
    memberAvatarUrls,
    memberNames,
    memberIds,
    hasTypingUsers,
    typingUsers,
    draft,
    isLowPriority,
    isInvite,
    directUserId,
    isHidden,
  ];

  ConversationEntity copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? lastMessage,
    DateTime? lastMessageTime,
    String? lastMessageSenderId,
    String? lastMessageSenderName,
    int? unreadCount,
    int? highlightCount,
    ConversationType? type,
    bool? isEncrypted,
    bool? isPinned,
    bool? isMuted,
    bool? isStrongReminder,
    bool? isMarkedAsRead,
    String? topic,
    int? memberCount,
    List<String?>? memberAvatarUrls,
    List<String>? memberNames,
    List<String>? memberIds,
    bool? hasTypingUsers,
    List<String>? typingUsers,
    String? draft,
    bool? isLowPriority,
    bool? isInvite,
    String? directUserId,
    bool? isHidden,
  }) {
    return ConversationEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      lastMessageSenderId: lastMessageSenderId ?? this.lastMessageSenderId,
      lastMessageSenderName:
          lastMessageSenderName ?? this.lastMessageSenderName,
      unreadCount: unreadCount ?? this.unreadCount,
      highlightCount: highlightCount ?? this.highlightCount,
      type: type ?? this.type,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      isStrongReminder: isStrongReminder ?? this.isStrongReminder,
      isMarkedAsRead: isMarkedAsRead ?? this.isMarkedAsRead,
      topic: topic ?? this.topic,
      memberCount: memberCount ?? this.memberCount,
      memberAvatarUrls: memberAvatarUrls ?? this.memberAvatarUrls,
      memberNames: memberNames ?? this.memberNames,
      memberIds: memberIds ?? this.memberIds,
      hasTypingUsers: hasTypingUsers ?? this.hasTypingUsers,
      typingUsers: typingUsers ?? this.typingUsers,
      draft: draft ?? this.draft,
      isLowPriority: isLowPriority ?? this.isLowPriority,
      isInvite: isInvite ?? this.isInvite,
      directUserId: directUserId ?? this.directUserId,
      isHidden: isHidden ?? this.isHidden,
    );
  }
}
