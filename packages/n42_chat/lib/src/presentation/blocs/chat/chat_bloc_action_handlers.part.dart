part of 'chat_bloc.dart';

/// 消息操作相关 handler 方法
///
/// 包含：重发、撤回、本地删除、删除失败消息、回复、设置回复/编辑目标、
/// 表情回应、已读回执、输入状态、清理聊天室、清空聊天记录、
/// 斜杠命令、举报消息等。
extension ChatBlocActionHandlers on ChatBloc {
  /// 重发消息
  Future<void> onResendMessage(
    ResendMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null) return;

    try {
      await _messageRepository.resendMessage(_currentRoomId!, event.messageId);
      // 旧的 EventStatus.error 事件仍在 SDK 时间线中，将其 ID 加入本地删除集合
      // 防止 scanFailedMessages 将旧事件重新入队形成死循环。
      _locallyDeletedMessageIds.add(event.messageId);
      // 允许新事件（由 resendMessage 创建）被自动重试系统处理
      _permanentlyFailedMessages.remove(event.messageId);
    } catch (e) {
      emit(state.copyWith(error: 'Failed to resend'));
    }
  }

  /// 撤回消息
  ///
  /// 遵循 Matrix 规范与微信行为：撤回不删除消息条目，而是将其原地更新为
  /// [MessageType.redacted]，保持消息在列表中的位置，仅内容替换为"已撤回"提示。
  ///
  /// 旧逻辑（直接删除）会导致：
  ///   撤回 -> 消息消失 -> 服务器确认后 BLoC 删除 -> sync 到来 -> 消息重新出现
  /// 新逻辑（原地标记）：
  ///   撤回 -> 消息立即标记为 redacted（UI 持续显示"已撤回"）-> sync 到来不变
  Future<void> onRedactMessage(
    RedactMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null) return;

    // 保存原始消息列表，用于失败时回滚
    final originalMessages = List<MessageEntity>.unmodifiable(state.messages);

    // 立即在本地将消息标记为已撤回（乐观更新）
    // 使消息立即显示为"已撤回"提示，而不是消失
    final optimisticMessages = state.messages.map((m) {
      if (m.id == event.messageId) {
        return m.copyWith(type: MessageType.redacted, content: '');
      }
      return m;
    }).toList();
    emit(state.copyWith(messages: optimisticMessages));

    try {
      await _messageRepository.redactMessage(
        _currentRoomId!,
        event.messageId,
        reason: event.reason,
      );
      // 服务器确认后无需额外操作：
      // Matrix sync 会将该事件重新推回，onMessagesUpdated 中会以
      // MessageType.redacted 合并，与当前状态一致，不会产生闪烁。
    } catch (e) {
      // 服务器撤回失败：回滚乐观更新，恢复原始消息列表
      debugLog('ChatBloc: Failed to redact message ${event.messageId}: $e');
      emit(
        state.copyWith(messages: originalMessages, error: 'Failed to recall'),
      );
    }
  }

  /// 本地删除消息（不发送到服务器）
  Future<void> onDeleteMessagesLocally(
    DeleteMessagesLocally event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null) return;

    final idsToDelete = event.messageIds.toSet();

    // 将删除的消息ID添加到内存集合中，防止被消息订阅恢复
    _locallyDeletedMessageIds.addAll(idsToDelete);
    debugLog('ChatBloc: Locally deleted message IDs: $idsToDelete');

    // 立即更新 UI
    final updatedMessages = state.messages
        .where((m) => !idsToDelete.contains(m.id))
        .toList();
    emit(state.copyWith(messages: updatedMessages));

    // 持久化到存储（异步，不阻塞 UI）
    try {
      await _messageRepository.markMessagesAsLocallyDeleted(
        _currentRoomId!,
        event.messageIds,
      );
      debugLog(
        'ChatBloc: Persisted ${event.messageIds.length} deleted message IDs to storage',
      );
    } catch (e) {
      debugLog('ChatBloc: Failed to persist deleted message IDs: $e');
    }
  }

  /// 删除发送失败的消息（从本地和服务器）
  Future<void> onDeleteFailedMessage(
    DeleteFailedMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null) return;

    final roomId = _currentRoomId!;
    final messageId = event.messageId;

    debugLog('ChatBloc: Deleting failed message: $messageId');

    // 先从 UI 中移除
    _locallyDeletedMessageIds.add(messageId);
    final updatedMessages = state.messages
        .where((m) => m.id != messageId)
        .toList();

    if (!isClosed) {
      emit(state.copyWith(messages: updatedMessages));
    }

    // 然后尝试从服务器/本地数据库中删除（不需要 emit，所以可以在 bloc 关闭后继续）
    try {
      await _messageRepository.deleteFailedMessage(roomId, messageId);
      debugLog(
        'ChatBloc: Successfully deleted failed message from server/local',
      );
    } catch (e) {
      debugLog('ChatBloc: Error deleting failed message: $e');
    }
  }

  /// 回复消息
  Future<void> onReplyToMessage(
    ReplyToMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null) return;

    emit(state.copyWith(isSending: true, clearError: true));

    try {
      final selfDestructAfter = await _resolveSelfDestructAfter(
        event.selfDestructAfter,
      );
      await _messageRepository.replyToMessage(
        _currentRoomId!,
        event.replyToMessageId,
        event.text,
        selfDestructAfter: selfDestructAfter,
        mentionedUserIds: event.mentionedUserIds,
        mentionsRoom: event.mentionsRoom,
      );
      emit(state.copyWith(isSending: false, clearReplyTarget: true));
    } catch (e) {
      emit(state.copyWith(isSending: false, error: 'Failed to reply'));
    }
  }

  /// 设置回复目标
  void onSetReplyTarget(SetReplyTarget event, Emitter<ChatState> emit) {
    if (event.message == null) {
      emit(state.copyWith(clearReplyTarget: true));
    } else {
      // 进入回复模式时清除编辑模式
      emit(
        state.copyWith(replyTarget: event.message, clearEditingMessage: true),
      );
    }
  }

  /// 设置编辑目标（进入/退出编辑模式）
  void onSetEditTarget(SetEditTarget event, Emitter<ChatState> emit) {
    if (event.message == null) {
      emit(state.copyWith(clearEditingMessage: true));
    } else {
      // 进入编辑模式时清除回复目标
      emit(
        state.copyWith(editingMessage: event.message, clearReplyTarget: true),
      );
    }
  }

  /// 添加表情回应
  Future<void> onAddReaction(AddReaction event, Emitter<ChatState> emit) async {
    if (_currentRoomId == null) return;

    try {
      // 先立即更新本地UI，显示表情回应
      final currentUserId = await _messageRepository.getCurrentUserId();
      final updatedMessages = state.messages.map((msg) {
        if (msg.id == event.messageId) {
          // 查找是否已有该表情的回应
          final existingReactionIndex = msg.reactions.indexWhere(
            (r) => r.key == event.emoji,
          );

          List<MessageReaction> newReactions;
          if (existingReactionIndex >= 0) {
            // 已有该表情，增加计数
            final existingReaction = msg.reactions[existingReactionIndex];
            final actorId = currentUserId ?? 'me';
            if (existingReaction.userIds.contains(actorId)) {
              // 用户已经回应过，移除回应
              final newUserIds = existingReaction.userIds
                  .where((id) => id != actorId)
                  .toList();
              final newAggregateCount = existingReaction.aggregateCount == null
                  ? null
                  : (existingReaction.count > 0
                        ? existingReaction.count - 1
                        : 0);
              if (newUserIds.isEmpty &&
                  (newAggregateCount == null || newAggregateCount == 0)) {
                // 没有人回应了，移除整个表情
                newReactions = [...msg.reactions]
                  ..removeAt(existingReactionIndex);
              } else {
                newReactions = [...msg.reactions];
                newReactions[existingReactionIndex] = MessageReaction(
                  key: existingReaction.key,
                  userIds: newUserIds,
                  isMe: newUserIds.contains(actorId),
                  aggregateCount: newAggregateCount,
                );
              }
            } else {
              // 用户没有回应过，添加回应
              newReactions = [...msg.reactions];
              final newAggregateCount = existingReaction.aggregateCount == null
                  ? null
                  : existingReaction.count + 1;
              newReactions[existingReactionIndex] = MessageReaction(
                key: existingReaction.key,
                userIds: [...existingReaction.userIds, actorId],
                isMe: true,
                aggregateCount: newAggregateCount,
              );
            }
          } else {
            // 新的表情回应
            newReactions = [
              ...msg.reactions,
              MessageReaction(
                key: event.emoji,
                userIds: [currentUserId ?? 'me'],
                isMe: true,
              ),
            ];
          }

          return msg.copyWith(reactions: newReactions);
        }
        return msg;
      }).toList();

      emit(state.copyWith(messages: updatedMessages));

      // 发送到服务器
      await _messageRepository.addReaction(
        _currentRoomId!,
        event.messageId,
        event.emoji,
      );
      debugLog(
        'ChatBloc: Reaction $event.emoji added to message ${event.messageId}',
      );
    } catch (e) {
      debugLog('ChatBloc: Failed to add reaction: $e');
      emit(state.copyWith(error: 'Failed to add reaction'));
    }
  }

  /// 标记消息已读
  ///
  /// 根据用户隐私设置决定是否发送已读回执
  Future<void> onMarkMessageAsRead(
    MarkMessageAsRead event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null) return;

    try {
      // 检查隐私设置：是否允许发送已读回执
      final shouldSendReadReceipts = await _secureStorage
          .shouldShowReadReceipts();
      if (!shouldSendReadReceipts) {
        debugLog('ChatBloc: Skipping read receipt due to privacy settings');
        return;
      }

      await _messageRepository.markAsRead(_currentRoomId!, event.messageId);
    } catch (e) {
      // 静默失败
      debugLog('Error: $e');
    }
  }

  /// 发送正在输入状态
  ///
  /// 根据用户隐私设置决定是否发送输入状态
  Future<void> onSendTypingNotification(
    SendTypingNotification event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null) return;

    try {
      // 检查隐私设置：是否允许发送输入状态
      final shouldSendTypingIndicator = await _secureStorage
          .shouldShowTypingIndicator();
      if (!shouldSendTypingIndicator) {
        debugLog(
          'ChatBloc: Skipping typing notification due to privacy settings',
        );
        return;
      }

      await _messageRepository.sendTypingNotification(
        _currentRoomId!,
        event.isTyping,
      );
    } catch (e) {
      // 静默失败
      debugLog('Error: $e');
    }
  }

  /// 清理聊天室
  Future<void> onDisposeChat(DisposeChat event, Emitter<ChatState> emit) async {
    await _messagesSubscription?.cancel();
    _messagesSubscription = null;
    _typingUsersTimer?.cancel();
    _typingUsersTimer = null;
    await _syncStatusSubscription?.cancel();
    _syncStatusSubscription = null;
    _retryTimer?.cancel();
    _retryTimer = null;
    _pendingRetryMessages.clear();
    _permanentlyFailedMessages.clear();
    _currentRoomId = null;
    _locallyDeletedMessageIds.clear();
    if (!isClosed) {
      emit(ChatState.initial());
    }
  }

  /// 清空聊天记录（本地）
  Future<void> onClearChatHistory(
    ClearChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    debugLog('ChatBloc: Clearing chat history for room $_currentRoomId');

    // 清空本地消息列表
    _locallyDeletedMessageIds.addAll(state.messages.map((m) => m.id));

    if (!isClosed) {
      emit(state.copyWith(messages: [], clearError: true));
    }
  }

  /// 清除待处理的斜杠命令信号
  void _onClearPendingCommand(
    ClearPendingCommand event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(clearPendingCommand: true));
  }

  /// 执行斜杠命令
  Future<void> onExecuteSlashCommand(
    ExecuteSlashCommand event,
    Emitter<ChatState> emit,
  ) async {
    switch (event.command) {
      case 'announce':
        if (event.args.isNotEmpty && _currentRoomId != null) {
          add(SendSystemNotice(event.args));
        }
        break;
      case 'poll':
        // BLoC 无 context，通过 pendingCommand 信号通知 UI 打开 Poll 对话框
        emit(state.copyWith(pendingCommand: 'poll'));
        break;
      default:
        debugLog('ChatBloc: Unknown slash command: ${event.command}');
    }
  }

  /// 举报消息
  Future<void> onReportMessage(
    ReportMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null) return;
    try {
      await _messageRepository.reportMessage(
        _currentRoomId!,
        event.messageId,
        reason: event.reason,
      );
      // 通过 error 字段发送成功信号（使用特殊前缀区分）
      emit(state.copyWith(error: 'success:report'));
    } catch (e) {
      debugLog('ChatBloc: Failed to report message: $e');
      emit(state.copyWith(error: 'Failed to report message'));
    }
  }
}
