part of 'chat_bloc.dart';

/// 离线消息自动重试相关逻辑
extension ChatBlocRetryHandlers on ChatBloc {
  /// 设置同步状态监听，连接恢复后自动重试失败消息
  void setupAutoRetry() {
    _syncStatusSubscription?.cancel();
    final syncStream = _clientManager?.onSyncStatus;
    if (syncStream == null) return;

    _syncStatusSubscription = syncStream.listen((status) {
      if (isClosed) return;

      if (status.status == SyncStatus.finished) {
        if (!_isConnected) {
          _isConnected = true;
          add(const ConnectionStatusChanged(true));
        }
        // 同步完成时，自动重试待发消息
        if (_pendingRetryMessages.isNotEmpty) {
          add(const RetryPendingMessages());
        }
      } else if (status.status == SyncStatus.error) {
        if (_isConnected) {
          _isConnected = false;
          add(const ConnectionStatusChanged(false));
        }
      }
    });
  }

  /// 将发送失败的消息加入待重试队列
  void enqueueForRetry(String messageId) {
    // 已永久放弃的消息不再重试，避免 _pendingRetryMessages 移除 key 后
    // 下次调用 ?? 0 使计数清零导致死循环。
    if (_permanentlyFailedMessages.contains(messageId)) return;

    final currentCount = _pendingRetryMessages[messageId] ?? 0;
    if (currentCount >= ChatBloc._maxRetryCount) {
      debugLog('ChatBloc: Message $messageId exceeded max retry count (${ChatBloc._maxRetryCount}), giving up');
      _pendingRetryMessages.remove(messageId);
      _permanentlyFailedMessages.add(messageId);
      return;
    }
    _pendingRetryMessages[messageId] = currentCount;
    debugLog('ChatBloc: Enqueued message $messageId for retry (attempt ${currentCount + 1}/${ChatBloc._maxRetryCount})');
  }

  /// 连接状态变化处理
  void onConnectionStatusChanged(
    ConnectionStatusChanged event,
    Emitter<ChatState> emit,
  ) {
    debugLog('ChatBloc: Connection status changed: ${event.isConnected}');
  }

  /// 自动重试所有待发消息
  Future<void> onRetryPendingMessages(
    RetryPendingMessages event,
    Emitter<ChatState> emit,
  ) async {
    if (_currentRoomId == null || _pendingRetryMessages.isEmpty) return;

    // 取出当前所有待重试的消息
    final messagesToRetry = Map<String, int>.from(_pendingRetryMessages);
    debugLog('ChatBloc: Retrying ${messagesToRetry.length} pending messages');

    for (final entry in messagesToRetry.entries) {
      final messageId = entry.key;
      final retryCount = entry.value;

      // 指数退避延迟：2s → 4s → 8s
      final delayMs = ChatBloc._baseRetryDelayMs * (1 << retryCount);
      await Future<void>.delayed(Duration(milliseconds: min(delayMs, 8000)));

      if (isClosed) return;

      try {
        final success = await _messageRepository.resendMessage(
          _currentRoomId!,
          messageId,
        );
        if (success) {
          _pendingRetryMessages.remove(messageId);
          // 旧的 EventStatus.error 事件仍在 SDK 时间线中，将其 ID 加入本地删除集合
          // 使 onMessagesUpdated 过滤掉它，防止 scanFailedMessages 反复发现并重入队。
          _locallyDeletedMessageIds.add(messageId);
          debugLog('ChatBloc: Message $messageId resent successfully, old event hidden');
        } else {
          _handleRetryFailure(messageId, retryCount);
        }
      } catch (e) {
        debugLog('ChatBloc: Retry failed for $messageId: $e');
        _handleRetryFailure(messageId, retryCount);
      }
    }
  }

  /// 处理重试失败
  void _handleRetryFailure(String messageId, int currentRetryCount) {
    final nextCount = currentRetryCount + 1;
    if (nextCount >= ChatBloc._maxRetryCount) {
      _pendingRetryMessages.remove(messageId);
      // 标记为永久失败，防止 scanFailedMessages 重新以计数 0 入队
      _permanentlyFailedMessages.add(messageId);
      debugLog('ChatBloc: Message $messageId failed after ${ChatBloc._maxRetryCount} retries, requires manual resend');
    } else {
      _pendingRetryMessages[messageId] = nextCount;
      debugLog('ChatBloc: Message $messageId retry count updated to $nextCount/${ChatBloc._maxRetryCount}');
    }
  }

  /// 扫描当前消息列表中发送失败的消息，加入重试队列
  void scanFailedMessages() {
    for (final message in state.messages) {
      if (message.isFailed && message.isFromMe) {
        // 已永久放弃或正在排队的消息跳过
        if (_permanentlyFailedMessages.contains(message.id)) continue;
        if (!_pendingRetryMessages.containsKey(message.id)) {
          enqueueForRetry(message.id);
        }
      }
    }
  }
}
