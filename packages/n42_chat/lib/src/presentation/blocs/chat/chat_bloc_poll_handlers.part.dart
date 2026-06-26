part of 'chat_bloc.dart';

/// 投票相关 handler 方法
extension ChatBlocPollHandlers on ChatBloc {
  /// 发送投票消息
  Future<void> onSendPollMessage(
    SendPollMessage event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null) return;

    try {
      debugLog('ChatBloc: Sending poll - question: ${event.question}, options: ${event.options}');

      final message = await _messageRepository.sendPollMessage(
        _currentRoomId!,
        question: event.question,
        options: event.options,
        maxSelections: event.maxSelections,
        isAnonymous: event.isAnonymous,
      );

      if (message != null) {
        debugLog('ChatBloc: Poll sent successfully - eventId: ${message.id}');
        // 消息会通过订阅自动更新
      }
    } catch (e) {
      debugLog('ChatBloc: Failed to send poll: $e');
      if (!isClosed) {
        emit(state.copyWith(error: 'Failed to send poll'));
      }
    }
  }

  /// 投票响应
  Future<void> onVoteOnPoll(
    VoteOnPoll event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null) return;

    try {
      debugLog('ChatBloc: Voting on poll - pollEventId: ${event.pollEventId}, options: ${event.selectedOptionIds}');

      final success = await _messageRepository.voteOnPoll(
        _currentRoomId!,
        pollEventId: event.pollEventId,
        selectedOptionIds: event.selectedOptionIds,
      );

      if (success && !isClosed) {
        debugLog('ChatBloc: Vote submitted successfully, fetching fresh poll data');

        // 从服务器获取最新的投票聚合数据
        final freshAggregations = await _messageRepository.getPollAggregations(
          _currentRoomId!,
          event.pollEventId,
        );

        // 使用服务器数据更新UI
        final updatedMessages = state.messages.map((msg) {
          if (msg.id == event.pollEventId && msg.metadata != null) {
            final oldMetadata = msg.metadata!;

            // 优先使用服务器返回的数据
            Map<String, int> newVoteCounts;
            int totalVoters;
            List<String> newMyVotes;

            if (freshAggregations != null) {
              newVoteCounts = (freshAggregations['voteCounts'] as Map<String, dynamic>?)
                  ?.cast<String, int>() ?? {};
              totalVoters = freshAggregations['totalVoters'] as int? ?? 0;
              newMyVotes = (freshAggregations['myVotes'] as List<dynamic>?)
                  ?.cast<String>() ?? event.selectedOptionIds;
              debugLog('ChatBloc: Using fresh poll data - voteCounts: $newVoteCounts, totalVoters: $totalVoters, myVotes: $newMyVotes');
            } else {
              // 如果获取失败，使用本地计算的数据
              debugLog('ChatBloc: Fresh poll data unavailable, using local calculation');
              newVoteCounts = Map<String, int>.from(oldMetadata.voteCounts ?? {});
              final oldMyVotes = List<String>.from(oldMetadata.myVotes ?? []);
              newMyVotes = List<String>.from(event.selectedOptionIds);

              debugLog('ChatBloc: oldMyVotes: $oldMyVotes, newMyVotes: $newMyVotes');

              // 减少之前投票但现在取消的选项的票数
              for (final optionId in oldMyVotes) {
                if (!newMyVotes.contains(optionId)) {
                  final currentCount = newVoteCounts[optionId] ?? 0;
                  if (currentCount > 0) {
                    newVoteCounts[optionId] = currentCount - 1;
                    debugLog('ChatBloc: Decreased vote count for $optionId to ${newVoteCounts[optionId]}');
                  }
                }
              }

              // 增加新投票选项的票数
              for (final optionId in newMyVotes) {
                if (!oldMyVotes.contains(optionId)) {
                  newVoteCounts[optionId] = (newVoteCounts[optionId] ?? 0) + 1;
                  debugLog('ChatBloc: Increased vote count for $optionId to ${newVoteCounts[optionId]}');
                }
              }

              // 计算新的总投票人数
              totalVoters = oldMetadata.totalVoters ?? 0;
              if (oldMyVotes.isEmpty && newMyVotes.isNotEmpty) {
                totalVoters += 1;
              } else if (oldMyVotes.isNotEmpty && newMyVotes.isEmpty) {
                totalVoters = totalVoters > 0 ? totalVoters - 1 : 0;
              }
            }

            return msg.copyWith(
              metadata: oldMetadata.copyWithPoll(
                voteCounts: newVoteCounts,
                totalVoters: totalVoters,
                myVotes: newMyVotes,
              ),
            );
          }
          return msg;
        }).toList();

        emit(state.copyWith(messages: updatedMessages));
      }
    } catch (e) {
      debugLog('ChatBloc: Failed to vote: $e');
      if (!isClosed) {
        emit(state.copyWith(error: 'Failed to vote'));
      }
    }
  }

  /// 处理投票响应接收事件（来自其他用户的投票）
  Future<void> onPollResponseReceived(
    PollResponseReceived event,
    Emitter<ChatState> emit,
  ) async {
    if (isClosed) return;

    // 如果是当前用户的投票，已在 _onVoteOnPoll 中处理
    if (event.isCurrentUser) return;

    debugLog('ChatBloc: Poll response received - poll: ${event.pollEventId}, from: ${event.senderId}');

    final updatedMessages = state.messages.map((msg) {
      if (msg.id == event.pollEventId && msg.metadata != null) {
        final oldMetadata = msg.metadata!;
        final newVoteCounts = Map<String, int>.from(oldMetadata.voteCounts ?? {});

        // 更新选中选项的票数
        for (final optionId in event.selectedOptionIds) {
          newVoteCounts[optionId] = (newVoteCounts[optionId] ?? 0) + 1;
        }

        // 计算新的总投票人数
        final totalVoters = (oldMetadata.totalVoters ?? 0) + 1;

        return msg.copyWith(
          metadata: oldMetadata.copyWithPoll(
            voteCounts: newVoteCounts,
            totalVoters: totalVoters,
          ),
        );
      }
      return msg;
    }).toList();

    emit(state.copyWith(messages: updatedMessages));
  }

  /// 主动结束投票
  Future<void> onEndPoll(
    EndPoll event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null) return;

    try {
      debugLog('ChatBloc: Ending poll - poll: ${event.pollEventId}');

      // 调用 API 结束投票
      final success = await _messageRepository.endPoll(
        _currentRoomId!,
        event.pollEventId,
      );

      if (success) {
        // 立即更新本地状态
        final updatedMessages = state.messages.map((msg) {
          if (msg.id == event.pollEventId && msg.metadata != null) {
            return msg.copyWith(
              metadata: msg.metadata!.copyWithPoll(pollEnded: true),
            );
          }
          return msg;
        }).toList();

        emit(state.copyWith(messages: updatedMessages));
        debugLog('ChatBloc: Poll ended successfully');
      } else {
        debugLog('ChatBloc: Failed to end poll');
        emit(state.copyWith(error: 'Failed to end poll'));
      }
    } catch (e) {
      debugLog('ChatBloc: Error ending poll: $e');
      emit(state.copyWith(error: 'Error ending poll: $e'));
    }
  }

  /// 处理投票已结束事件（从服务器接收）
  Future<void> onPollEnded(
    PollEnded event,
    Emitter<ChatState> emit,
  ) async {
    if (isClosed) return;

    debugLog('ChatBloc: Poll ended - poll: ${event.pollEventId}');

    final updatedMessages = state.messages.map((msg) {
      if (msg.id == event.pollEventId && msg.metadata != null) {
        return msg.copyWith(
          metadata: msg.metadata!.copyWithPoll(pollEnded: true),
        );
      }
      return msg;
    }).toList();

    emit(state.copyWith(messages: updatedMessages));
  }
}
