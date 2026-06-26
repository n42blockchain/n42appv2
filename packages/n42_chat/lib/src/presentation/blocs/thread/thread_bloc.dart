import 'dart:typed_data';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/message_entity.dart';
import '../../../domain/repositories/message_repository.dart';
import 'thread_event.dart';
import 'thread_state.dart';
import '../../../core/utils/debug_log.dart';

/// 消息线程 BLoC
///
/// 独立管理线程消息的加载、发送、订阅。
/// 与 ChatBloc 解耦，避免进一步增加 ChatBloc 复杂度。
class ThreadBloc extends Bloc<ThreadEvent, ThreadState> {
  final IMessageRepository _messageRepository;

  StreamSubscription<List<MessageEntity>>? _threadMessagesSubscription;

  ThreadBloc({
    required IMessageRepository messageRepository,
  })  : _messageRepository = messageRepository,
        super(ThreadState.initial()) {
    on<InitializeThread>(_onInitializeThread);
    on<LoadThreadMessages>(_onLoadThreadMessages);
    on<LoadMoreThreadMessages>(_onLoadMoreThreadMessages);
    on<SendThreadTextMessage>(_onSendThreadTextMessage);
    on<SendThreadImageMessage>(_onSendThreadImageMessage);
    on<SendThreadFileMessage>(_onSendThreadFileMessage);
    on<SetThreadReplyTarget>(_onSetThreadReplyTarget);
    on<ThreadMessagesUpdated>(_onThreadMessagesUpdated);
    on<DisposeThread>(_onDisposeThread);
  }

