import 'package:equatable/equatable.dart';

import 'contact_entity.dart';
import 'conversation_entity.dart';
import 'message_entity.dart';

/// 搜索结果类型
enum SearchResultType {
  /// 联系人
  contact,

  /// 群聊
  group,

  /// 会话
  conversation,

  /// 消息
  message,

  /// 全部
  all,
}

class MessageSearchFilter extends Equatable {
  static const Object _unset = Object();

  final String? senderId;
  final MessageType? messageType;
  final DateTime? sentAfter;
  final DateTime? sentBefore;
  final bool onlyFromMe;
  final bool hasMediaOnly;

  const MessageSearchFilter({
    this.senderId,
    this.messageType,
    this.sentAfter,
    this.sentBefore,
    this.onlyFromMe = false,
    this.hasMediaOnly = false,
  });

  bool get isEmpty =>
      (senderId == null || senderId!.isEmpty) &&
      messageType == null &&
      sentAfter == null &&
      sentBefore == null &&
      !onlyFromMe &&
      !hasMediaOnly;

  int get activeCount {
    var count = 0;
    if (senderId != null && senderId!.isNotEmpty) {
      count++;
    }
    if (messageType != null) {
      count++;
    }
    if (sentAfter != null || sentBefore != null) {
      count++;
    }
    if (onlyFromMe) {
      count++;
    }
    if (hasMediaOnly) {
      count++;
    }
    return count;
  }

  MessageSearchFilter copyWith({
    Object? senderId = _unset,
    Object? messageType = _unset,
    Object? sentAfter = _unset,
    Object? sentBefore = _unset,
    bool? onlyFromMe,
    bool? hasMediaOnly,
  }) {
    return MessageSearchFilter(
      senderId: identical(senderId, _unset)
          ? this.senderId
          : senderId as String?,
      messageType: identical(messageType, _unset)
          ? this.messageType
          : messageType as MessageType?,
      sentAfter: identical(sentAfter, _unset)
          ? this.sentAfter
          : sentAfter as DateTime?,
      sentBefore: identical(sentBefore, _unset)
          ? this.sentBefore
          : sentBefore as DateTime?,
      onlyFromMe: onlyFromMe ?? this.onlyFromMe,
      hasMediaOnly: hasMediaOnly ?? this.hasMediaOnly,
    );
  }

  @override
  List<Object?> get props => [
    senderId,
    messageType,
    sentAfter,
    sentBefore,
    onlyFromMe,
    hasMediaOnly,
  ];
}

/// 搜索结果项
class SearchResultItem extends Equatable {
  /// 结果类型
  final SearchResultType type;

  /// 唯一标识符
  final String id;

  /// 标题（联系人名/群名/会话名）
  final String title;

  /// 副标题/描述
  final String? subtitle;

  /// 头像URL
  final String? avatarUrl;

  /// 匹配的关键词
  final String? matchedKeyword;

  /// 匹配的内容（用于消息搜索）
  final String? matchedContent;

  /// 时间戳
  final DateTime? timestamp;

  /// 关联的房间ID
  final String? roomId;

  /// 原始数据
  final Object? rawData;

  const SearchResultItem({
    required this.type,
    required this.id,
    required this.title,
    this.subtitle,
    this.avatarUrl,
    this.matchedKeyword,
    this.matchedContent,
    this.timestamp,
    this.roomId,
    this.rawData,
  });

  /// 从联系人创建
  factory SearchResultItem.fromContact(
    ContactEntity contact, {
    String? matchedKeyword,
  }) {
    return SearchResultItem(
      type: SearchResultType.contact,
      id: contact.userId,
      title: contact.effectiveDisplayName,
      subtitle: contact.statusMessage ?? contact.userId,
      avatarUrl: contact.avatarUrl,
      matchedKeyword: matchedKeyword,
      rawData: contact,
    );
  }

  /// 从会话创建
  factory SearchResultItem.fromConversation(
    ConversationEntity conversation, {
    String? matchedKeyword,
  }) {
    return SearchResultItem(
      type: conversation.isGroup
          ? SearchResultType.group
          : SearchResultType.conversation,
      id: conversation.id,
      title: conversation.name,
      subtitle: conversation.lastMessage,
      avatarUrl: conversation.avatarUrl,
      matchedKeyword: matchedKeyword,
      timestamp: conversation.lastMessageTime,
      roomId: conversation.id,
      rawData: conversation,
    );
  }

  /// 从消息创建
  factory SearchResultItem.fromMessage(
    MessageEntity message, {
    required String roomId,
    required String roomName,
    String? roomAvatarUrl,
    String? matchedKeyword,
  }) {
    return SearchResultItem(
      type: SearchResultType.message,
      id: message.id,
      title: roomName,
      subtitle: message.senderName.isNotEmpty
          ? message.senderName
          : message.senderId,
      avatarUrl: roomAvatarUrl,
      matchedKeyword: matchedKeyword,
      matchedContent: message.content,
      timestamp: message.timestamp,
      roomId: roomId,
      rawData: message,
    );
  }

