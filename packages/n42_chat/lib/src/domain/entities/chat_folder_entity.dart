import 'package:equatable/equatable.dart';

/// 聊天文件夹实体
///
/// 用于组织和分类聊天会话，类似 Telegram 的文件夹功能
class ChatFolderEntity extends Equatable {
  /// 文件夹 ID
  final String id;

  /// 文件夹名称
  final String name;

  /// 文件夹图标（emoji 或图标名称）
  final String? icon;

  /// 文件夹颜色（十六进制）
  final String? color;

  /// 排序顺序
  final int order;

  /// 包含的房间 ID 列表
  final List<String> includedRoomIds;

  /// 排除的房间 ID 列表
  final List<String> excludedRoomIds;

  /// 过滤条件
  final ChatFolderFilter filter;

  /// 是否显示未读计数
  final bool showUnreadCount;

  /// 是否显示未读标记
  final bool showUnreadBadge;

  /// 是否是系统文件夹（不可删除）
  final bool isSystem;

  /// 未读消息数（运行时计算）
  final int unreadCount;

  /// 未读会话数（运行时计算）
  final int unreadChatsCount;

  const ChatFolderEntity({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.order = 0,
    this.includedRoomIds = const [],
    this.excludedRoomIds = const [],
    this.filter = const ChatFolderFilter(),
    this.showUnreadCount = true,
    this.showUnreadBadge = true,
    this.isSystem = false,
    this.unreadCount = 0,
    this.unreadChatsCount = 0,
  });

  /// 全部聊天文件夹（系统默认）
  static const ChatFolderEntity all = ChatFolderEntity(
    id: 'all',
    name: 'All Chats',
    icon: '💬',
    order: -1000,
    isSystem: true,
  );

  /// 未读文件夹
  static const ChatFolderEntity unread = ChatFolderEntity(
    id: 'unread',
    name: 'Unread',
    icon: '🔔',
    order: -900,
    isSystem: true,
    filter: ChatFolderFilter(unreadOnly: true),
  );

  /// 私聊文件夹
  static const ChatFolderEntity personal = ChatFolderEntity(
    id: 'personal',
    name: 'Personal',
    icon: '👤',
    order: -800,
    isSystem: true,
    filter: ChatFolderFilter(includeDirectMessages: true, includeGroups: false),
  );

  /// 群组文件夹
  static const ChatFolderEntity groups = ChatFolderEntity(
    id: 'groups',
    name: 'Groups',
    icon: '👥',
    order: -700,
    isSystem: true,
    filter: ChatFolderFilter(includeDirectMessages: false, includeGroups: true),
  );

  /// 频道文件夹
  static const ChatFolderEntity channels = ChatFolderEntity(
    id: 'channels',
    name: 'Channels',
    icon: '📢',
    order: -600,
    isSystem: true,
    filter: ChatFolderFilter(
      includeDirectMessages: false,
      includeGroups: false,
      includeChannels: true,
    ),
  );

  /// 静音文件夹
  static const ChatFolderEntity muted = ChatFolderEntity(
    id: 'muted',
    name: 'Muted',
    icon: '🔇',
    order: -500,
    isSystem: true,
    filter: ChatFolderFilter(mutedOnly: true),
  );

  /// 是否有自定义过滤
  bool get hasFilter => filter != const ChatFolderFilter() ||
      includedRoomIds.isNotEmpty ||
      excludedRoomIds.isNotEmpty;

  /// 是否匹配某个房间
  bool matchesRoom({
    required String roomId,
    required bool isDirectMessage,
    required bool isGroup,
    required bool isChannel,
    required bool isMuted,
    required int unreadCount,
  }) {
    // 检查排除列表
    if (excludedRoomIds.contains(roomId)) {
      return false;
    }

    // 检查包含列表
    if (includedRoomIds.isNotEmpty) {
      return includedRoomIds.contains(roomId);
    }

    // 应用过滤器
    return filter.matches(
      isDirectMessage: isDirectMessage,
      isGroup: isGroup,
      isChannel: isChannel,
      isMuted: isMuted,
      unreadCount: unreadCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        icon,
        color,
        order,
        includedRoomIds,
        excludedRoomIds,
        filter,
        showUnreadCount,
        showUnreadBadge,
        isSystem,
        unreadCount,
        unreadChatsCount,
      ];

  ChatFolderEntity copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    int? order,
    List<String>? includedRoomIds,
    List<String>? excludedRoomIds,
    ChatFolderFilter? filter,
    bool? showUnreadCount,
    bool? showUnreadBadge,
    bool? isSystem,
    int? unreadCount,
    int? unreadChatsCount,
  }) {
    return ChatFolderEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      order: order ?? this.order,
      includedRoomIds: includedRoomIds ?? this.includedRoomIds,
      excludedRoomIds: excludedRoomIds ?? this.excludedRoomIds,
      filter: filter ?? this.filter,
      showUnreadCount: showUnreadCount ?? this.showUnreadCount,
      showUnreadBadge: showUnreadBadge ?? this.showUnreadBadge,
      isSystem: isSystem ?? this.isSystem,
      unreadCount: unreadCount ?? this.unreadCount,
      unreadChatsCount: unreadChatsCount ?? this.unreadChatsCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'order': order,
      'includedRoomIds': includedRoomIds,
      'excludedRoomIds': excludedRoomIds,
      'filter': filter.toJson(),
      'showUnreadCount': showUnreadCount,
      'showUnreadBadge': showUnreadBadge,
      'isSystem': isSystem,
    };
  }

  factory ChatFolderEntity.fromJson(Map<String, dynamic> json) {
    return ChatFolderEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      order: json['order'] as int? ?? 0,
      includedRoomIds: List<String>.from((json['includedRoomIds'] as List?) ?? []),
      excludedRoomIds: List<String>.from((json['excludedRoomIds'] as List?) ?? []),
      filter: json['filter'] != null
          ? ChatFolderFilter.fromJson(json['filter'] as Map<String, dynamic>)
          : const ChatFolderFilter(),
      showUnreadCount: json['showUnreadCount'] as bool? ?? true,
      showUnreadBadge: json['showUnreadBadge'] as bool? ?? true,
      isSystem: json['isSystem'] as bool? ?? false,
    );
  }
}

