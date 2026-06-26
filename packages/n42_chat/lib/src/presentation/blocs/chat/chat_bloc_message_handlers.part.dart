part of 'chat_bloc.dart';

/// 消息加载/订阅/更新/过滤相关 handler 方法
extension ChatBlocMessageHandlers on ChatBloc {
  /// 加载消息
  Future<void> onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final messages = await _messageRepository.getMessages(
        event.roomId,
        limit: event.limit,
      );

      // 构建当前消息的索引 Map (O(n) 而不是 O(n²))
      final currentMessagesMap = <String, MessageEntity>{};
      for (final msg in state.messages) {
        currentMessagesMap[msg.id] = msg;
      }

      // 保留之前的 reactions（服务器聚合可能需要时间）
      var mergedMessages = messages.map((newMsg) {
        final currentMsg = currentMessagesMap[newMsg.id];
        if (currentMsg == null) return newMsg;

        // 如果当前消息有 reactions 但新消息没有，保留当前的 reactions
        if (currentMsg.reactions.isNotEmpty && newMsg.reactions.isEmpty) {
          return newMsg.copyWith(reactions: currentMsg.reactions);
        }
        // 合并 reactions（服务器可能有其他用户的 reactions）
        if (currentMsg.reactions.isNotEmpty && newMsg.reactions.isNotEmpty) {
          // 使用新消息的 reactions，但保留本地添加的
          final mergedReactions = <String, MessageReaction>{};
          // 先添加服务器的 reactions
          for (final r in newMsg.reactions) {
            mergedReactions[r.key] = r;
          }
          // 再添加本地的 reactions（如果服务器没有）
          for (final r in currentMsg.reactions) {
            if (!mergedReactions.containsKey(r.key)) {
              mergedReactions[r.key] = r;
            }
          }
          return newMsg.copyWith(reactions: mergedReactions.values.toList());
        }
        return newMsg;
      }).toList();

      // 获取投票消息的聚合结果
      mergedMessages = await _loadPollAggregations(
        event.roomId,
        mergedMessages,
      );

      // 获取消息的反应聚合结果
      mergedMessages = await _loadReactionAggregations(
        event.roomId,
        mergedMessages,
      );

      // 应用关键词过滤
      mergedMessages = _applyContentFilter(mergedMessages);

      emit(
        state.copyWith(
          messages: mergedMessages,
          isLoading: false,
          hasMore: messages.length >= event.limit,
        ),
      );