  Future<void> _onInitializeThread(
    InitializeThread event,
    Emitter<ThreadState> emit,
  ) async {
    emit(state.copyWith(
      isLoading: true,
      roomId: event.roomId,
      threadRootEventId: event.threadRootEventId,
      clearError: true,
    ));

    try {
      // 加载线程消息
      final messages = await _messageRepository.getThreadMessages(
        event.roomId,
        event.threadRootEventId,
      );

      // 分离根消息和回复
      MessageEntity? rootMessage;
      final replies = <MessageEntity>[];

      for (final msg in messages) {
        if (msg.id == event.threadRootEventId) {
          rootMessage = msg;
        } else {
          replies.add(msg);
        }
      }

      // 如果根消息不在返回结果中，单独获取
      rootMessage ??= await _loadRootMessage(event.roomId, event.threadRootEventId);

      // 计算参与者
      final participantIds = <String>{};
      if (rootMessage != null) participantIds.add(rootMessage.senderId);
      for (final reply in replies) {
        participantIds.add(reply.senderId);
      }

      emit(state.copyWith(
        rootMessage: rootMessage,
        replies: replies,
        isLoading: false,
        participantCount: participantIds.length,
        hasMore: messages.length >= 50,
      ));

      // 订阅线程消息更新
      _subscribeToThreadMessages(event.roomId, event.threadRootEventId);
    } catch (e) {
      debugLog('ThreadBloc: Failed to initialize thread: $e');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<MessageEntity?> _loadRootMessage(String roomId, String eventId) async {
    try {
      // 尝试通过 watchMessage 获取根消息
      final stream = _messageRepository.watchMessage(roomId, eventId);
      final msg = await stream.first.timeout(
        const Duration(seconds: 5),
        onTimeout: () => null,
      );
      return msg;
    } catch (e) {
      debugLog('ThreadBloc: Failed to load root message: $e');
      return null;
    }
  }

  void _subscribeToThreadMessages(String roomId, String threadRootEventId) {
    _threadMessagesSubscription?.cancel();
    _threadMessagesSubscription = _messageRepository
        .watchThreadMessages(roomId, threadRootEventId)
        .listen(
      (messages) {
        if (!isClosed) {
          add(ThreadMessagesUpdated(messages));
        }
      },
      onError: (Object e) {
        debugLog('ThreadBloc: Thread messages stream error: $e');
      },
    );
  }

  Future<void> _onLoadThreadMessages(
    LoadThreadMessages event,
    Emitter<ThreadState> emit,
  ) async {
    if (state.roomId == null || state.threadRootEventId == null) return;

    emit(state.copyWith(isLoading: true));
    try {
      final messages = await _messageRepository.getThreadMessages(
        state.roomId!,
        state.threadRootEventId!,
      );

      final replies = messages
          .where((m) => m.id != state.threadRootEventId)
          .toList();

      emit(state.copyWith(
        replies: replies,
        isLoading: false,
        hasMore: messages.length >= 50,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onLoadMoreThreadMessages(
    LoadMoreThreadMessages event,
    Emitter<ThreadState> emit,
  ) async {
    if (state.roomId == null || state.threadRootEventId == null || !state.hasMore) return;

    emit(state.copyWith(isLoading: true));
    try {
      final beforeEventId = state.replies.isNotEmpty ? state.replies.first.id : null;
      final messages = await _messageRepository.getThreadMessages(
        state.roomId!,
        state.threadRootEventId!,
        limit: 50,
        fromEventId: beforeEventId,
      );

      final newReplies = messages
          .where((m) => m.id != state.threadRootEventId)
          .toList();

      emit(state.copyWith(
        replies: [...newReplies, ...state.replies],
        isLoading: false,
        hasMore: messages.length >= 50,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onSendThreadTextMessage(
    SendThreadTextMessage event,
    Emitter<ThreadState> emit,
  ) async {
    if (state.roomId == null || state.threadRootEventId == null) return;

    emit(state.copyWith(isSending: true, clearReplyTarget: true));
    try {
      await _messageRepository.sendThreadTextMessage(
        state.roomId!,
        state.threadRootEventId!,
        event.text,
      );
      emit(state.copyWith(isSending: false));
    } catch (e) {
      debugLog('ThreadBloc: Failed to send thread message: $e');
      emit(state.copyWith(isSending: false, error: e.toString()));
    }
  }

  Future<void> _onSendThreadImageMessage(
    SendThreadImageMessage event,
    Emitter<ThreadState> emit,
  ) async {
    if (state.roomId == null || state.threadRootEventId == null) return;

    emit(state.copyWith(isSending: true));
    try {
      await _messageRepository.sendThreadImageMessage(
        state.roomId!,
        state.threadRootEventId!,
        imageBytes: Uint8List.fromList(event.imageBytes),
        filename: event.filename,
        mimeType: event.mimeType,
      );
      emit(state.copyWith(isSending: false));
    } catch (e) {
      emit(state.copyWith(isSending: false, error: e.toString()));
    }
  }

  Future<void> _onSendThreadFileMessage(
    SendThreadFileMessage event,
    Emitter<ThreadState> emit,
  ) async {
    if (state.roomId == null || state.threadRootEventId == null) return;

    emit(state.copyWith(isSending: true));
    try {
      await _messageRepository.sendThreadFileMessage(
        state.roomId!,
        state.threadRootEventId!,
        fileBytes: Uint8List.fromList(event.fileBytes),
        filename: event.filename,
        mimeType: event.mimeType,
      );
      emit(state.copyWith(isSending: false));
    } catch (e) {
      emit(state.copyWith(isSending: false, error: e.toString()));
    }
  }

  void _onSetThreadReplyTarget(
    SetThreadReplyTarget event,
    Emitter<ThreadState> emit,
  ) {
    if (event.target == null) {
      emit(state.copyWith(clearReplyTarget: true));
    } else {
      emit(state.copyWith(replyTarget: event.target));
    }
  }

  void _onThreadMessagesUpdated(
    ThreadMessagesUpdated event,
    Emitter<ThreadState> emit,
  ) {
    final replies = event.messages
        .where((m) => m.id != state.threadRootEventId)
        .toList();

    // 更新根消息（如果在更新列表中）
    final updatedRoot = event.messages
        .where((m) => m.id == state.threadRootEventId)
        .firstOrNull;

    // 计算参与者
    final participantIds = <String>{};
    if (state.rootMessage != null) participantIds.add(state.rootMessage!.senderId);
    for (final reply in replies) {
      participantIds.add(reply.senderId);
    }

    emit(state.copyWith(
      rootMessage: updatedRoot ?? state.rootMessage,
      replies: replies,
      participantCount: participantIds.length,
    ));
  }

  void _onDisposeThread(
    DisposeThread event,
    Emitter<ThreadState> emit,
  ) {
    _threadMessagesSubscription?.cancel();
    _threadMessagesSubscription = null;
  }

  @override
  Future<void> close() {
    _threadMessagesSubscription?.cancel();
    return super.close();
  }
}