/// 聊天文件夹过滤条件
class ChatFolderFilter extends Equatable {
  /// 包含私聊
  final bool includeDirectMessages;

  /// 包含群组
  final bool includeGroups;

  /// 包含频道
  final bool includeChannels;

  /// 仅显示未读
  final bool unreadOnly;

  /// 仅显示静音
  final bool mutedOnly;

  /// 仅显示非静音
  final bool unmutedOnly;

  /// 仅显示置顶
  final bool pinnedOnly;

  /// 仅显示已归档
  final bool archivedOnly;

  /// 排除已归档
  final bool excludeArchived;

  const ChatFolderFilter({
    this.includeDirectMessages = true,
    this.includeGroups = true,
    this.includeChannels = true,
    this.unreadOnly = false,
    this.mutedOnly = false,
    this.unmutedOnly = false,
    this.pinnedOnly = false,
    this.archivedOnly = false,
    this.excludeArchived = true,
  });

  /// 检查是否匹配
  bool matches({
    required bool isDirectMessage,
    required bool isGroup,
    required bool isChannel,
    required bool isMuted,
    required int unreadCount,
    bool isPinned = false,
    bool isArchived = false,
  }) {
    // 归档过滤
    if (archivedOnly && !isArchived) return false;
    if (excludeArchived && isArchived) return false;

    // 类型过滤
    if (isDirectMessage && !includeDirectMessages) return false;
    if (isGroup && !includeGroups) return false;
    if (isChannel && !includeChannels) return false;

    // 状态过滤
    if (unreadOnly && unreadCount == 0) return false;
    if (mutedOnly && !isMuted) return false;
    if (unmutedOnly && isMuted) return false;
    if (pinnedOnly && !isPinned) return false;

    return true;
  }

  @override
  List<Object?> get props => [
        includeDirectMessages,
        includeGroups,
        includeChannels,
        unreadOnly,
        mutedOnly,
        unmutedOnly,
        pinnedOnly,
        archivedOnly,
        excludeArchived,
      ];

  ChatFolderFilter copyWith({
    bool? includeDirectMessages,
    bool? includeGroups,
    bool? includeChannels,
    bool? unreadOnly,
    bool? mutedOnly,
    bool? unmutedOnly,
    bool? pinnedOnly,
    bool? archivedOnly,
    bool? excludeArchived,
  }) {
    return ChatFolderFilter(
      includeDirectMessages: includeDirectMessages ?? this.includeDirectMessages,
      includeGroups: includeGroups ?? this.includeGroups,
      includeChannels: includeChannels ?? this.includeChannels,
      unreadOnly: unreadOnly ?? this.unreadOnly,
      mutedOnly: mutedOnly ?? this.mutedOnly,
      unmutedOnly: unmutedOnly ?? this.unmutedOnly,
      pinnedOnly: pinnedOnly ?? this.pinnedOnly,
      archivedOnly: archivedOnly ?? this.archivedOnly,
      excludeArchived: excludeArchived ?? this.excludeArchived,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'includeDirectMessages': includeDirectMessages,
      'includeGroups': includeGroups,
      'includeChannels': includeChannels,
      'unreadOnly': unreadOnly,
      'mutedOnly': mutedOnly,
      'unmutedOnly': unmutedOnly,
      'pinnedOnly': pinnedOnly,
      'archivedOnly': archivedOnly,
      'excludeArchived': excludeArchived,
    };
  }

  factory ChatFolderFilter.fromJson(Map<String, dynamic> json) {
    return ChatFolderFilter(
      includeDirectMessages: json['includeDirectMessages'] as bool? ?? true,
      includeGroups: json['includeGroups'] as bool? ?? true,
      includeChannels: json['includeChannels'] as bool? ?? true,
      unreadOnly: json['unreadOnly'] as bool? ?? false,
      mutedOnly: json['mutedOnly'] as bool? ?? false,
      unmutedOnly: json['unmutedOnly'] as bool? ?? false,
      pinnedOnly: json['pinnedOnly'] as bool? ?? false,
      archivedOnly: json['archivedOnly'] as bool? ?? false,
      excludeArchived: json['excludeArchived'] as bool? ?? true,
    );
  }
}
