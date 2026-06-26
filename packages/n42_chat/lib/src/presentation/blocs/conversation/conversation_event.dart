import 'package:equatable/equatable.dart';

import '../../../domain/entities/conversation_entity.dart';

/// 会话列表事件
abstract class ConversationEvent extends Equatable {
  const ConversationEvent();

  @override
  List<Object?> get props => [];
}

/// 加载会话列表
class LoadConversations extends ConversationEvent {
  const LoadConversations();
}

/// 刷新会话列表
class RefreshConversations extends ConversationEvent {
  const RefreshConversations();
}

/// 订阅会话列表实时更新
class SubscribeConversations extends ConversationEvent {
  const SubscribeConversations();
}

/// 取消订阅
class UnsubscribeConversations extends ConversationEvent {
  const UnsubscribeConversations();
}

/// 搜索会话
class SearchConversations extends ConversationEvent {
  final String query;

  const SearchConversations(this.query);

  @override
  List<Object?> get props => [query];
}

/// 清除搜索
class ClearSearch extends ConversationEvent {
  const ClearSearch();
}

/// 设置会话免打扰
class SetConversationMuted extends ConversationEvent {
  final String conversationId;
  final bool muted;

  const SetConversationMuted({
    required this.conversationId,
    required this.muted,
  });

  @override
  List<Object?> get props => [conversationId, muted];
}

/// 设置会话置顶
class SetConversationPinned extends ConversationEvent {
  final String conversationId;
  final bool pinned;

  const SetConversationPinned({
    required this.conversationId,
    required this.pinned,
  });

  @override
  List<Object?> get props => [conversationId, pinned];
}

/// 标记会话已读
class MarkConversationAsRead extends ConversationEvent {
  final String conversationId;

  const MarkConversationAsRead(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// 删除会话
class DeleteConversation extends ConversationEvent {
  final String conversationId;

  const DeleteConversation(this.conversationId);

  @override
  List<Object?> get props => [conversationId];
}

/// 创建私聊
class CreateDirectChat extends ConversationEvent {
  final String userId;

  const CreateDirectChat(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// 创建群聊
class CreateGroupChat extends ConversationEvent {
  final String name;
  final String? topic;
  final List<String> memberIds;
  final bool encrypted;

  const CreateGroupChat({
    required this.name,
    this.topic,
    this.memberIds = const [],
    this.encrypted = true,
  });

  @override
  List<Object?> get props => [name, topic, memberIds, encrypted];
}

/// 会话列表更新（内部事件）
class ConversationsUpdated extends ConversationEvent {
  final List<ConversationEntity> conversations;

  const ConversationsUpdated(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

/// 设置会话隐藏状态
class SetConversationHidden extends ConversationEvent {
  final String conversationId;
  final bool hidden;

  const SetConversationHidden({
    required this.conversationId,
    required this.hidden,
  });

  @override
  List<Object?> get props => [conversationId, hidden];
}

/// 加载隐藏的会话列表
class LoadHiddenConversations extends ConversationEvent {
  const LoadHiddenConversations();
}

/// 清除新建会话导航信号
class ClearNewConversationNavigation extends ConversationEvent {
  const ClearNewConversationNavigation();
}