      // 标记最新消息已读
      if (messages.isNotEmpty) {
        await _messageRepository.markAsRead(event.roomId, messages.first.id);
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load messages: ${e.toString()}',
        ),
      );
    }
  }

  /// 加载投票消息的聚合结果
  Future<List<MessageEntity>> _loadPollAggregations(
    String roomId,
    List<MessageEntity> messages,
  ) async {
    final pollMessages = messages
        .where((m) => m.type == MessageType.poll)
        .toList();
    if (pollMessages.isEmpty) return messages;

    final updatedMessages = List<MessageEntity>.from(messages);

    for (final pollMsg in pollMessages) {
      try {
        final aggregations = await _messageRepository.getPollAggregations(
          roomId,
          pollMsg.id,
        );

        if (aggregations != null) {
          final voteCounts =
              (aggregations['voteCounts'] as Map<String, dynamic>?)
                  ?.cast<String, int>() ??
              {};
          final totalVoters = aggregations['totalVoters'] as int? ?? 0;
          final myVotes =
              (aggregations['myVotes'] as List<dynamic>?)?.cast<String>() ?? [];
          final pollEnded = aggregations['pollEnded'] as bool? ?? false;

          final index = updatedMessages.indexWhere((m) => m.id == pollMsg.id);
          if (index != -1 && pollMsg.metadata != null) {
            updatedMessages[index] = pollMsg.copyWith(
              metadata: pollMsg.metadata!.copyWithPoll(
                pollEnded: pollEnded,
                voteCounts: voteCounts,
                totalVoters: totalVoters,
                myVotes: myVotes,
              ),
            );
          }
        }
      } catch (e) {
        debugLog(
          'ChatBloc: Failed to load poll aggregations for ${pollMsg.id}: $e',
        );
      }
    }

    return updatedMessages;
  }

  /// 加载消息的反应聚合结果
  ///
  /// 优化：使用 Future.wait() 并行请求，将加载时间从 5s 降至约 500ms
  Future<List<MessageEntity>> _loadReactionAggregations(
    String roomId,
    List<MessageEntity> messages,
  ) async {
    // 只检查最近的一些消息，因为旧消息可能没有反应
    final messagesToCheck = messages.take(50).toList();
    if (messagesToCheck.isEmpty) return messages;

    final updatedMessages = List<MessageEntity>.from(messages);

    // 并行请求所有消息的 reactions（最多 10 个并发）
    const batchSize = 10;
    for (var i = 0; i < messagesToCheck.length; i += batchSize) {
      final batch = messagesToCheck.skip(i).take(batchSize).toList();

      final futures = batch.map((msg) async {
        try {
          final aggregations = await _messageRepository.getReactionAggregations(
            roomId,
            msg.id,
          );
          return (msg.id, aggregations);
        } catch (e) {
          debugLog(
            'ChatBloc: Failed to load reaction aggregations for ${msg.id}: $e',
          );
          return (msg.id, null);
        }
      });

      final results = await Future.wait(futures);

      for (final (msgId, aggregations) in results) {
        if (aggregations == null) continue;

        final reactionsData =
            aggregations['reactions'] as Map<String, dynamic>?;
        if (reactionsData == null || reactionsData.isEmpty) continue;

        final reactions = <MessageReaction>[];
        for (final entry in reactionsData.entries) {
          final emoji = entry.key;
          final data = entry.value as Map<String, dynamic>;
          final userIds = (data['userIds'] as List<String>?) ?? [];
          final isMe = data['isMe'] as bool? ?? false;

          reactions.add(
            MessageReaction(key: emoji, userIds: userIds, isMe: isMe),
          );
        }

        if (reactions.isNotEmpty) {
          final index = updatedMessages.indexWhere((m) => m.id == msgId);
          if (index != -1) {
            final originalMsg = updatedMessages[index];
            updatedMessages[index] = originalMsg.copyWith(reactions: reactions);
          }
        }
      }
    }

    return updatedMessages;
  }

  /// 加载更多历史消息
  Future<void> onLoadMoreMessages(
    LoadMoreMessages event,
    Emitter<ChatState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore || _currentRoomId == null) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final moreMessages = await _messageRepository.loadMoreMessages(
        _currentRoomId!,
        limit: 50,
      );

      emit(
        state.copyWith(
          messages: moreMessages,
          isLoadingMore: false,
          hasMore: moreMessages.length > state.messages.length,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          error: 'Failed to load more messages',
        ),
      );
    }
  }

  /// 订阅消息更新
  Future<void> onSubscribeMessages(
    SubscribeMessages event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null) return;

    await _messagesSubscription?.cancel();

    _messagesSubscription = _messageRepository
        .watchMessages(_currentRoomId!)
        .listen(
          (messages) {
            // 防止在 BLoC 关闭后添加事件
            if (!isClosed) {
              add(MessagesUpdated(messages));
            }
          },
          onError: (Object error) {
            debugLog('ChatBloc: Messages stream error: $error');
          },
        );
  }

  /// 取消订阅
  Future<void> onUnsubscribeMessages(
    UnsubscribeMessages event,
    Emitter<ChatState> emit,
  ) async {
    await _messagesSubscription?.cancel();
    _messagesSubscription = null;
  }

  List<String> _resolveCurrentTypingUsers() {
    final roomId = _currentRoomId;
    final client = _clientManager?.client;
    if (roomId == null || client == null) {
      return const [];
    }

    final room = client.getRoomById(roomId);
    if (room == null) {
      return const [];
    }

    final currentUserId = client.userID;
    final names = <String>[];

    for (final user in room.typingUsers) {
      if (user.id == currentUserId) {
        continue;
      }

      final displayName = user.calcDisplayname().trim();
      final label = displayName.isNotEmpty ? displayName : user.id;
      if (!names.contains(label)) {
        names.add(label);
      }
    }

    return List.unmodifiable(names);
  }

  void _scheduleTypingUsersRefresh(List<String> typingUsers) {
    _typingUsersTimer?.cancel();
    _typingUsersTimer = null;

    if (typingUsers.isEmpty || isClosed) {
      return;
    }

    final timeout =
        _clientManager?.client?.typingIndicatorTimeout ??
        const Duration(seconds: 30);
    _typingUsersTimer = Timer(timeout + const Duration(milliseconds: 250), () {
      if (!isClosed) {
        add(TypingUsersUpdated(_resolveCurrentTypingUsers()));
      }
    });
  }

  /// 消息列表更新
  void onMessagesUpdated(MessagesUpdated event, Emitter<ChatState> emit) {
    // 过滤掉已本地删除的消息和线程内回复消息（线程回复只在线程详情页显示）
    final filteredMessages = event.messages
        .where((m) => !_locallyDeletedMessageIds.contains(m.id))
        .where((m) => !m.isInThread)
        .toList();

    // 构建当前消息的索引 Map (O(n) 而不是 O(n²))
    final currentMessagesMap = <String, MessageEntity>{};
    for (final msg in state.messages) {
      currentMessagesMap[msg.id] = msg;
    }

    // 保留本地添加的 reactions 和投票状态（服务器聚合可能需要时间）
    final mergedMessages = filteredMessages.map((newMsg) {
      // 查找当前状态中的同一消息
      final currentMsg = currentMessagesMap[newMsg.id];
      if (currentMsg == null) return newMsg;

      // 防止已撤回的消息被 sync 事件"恢复"成原始内容。
      // Matrix 协议保证消息一旦被 redact 就永远是 redacted，但本地乐观更新时
      // 可能 sync 先带来旧事件（历史分页等），需在此兜底。
      if (currentMsg.type == MessageType.redacted &&
          newMsg.type != MessageType.redacted) {
        return currentMsg;
      }

      // 如果当前消息有 reactions 但新消息没有，保留当前的 reactions
      if (currentMsg.reactions.isNotEmpty && newMsg.reactions.isEmpty) {
        newMsg = newMsg.copyWith(reactions: currentMsg.reactions);
      }

      // 保留投票消息的本地状态（服务器聚合需要时间）
      if (newMsg.type == MessageType.poll &&
          currentMsg.type == MessageType.poll &&
          currentMsg.metadata != null) {
        final currentMeta = currentMsg.metadata!;
        final newMeta = newMsg.metadata;

        // 如果本地有投票数据但服务器返回的没有，保留本地数据
        if ((currentMeta.totalVoters ?? 0) > 0 &&
            (newMeta?.totalVoters ?? 0) == 0) {
          newMsg = newMsg.copyWith(metadata: currentMeta);
        }
        // 如果本地有我的投票但服务器返回的没有，保留本地数据
        else if ((currentMeta.myVotes?.isNotEmpty ?? false) &&
            (newMeta?.myVotes?.isEmpty ?? true)) {
          newMsg = newMsg.copyWith(
            metadata: MessageMetadata(
              pollQuestion: newMeta?.pollQuestion ?? currentMeta.pollQuestion,
              pollOptions: newMeta?.pollOptions ?? currentMeta.pollOptions,
              pollOptionIds:
                  newMeta?.pollOptionIds ?? currentMeta.pollOptionIds,
              maxSelections:
                  newMeta?.maxSelections ?? currentMeta.maxSelections,
              pollEnded: newMeta?.pollEnded ?? currentMeta.pollEnded,
              voteCounts: currentMeta.voteCounts,
              totalVoters: currentMeta.totalVoters,
              myVotes: currentMeta.myVotes,
              // 保留其他元数据
              mediaUrl: newMeta?.mediaUrl,
              httpUrl: newMeta?.httpUrl,
              thumbnailUrl: newMeta?.thumbnailUrl,
              mimeType: newMeta?.mimeType,
              size: newMeta?.size,
              width: newMeta?.width,
              height: newMeta?.height,
              duration: newMeta?.duration,
              fileName: newMeta?.fileName,
              isPlayed: newMeta?.isPlayed,
              waveform: newMeta?.waveform,
              latitude: newMeta?.latitude,
              longitude: newMeta?.longitude,
              locationName: newMeta?.locationName,
              amount: newMeta?.amount,
              token: newMeta?.token,
              transferStatus: newMeta?.transferStatus,
              txHash: newMeta?.txHash,
            ),
          );
        }
      }

      return newMsg;
    }).toList();

    final typingUsers = _resolveCurrentTypingUsers();

    if (!isClosed) {
      emit(state.copyWith(messages: mergedMessages, typingUsers: typingUsers));
      _scheduleTypingUsersRefresh(typingUsers);

      // 扫描失败消息加入自动重试队列
      ChatBlocRetryHandlers(this).scanFailedMessages();

      // 自动翻译新收到的消息
      if (state.autoTranslate && _translationService != null) {
        _autoTranslateMessages(emit);
      }

      // 智能回复翻译：检测对方最近消息语言
      if (state.smartReplyTranslate && _translationService != null) {
        _detectRecipientLanguage(emit);
      }
    }
  }

  void onTypingUsersUpdated(TypingUsersUpdated event, Emitter<ChatState> emit) {
    if (listEquals(state.typingUsers, event.typingUsers)) {
      _scheduleTypingUsersRefresh(event.typingUsers);
      return;
    }

    emit(state.copyWith(typingUsers: event.typingUsers));
    _scheduleTypingUsersRefresh(event.typingUsers);
  }

  /// 应用关键词过滤
  List<MessageEntity> _applyContentFilter(List<MessageEntity> messages) {
    final filter = state.contentFilter;
    if (filter == null || !filter.enabled) {
      return messages;
    }
    final filtered = <MessageEntity>[];
    for (final m in messages) {
      if (m.type != MessageType.text) {
        filtered.add(m);
        continue;
      }
      final decision = applyContentFilterToText(m.content, filter);
      if (!decision.matched) {
        filtered.add(m);
      } else if (!decision.shouldHide) {
        filtered.add(m.copyWith(content: decision.content));
      }
    }
    return filtered;
  }
}
