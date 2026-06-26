import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/repositories/message_action_repository.dart';
import 'message_action_event.dart';
import 'message_action_state.dart';

/// 消息操作BLoC
class MessageActionBloc extends Bloc<MessageActionEvent, MessageActionState> {
  final IMessageActionRepository _repository;

  MessageActionBloc(this._repository) : super(const MessageActionInitial()) {
    on<AddReaction>(_onAddReaction);
    on<RemoveReaction>(_onRemoveReaction);
    on<ToggleReaction>(_onToggleReaction);
    on<LoadReactions>(_onLoadReactions);
    on<ReplyToMessage>(_onReplyToMessage);
    on<EditMessage>(_onEditMessage);
    on<RedactMessage>(_onRedactMessage);
    on<ForwardMessage>(_onForwardMessage);
    on<ForwardToMultipleRooms>(_onForwardToMultipleRooms);
    on<SaveMessage>(_onSaveMessage);
    on<UnsaveMessage>(_onUnsaveMessage);
    on<LoadSavedMessages>(_onLoadSavedMessages);
    on<CheckMessageSaved>(_onCheckMessageSaved);
  }

  Future<void> _onAddReaction(
    AddReaction event,
    Emitter<MessageActionState> emit,
  ) async {
    emit(const MessageActionLoading('addReaction'));

    try {
      await _repository.addReaction(event.roomId, event.eventId, event.emoji);
      emit(const MessageActionSuccess('addReaction'));
    } catch (e) {
      emit(MessageActionFailure('addReaction', e.toString()));
    }
  }

  Future<void> _onRemoveReaction(
    RemoveReaction event,
    Emitter<MessageActionState> emit,
  ) async {
    emit(const MessageActionLoading('removeReaction'));

    try {
      await _repository.removeReaction(event.roomId, event.eventId, event.emoji);
      emit(const MessageActionSuccess('removeReaction'));
    } catch (e) {
      emit(MessageActionFailure('removeReaction', e.toString()));
    }
  }

  Future<void> _onToggleReaction(
    ToggleReaction event,
    Emitter<MessageActionState> emit,
  ) async {
    emit(const MessageActionLoading('toggleReaction'));

    try {
      await _repository.toggleReaction(event.roomId, event.eventId, event.emoji);
      emit(const MessageActionSuccess('toggleReaction'));
    } catch (e) {
      emit(MessageActionFailure('toggleReaction', e.toString()));
    }
  }

  Future<void> _onLoadReactions(
    LoadReactions event,
    Emitter<MessageActionState> emit,
  ) async {
    try {
      final reactions = await _repository.getReactions(event.roomId, event.eventId);
      emit(ReactionsLoaded(event.eventId, reactions));
    } catch (e) {
      emit(MessageActionFailure('loadReactions', e.toString()));
    }
  }

  Future<void> _onReplyToMessage(
    ReplyToMessage event,
    Emitter<MessageActionState> emit,
  ) async {
    emit(const MessageActionLoading('reply'));

    try {
      await _repository.replyToMessage(
        event.roomId,
        event.originalEventId,
        event.content,
      );
      emit(const MessageActionSuccess('reply', message: 'Reply sent'));
    } catch (e) {
      emit(MessageActionFailure('reply', e.toString()));
    }
  }

  Future<void> _onEditMessage(
    EditMessage event,
    Emitter<MessageActionState> emit,
  ) async {
    emit(const MessageActionLoading('edit'));

    try {
      await _repository.editMessage(
        event.roomId,
        event.originalEventId,
        event.newContent,
      );
      emit(const MessageActionSuccess('edit', message: 'Message edited'));
    } catch (e) {
      emit(MessageActionFailure('edit', e.toString()));
    }
  }

  Future<void> _onRedactMessage(
    RedactMessage event,
    Emitter<MessageActionState> emit,
  ) async {
    emit(const MessageActionLoading('redact'));

    try {
      await _repository.redactMessage(
        event.roomId,
        event.eventId,
        reason: event.reason,
      );
      emit(const MessageActionSuccess('redact', message: 'Message recalled'));
    } catch (e) {
      emit(MessageActionFailure('redact', e.toString()));
    }
  }

  Future<void> _onForwardMessage(
    ForwardMessage event,
    Emitter<MessageActionState> emit,
  ) async {
    emit(const MessageActionLoading('forward'));

    try {
      await _repository.forwardMessage(
        event.fromRoomId,
        event.eventId,
        event.toRoomId,
      );
      emit(const MessageActionSuccess('forward', message: 'Message forwarded'));
    } catch (e) {
      emit(MessageActionFailure('forward', e.toString()));
    }
  }

  Future<void> _onForwardToMultipleRooms(
    ForwardToMultipleRooms event,
    Emitter<MessageActionState> emit,
  ) async {
    emit(const MessageActionLoading('forwardMultiple'));

    try {
      final results = await _repository.forwardToMultipleRooms(
        event.fromRoomId,
        event.eventId,
        event.toRoomIds,
      );
      emit(ForwardResult(results));
    } catch (e) {
      emit(MessageActionFailure('forwardMultiple', e.toString()));
    }
  }

  Future<void> _onSaveMessage(
    SaveMessage event,
    Emitter<MessageActionState> emit,
  ) async {
    try {
      await _repository.saveMessage(event.message);
      emit(MessageSavedStatus(event.message.id, true));
    } catch (e) {
      emit(MessageActionFailure('save', e.toString()));
    }
  }

  Future<void> _onUnsaveMessage(
    UnsaveMessage event,
    Emitter<MessageActionState> emit,
  ) async {
    try {
      await _repository.unsaveMessage(event.messageId);
      emit(MessageSavedStatus(event.messageId, false));
    } catch (e) {
      emit(MessageActionFailure('unsave', e.toString()));
    }
  }

  Future<void> _onLoadSavedMessages(
    LoadSavedMessages event,
    Emitter<MessageActionState> emit,
  ) async {
    try {
      final messages = await _repository.getSavedMessages();
      emit(SavedMessagesLoaded(messages));
    } catch (e) {
      emit(MessageActionFailure('loadSaved', e.toString()));
    }
  }

  Future<void> _onCheckMessageSaved(
    CheckMessageSaved event,
    Emitter<MessageActionState> emit,
  ) async {
    try {
      final isSaved = await _repository.isMessageSaved(event.messageId);
      emit(MessageSavedStatus(event.messageId, isSaved));
    } catch (e) {
      // 如果检查失败，默认为未收藏
      emit(MessageSavedStatus(event.messageId, false));
    }
  }

  /// 检查是否可以编辑消息
  bool canEdit(String roomId, String senderId) {
    return _repository.canEdit(roomId, senderId);
  }

  /// 检查是否可以撤回消息
  bool canRedact(String roomId, String senderId) {
    return _repository.canRedact(roomId, senderId);
  }
}

