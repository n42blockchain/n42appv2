import 'package:equatable/equatable.dart';

import '../../../domain/entities/conversation_entity.dart';

/// 会话列表状态
class ConversationState extends Equatable {
  /// 所有会话列表
  final List<ConversationEntity> conversations;

  /// 过滤后的会话列表（搜索结果）
  final List<ConversationEntity>? filteredConversations;

  /// 置顶会话
  final List<ConversationEntity> pinnedConversations;

  /// 普通会话
  final List<ConversationEntity> normalConversations;

  /// 是否正在加载
  final bool isLoading;

  /// 是否正在刷新
  final bool isRefreshing;

  /// 是否正在搜索
  final bool isSearching;

  /// 搜索关键词
  final String? searchQuery;

  /// 错误信息
  final String? error;

  /// 未读消息总数
  final int totalUnreadCount;

  /// 新创建的会话ID（用于导航）
  final String? newConversationId;

  /// 隐藏的会话列表
  final List<ConversationEntity> hiddenConversations;

  /// 是否正在加载隐藏会话
  final bool isLoadingHidden;

  const ConversationState({
    this.conversations = const [],
    this.filteredConversations,
    this.pinnedConversations = const [],
    this.normalConversations = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.isSearching = false,
    this.searchQuery,
    this.error,
    this.totalUnreadCount = 0,
    this.newConversationId,
    this.hiddenConversations = const [],
    this.isLoadingHidden = false,
  });

  /// 初始状态
  factory ConversationState.initial() {
    return const ConversationState(isLoading: true);
  }

  /// 显示的会话列表
  List<ConversationEntity> get displayConversations {
    if (isSearching && filteredConversations != null) {
      return filteredConversations!;
    }
    return conversations;
  }

  /// 是否为空
  bool get isEmpty => conversations.isEmpty;

  /// 是否有搜索结果
  bool get hasSearchResults =>
      isSearching && (filteredConversations?.isNotEmpty ?? false);

  /// 搜索无结果
  bool get noSearchResults =>
      isSearching && (filteredConversations?.isEmpty ?? true);

  ConversationState copyWith({
    List<ConversationEntity>? conversations,
    List<ConversationEntity>? filteredConversations,
    List<ConversationEntity>? pinnedConversations,
    List<ConversationEntity>? normalConversations,
    bool? isLoading,
    bool? isRefreshing,
    bool? isSearching,
    String? searchQuery,
    String? error,
    int? totalUnreadCount,
    String? newConversationId,
    List<ConversationEntity>? hiddenConversations,
    bool? isLoadingHidden,
    bool clearFilteredConversations = false,
    bool clearError = false,
    bool clearNewConversationId = false,
  }) {
    return ConversationState(
      conversations: conversations ?? this.conversations,
      filteredConversations: clearFilteredConversations
          ? null
          : (filteredConversations ?? this.filteredConversations),
      pinnedConversations: pinnedConversations ?? this.pinnedConversations,
      normalConversations: normalConversations ?? this.normalConversations,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSearching: isSearching ?? this.isSearching,
      searchQuery: searchQuery ?? this.searchQuery,
      error: clearError ? null : (error ?? this.error),
      totalUnreadCount: totalUnreadCount ?? this.totalUnreadCount,
      newConversationId: clearNewConversationId
          ? null
          : (newConversationId ?? this.newConversationId),
      hiddenConversations: hiddenConversations ?? this.hiddenConversations,
      isLoadingHidden: isLoadingHidden ?? this.isLoadingHidden,
    );
  }

  @override
  List<Object?> get props => [
        conversations,
        filteredConversations,
        pinnedConversations,
        normalConversations,
        isLoading,
        isRefreshing,
        isSearching,
        searchQuery,
        error,
        totalUnreadCount,
        newConversationId,
        hiddenConversations,
        isLoadingHidden,
      ];
}

