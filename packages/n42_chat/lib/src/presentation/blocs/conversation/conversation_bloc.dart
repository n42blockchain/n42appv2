import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/local/preferences_datasource.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../../domain/repositories/conversation_repository.dart';
import 'conversation_event.dart';
import 'conversation_state.dart';
import '../../../core/utils/debug_log.dart';

/// 会话列表BLoC
class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final IConversationRepository _conversationRepository;
  final PreferencesDataSource _storageDataSource;

  StreamSubscription<List<ConversationEntity>>? _conversationsSubscription;

  ConversationBloc({
    required IConversationRepository conversationRepository,
    required PreferencesDataSource storageDataSource,
  }) : _conversationRepository = conversationRepository,
       _storageDataSource = storageDataSource,
       super(ConversationState.initial()) {
    on<LoadConversations>(_onLoadConversations);
    on<RefreshConversations>(_onRefreshConversations);
    on<SubscribeConversations>(_onSubscribeConversations);
    on<UnsubscribeConversations>(_onUnsubscribeConversations);
    on<SearchConversations>(_onSearchConversations);
    on<ClearSearch>(_onClearSearch);
    on<SetConversationMuted>(_onSetMuted);
    on<SetConversationPinned>(_onSetPinned);
    on<MarkConversationAsRead>(_onMarkAsRead);
    on<DeleteConversation>(_onDeleteConversation);
    on<CreateDirectChat>(_onCreateDirectChat);
    on<CreateGroupChat>(_onCreateGroupChat);
    on<ConversationsUpdated>(_onConversationsUpdated);
    on<SetConversationHidden>(_onSetHidden);
    on<LoadHiddenConversations>(_onLoadHiddenConversations);
    on<ClearNewConversationNavigation>(_onClearNewConversationNavigation);
  }

  @override
  Future<void> close() {
    _conversationsSubscription?.cancel();
    return super.close();
  }

  /// 加载会话列表
  Future<void> _onLoadConversations(
    LoadConversations event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final conversations = await _conversationRepository.getConversations();
      final totalUnread = await _conversationRepository.getTotalUnreadCount();

      final (pinned, normal) = _separateConversations(conversations);

      emit(
        state.copyWith(
          conversations: conversations,
          pinnedConversations: pinned,
          normalConversations: normal,
          isLoading: false,
          totalUnreadCount: totalUnread,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load conversations: ${e.toString()}',
        ),
      );
    }
  }

  /// 刷新会话列表
  Future<void> _onRefreshConversations(
    RefreshConversations event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(isRefreshing: true, clearError: true));

    try {
      final conversations = await _conversationRepository.getConversations();
      final totalUnread = await _conversationRepository.getTotalUnreadCount();

      final (pinned, normal) = _separateConversations(conversations);

      emit(
        state.copyWith(
          conversations: conversations,
          pinnedConversations: pinned,
          normalConversations: normal,
          isRefreshing: false,
          totalUnreadCount: totalUnread,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isRefreshing: false,
          error: 'Refresh failed: ${e.toString()}',
        ),
      );
    }
  }

  /// 订阅会话列表实时更新
  Future<void> _onSubscribeConversations(
    SubscribeConversations event,
    Emitter<ConversationState> emit,
  ) async {
    await _conversationsSubscription?.cancel();

    _conversationsSubscription = _conversationRepository
        .watchConversations()
        .listen(
          (conversations) {
            // 防止在 BLoC 关闭后添加事件
            if (!isClosed) {
              add(ConversationsUpdated(conversations));
            }
          },
          onError: (Object error) {
            debugLog('ConversationBloc: Conversations stream error: $error');
          },
        );
  }

  /// 取消订阅
  Future<void> _onUnsubscribeConversations(
    UnsubscribeConversations event,
    Emitter<ConversationState> emit,
  ) async {
    await _conversationsSubscription?.cancel();
    _conversationsSubscription = null;
  }

  /// 会话列表更新
  void _onConversationsUpdated(
    ConversationsUpdated event,
    Emitter<ConversationState> emit,
  ) {
    final conversations = event.conversations;
    final (pinned, normal) = _separateConversations(conversations);

    final totalUnread = conversations.fold<int>(
      0,
      (sum, conv) => sum + conv.unreadCount,
    );

    emit(
      state.copyWith(
        conversations: conversations,
        pinnedConversations: pinned,
        normalConversations: normal,
        totalUnreadCount: totalUnread,
      ),
    );
  }

  /// 搜索会话
  Future<void> _onSearchConversations(
    SearchConversations event,
    Emitter<ConversationState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(
        state.copyWith(
          isSearching: false,
          searchQuery: null,
          clearFilteredConversations: true,
        ),
      );
      return;
    }

    emit(state.copyWith(isSearching: true, searchQuery: query));

    try {
      final results = await _conversationRepository.searchConversations(query);
      emit(state.copyWith(filteredConversations: results));
    } catch (e) {
      emit(state.copyWith(error: 'Search failed: ${e.toString()}'));
    }
  }

  /// 清除搜索
  void _onClearSearch(ClearSearch event, Emitter<ConversationState> emit) {
    emit(
      state.copyWith(
        isSearching: false,
        searchQuery: null,
        clearFilteredConversations: true,
      ),
    );
  }

  /// 设置免打扰
  Future<void> _onSetMuted(
    SetConversationMuted event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      await _conversationRepository.setMuted(event.conversationId, event.muted);

      // 乐观更新本地状态
      final updatedConversations = state.conversations.map((conv) {
        if (conv.id == event.conversationId) {
          return conv.copyWith(isMuted: event.muted);
        }
        return conv;
      }).toList();

      final (pinned, normal) = _separateConversations(updatedConversations);

      emit(
        state.copyWith(
          conversations: updatedConversations,
          pinnedConversations: pinned,
          normalConversations: normal,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: 'Setting failed: ${e.toString()}'));
    }
  }

  /// 设置置顶
  Future<void> _onSetPinned(
    SetConversationPinned event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      await _conversationRepository.setPinned(
        event.conversationId,
        event.pinned,
      );

      // 乐观更新本地状态
      final updatedConversations = state.conversations.map((conv) {
        if (conv.id == event.conversationId) {
          return conv.copyWith(isPinned: event.pinned);
        }
        return conv;
      }).toList();

      final (pinned, normal) = _separateConversations(updatedConversations);

      emit(
        state.copyWith(
          conversations: updatedConversations,
          pinnedConversations: pinned,
          normalConversations: normal,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: 'Setting failed: ${e.toString()}'));
    }
  }

  /// 标记已读
  Future<void> _onMarkAsRead(
    MarkConversationAsRead event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      await _conversationRepository.markAsRead(event.conversationId);

      // 乐观更新本地状态
      final updatedConversations = state.conversations.map((conv) {
        if (conv.id == event.conversationId) {
          return conv.copyWith(unreadCount: 0, highlightCount: 0);
        }
        return conv;
      }).toList();

      final totalUnread = updatedConversations.fold<int>(
        0,
        (sum, conv) => sum + conv.unreadCount,
      );

      emit(
        state.copyWith(
          conversations: updatedConversations,
          totalUnreadCount: totalUnread,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: 'Mark as read failed: ${e.toString()}'));
    }
  }

  /// 删除会话
  Future<void> _onDeleteConversation(
    DeleteConversation event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      await _conversationRepository.deleteConversation(event.conversationId);

      // 从本地状态移除
      final updatedConversations = state.conversations
          .where((conv) => conv.id != event.conversationId)
          .toList();

      final (pinned, normal) = _separateConversations(updatedConversations);

      emit(
        state.copyWith(
          conversations: updatedConversations,
          pinnedConversations: pinned,
          normalConversations: normal,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: 'Delete failed: ${e.toString()}'));
    }
  }

  /// 创建私聊
  Future<void> _onCreateDirectChat(
    CreateDirectChat event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      final conversation = await _conversationRepository.createDirectChat(
        event.userId,
      );

      final updatedConversations = _upsertConversation(
        state.conversations,
        conversation,
      );
      final (pinned, normal) = _separateConversations(updatedConversations);
      final totalUnread = updatedConversations.fold<int>(
        0,
        (sum, conv) => sum + conv.unreadCount,
      );

      emit(
        state.copyWith(
          conversations: updatedConversations,
          pinnedConversations: pinned,
          normalConversations: normal,
          totalUnreadCount: totalUnread,
          newConversationId: conversation.id,
        ),
      );

      // 触发刷新
      add(const RefreshConversations());
    } catch (e) {
      emit(state.copyWith(error: 'Failed to create chat: ${e.toString()}'));
    }
  }

  /// 创建群聊
  Future<void> _onCreateGroupChat(
    CreateGroupChat event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      final conversation = await _conversationRepository.createGroupChat(
        name: event.name,
        topic: event.topic,
        memberIds: event.memberIds,
        encrypted: event.encrypted,
      );

      final updatedConversations = _upsertConversation(
        state.conversations,
        conversation,
      );
      final (pinned, normal) = _separateConversations(updatedConversations);
      final totalUnread = updatedConversations.fold<int>(
        0,
        (sum, conv) => sum + conv.unreadCount,
      );

      emit(
        state.copyWith(
          conversations: updatedConversations,
          pinnedConversations: pinned,
          normalConversations: normal,
          totalUnreadCount: totalUnread,
          newConversationId: conversation.id,
        ),
      );

      // 触发刷新
      add(const RefreshConversations());
    } catch (e) {
      emit(state.copyWith(error: 'Failed to create group: ${e.toString()}'));
    }
  }

  /// 分离置顶和普通会话（同时过滤隐藏的会话）
  (List<ConversationEntity>, List<ConversationEntity>) _separateConversations(
    List<ConversationEntity> conversations,
  ) {
    // 过滤掉隐藏的会话
    final visible = conversations.where((c) => !c.isHidden).toList();
    final pinned = visible.where((c) => c.isPinned).toList();
    final normal = visible.where((c) => !c.isPinned).toList();
    return (pinned, normal);
  }

  /// Applies (or lifts) the server-side push rule that backs chat hiding.
  ///
  /// Failures are logged but never rethrown: the local hide already succeeded
  /// and must not be rolled back just because the homeserver call failed.
  Future<void> _applyHiddenPushRule(
    String conversationId, {
    required bool hidden,
  }) async {
    try {
      if (hidden) {
        await _conversationRepository.setMuted(conversationId, true);
        return;
      }
      final wasMutedByUser = state.conversations
          .where((c) => c.id == conversationId)
          .map((c) => c.isMuted)
          .firstOrNull;
      if (wasMutedByUser != true) {
        await _conversationRepository.setMuted(conversationId, false);
      }
    } catch (e) {
      debugLog('Failed to sync hidden push rule for $conversationId: $e');
    }
  }

  /// 设置会话隐藏状态
  Future<void> _onSetHidden(
    SetConversationHidden event,
    Emitter<ConversationState> emit,
  ) async {
    try {
      if (event.hidden) {
        await _storageDataSource.hideChat(event.conversationId);
      } else {
        await _storageDataSource.unhideChat(event.conversationId);
      }

      // Mute the room server-side as well, not just in local preferences.
      // The client-side notification filter only runs when Dart is awake; on
      // iOS the pusher is registered without event_id_only so the push gateway
      // delivers a full APNs alert that the OS renders without waking the app,
      // which no local filter can suppress. A server push rule stops the
      // notification at the source, so hiding holds on every platform.
      // Unhiding restores the room's own mute preference rather than blindly
      // unmuting a conversation the user had muted themselves.
      await _applyHiddenPushRule(event.conversationId, hidden: event.hidden);

      // 更新会话的隐藏状态
      final updatedConversations = state.conversations.map((conv) {
        if (conv.id == event.conversationId) {
          return conv.copyWith(isHidden: event.hidden);
        }
        return conv;
      }).toList();

      final (pinned, normal) = _separateConversations(updatedConversations);

      // 如果是取消隐藏，需要从隐藏列表中移除
      List<ConversationEntity> updatedHidden = state.hiddenConversations;
      if (!event.hidden) {
        updatedHidden = state.hiddenConversations
            .where((c) => c.id != event.conversationId)
            .toList();
      } else {
        // 如果是隐藏，需要添加到隐藏列表
        final conversation = updatedConversations.firstWhere(
          (c) => c.id == event.conversationId,
          orElse: () => throw StateError('Conversation not found'),
        );
        updatedHidden = [...state.hiddenConversations, conversation];
      }

      emit(
        state.copyWith(
          conversations: updatedConversations,
          pinnedConversations: pinned,
          normalConversations: normal,
          hiddenConversations: updatedHidden,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: 'Hide failed: ${e.toString()}'));
    }
  }

  /// 加载隐藏的会话列表
  Future<void> _onLoadHiddenConversations(
    LoadHiddenConversations event,
    Emitter<ConversationState> emit,
  ) async {
    emit(state.copyWith(isLoadingHidden: true));

    try {
      final hiddenIds = await _storageDataSource.getHiddenChatIds();
      final allConversations = await _conversationRepository.getConversations();

      // 过滤出隐藏的会话
      final hiddenConversations = allConversations
          .where((c) => hiddenIds.contains(c.id))
          .map((c) => c.copyWith(isHidden: true))
          .toList();

      // 更新所有会话的隐藏状态
      final updatedConversations = allConversations.map((c) {
        if (hiddenIds.contains(c.id)) {
          return c.copyWith(isHidden: true);
        }
        return c;
      }).toList();

      final (pinned, normal) = _separateConversations(updatedConversations);

      emit(
        state.copyWith(
          conversations: updatedConversations,
          pinnedConversations: pinned,
          normalConversations: normal,
          hiddenConversations: hiddenConversations,
          isLoadingHidden: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingHidden: false,
          error: 'Failed to load hidden conversations: ${e.toString()}',
        ),
      );
    }
  }

  void _onClearNewConversationNavigation(
    ClearNewConversationNavigation event,
    Emitter<ConversationState> emit,
  ) {
    if (state.newConversationId == null) {
      return;
    }
    emit(state.copyWith(clearNewConversationId: true));
  }

  List<ConversationEntity> _upsertConversation(
    List<ConversationEntity> conversations,
    ConversationEntity conversation,
  ) {
    return <ConversationEntity>[
      conversation,
      ...conversations.where((item) => item.id != conversation.id),
    ];
  }
}