  @override
  List<Object?> get props => [
    type,
    id,
    title,
    subtitle,
    avatarUrl,
    matchedKeyword,
    matchedContent,
    timestamp,
    roomId,
  ];
}

/// 搜索结果集合
class SearchResults extends Equatable {
  /// 联系人结果
  final List<SearchResultItem> contacts;

  /// 群聊结果
  final List<SearchResultItem> groups;

  /// 会话结果
  final List<SearchResultItem> conversations;

  /// 消息结果
  final List<SearchResultItem> messages;

  /// 搜索关键词
  final String query;

  /// 是否正在搜索
  final bool isSearching;

  /// 是否有更多结果
  final bool hasMore;

  /// 当前消息检索过滤条件
  final MessageSearchFilter? messageFilter;

  const SearchResults({
    this.contacts = const [],
    this.groups = const [],
    this.conversations = const [],
    this.messages = const [],
    this.query = '',
    this.isSearching = false,
    this.hasMore = false,
    this.messageFilter,
  });

  /// 所有结果
  List<SearchResultItem> get allResults => [
    ...contacts,
    ...groups,
    ...conversations,
    ...messages,
  ];

  /// 总结果数
  int get totalCount =>
      contacts.length + groups.length + conversations.length + messages.length;

  /// 是否为空
  bool get isEmpty => totalCount == 0;

  /// 是否有联系人结果
  bool get hasContacts => contacts.isNotEmpty;

  /// 是否有群聊结果
  bool get hasGroups => groups.isNotEmpty;

  /// 是否有会话结果
  bool get hasConversations => conversations.isNotEmpty;

  /// 是否有消息结果
  bool get hasMessages => messages.isNotEmpty;

  @override
  List<Object?> get props => [
    contacts,
    groups,
    conversations,
    messages,
    query,
    isSearching,
    hasMore,
    messageFilter,
  ];

  SearchResults copyWith({
    List<SearchResultItem>? contacts,
    List<SearchResultItem>? groups,
    List<SearchResultItem>? conversations,
    List<SearchResultItem>? messages,
    String? query,
    bool? isSearching,
    bool? hasMore,
    Object? messageFilter = MessageSearchFilter._unset,
  }) {
    return SearchResults(
      contacts: contacts ?? this.contacts,
      groups: groups ?? this.groups,
      conversations: conversations ?? this.conversations,
      messages: messages ?? this.messages,
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      hasMore: hasMore ?? this.hasMore,
      messageFilter: identical(messageFilter, MessageSearchFilter._unset)
          ? this.messageFilter
          : messageFilter as MessageSearchFilter?,
    );
  }
}

/// 聊天内搜索结果
class ChatSearchResults extends Equatable {
  /// 消息结果
  final List<MessageEntity> messages;

  /// 搜索关键词
  final String query;

  /// 房间ID
  final String roomId;

  /// 当前索引（用于导航）
  final int currentIndex;

  /// 是否正在搜索
  final bool isSearching;

  /// 是否有更多结果
  final bool hasMore;

  /// 当前消息检索过滤条件
  final MessageSearchFilter? filter;

  const ChatSearchResults({
    this.messages = const [],
    this.query = '',
    this.roomId = '',
    this.currentIndex = 0,
    this.isSearching = false,
    this.hasMore = false,
    this.filter,
  });

  /// 总结果数
  int get totalCount => messages.length;

  /// 是否为空
  bool get isEmpty => messages.isEmpty;

  /// 当前消息
  MessageEntity? get currentMessage {
    if (messages.isEmpty ||
        currentIndex < 0 ||
        currentIndex >= messages.length) {
      return null;
    }
    return messages[currentIndex];
  }

  /// 是否有上一条
  bool get hasPrevious => currentIndex > 0;

  /// 是否有下一条
  bool get hasNext => currentIndex < messages.length - 1;

  @override
  List<Object?> get props => [
    messages,
    query,
    roomId,
    currentIndex,
    isSearching,
    hasMore,
    filter,
  ];

  ChatSearchResults copyWith({
    List<MessageEntity>? messages,
    String? query,
    String? roomId,
    int? currentIndex,
    bool? isSearching,
    bool? hasMore,
    Object? filter = MessageSearchFilter._unset,
  }) {
    return ChatSearchResults(
      messages: messages ?? this.messages,
      query: query ?? this.query,
      roomId: roomId ?? this.roomId,
      currentIndex: currentIndex ?? this.currentIndex,
      isSearching: isSearching ?? this.isSearching,
      hasMore: hasMore ?? this.hasMore,
      filter: identical(filter, MessageSearchFilter._unset)
          ? this.filter
          : filter as MessageSearchFilter?,
    );
  }
}
