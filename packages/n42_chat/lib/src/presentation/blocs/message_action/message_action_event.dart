import 'package:equatable/equatable.dart';

import '../../../domain/entities/message_entity.dart';

/// 消息操作事件基类
abstract class MessageActionEvent extends Equatable {
  const MessageActionEvent();

  @override
  List<Object?> get props => [];
}

/// 添加反应
class AddReaction extends MessageActionEvent {
  final String roomId;
  final String eventId;
  final String emoji;

  const AddReaction(this.roomId, this.eventId, this.emoji);

  @override
  List<Object?> get props => [roomId, eventId, emoji];
}

/// 移除反应
class RemoveReaction extends MessageActionEvent {
  final String roomId;
  final String eventId;
  final String emoji;

  const RemoveReaction(this.roomId, this.eventId, this.emoji);

  @override
  List<Object?> get props => [roomId, eventId, emoji];
}

/// 切换反应
class ToggleReaction extends MessageActionEvent {
  final String roomId;
  final String eventId;
  final String emoji;

  const ToggleReaction(this.roomId, this.eventId, this.emoji);

  @override
  List<Object?> get props => [roomId, eventId, emoji];
}

/// 加载消息反应
class LoadReactions extends MessageActionEvent {
  final String roomId;
  final String eventId;

  const LoadReactions(this.roomId, this.eventId);

  @override
  List<Object?> get props => [roomId, eventId];
}

/// 回复消息
class ReplyToMessage extends MessageActionEvent {
  final String roomId;
  final String originalEventId;
  final String content;

  const ReplyToMessage(this.roomId, this.originalEventId, this.content);

  @override
  List<Object?> get props => [roomId, originalEventId, content];
}

/// 编辑消息
class EditMessage extends MessageActionEvent {
  final String roomId;
  final String originalEventId;
  final String newContent;

  const EditMessage(this.roomId, this.originalEventId, this.newContent);

  @override
  List<Object?> get props => [roomId, originalEventId, newContent];
}

/// 撤回消息
class RedactMessage extends MessageActionEvent {
  final String roomId;
  final String eventId;
  final String? reason;

  const RedactMessage(this.roomId, this.eventId, {this.reason});

  @override
  List<Object?> get props => [roomId, eventId, reason];
}

/// 转发消息
class ForwardMessage extends MessageActionEvent {
  final String fromRoomId;
  final String eventId;
  final String toRoomId;

  const ForwardMessage(this.fromRoomId, this.eventId, this.toRoomId);

  @override
  List<Object?> get props => [fromRoomId, eventId, toRoomId];
}

/// 转发消息到多个房间
class ForwardToMultipleRooms extends MessageActionEvent {
  final String fromRoomId;
  final String eventId;
  final List<String> toRoomIds;

  const ForwardToMultipleRooms(this.fromRoomId, this.eventId, this.toRoomIds);

  @override
  List<Object?> get props => [fromRoomId, eventId, toRoomIds];
}

/// 收藏消息
class SaveMessage extends MessageActionEvent {
  final MessageEntity message;

  const SaveMessage(this.message);

  @override
  List<Object?> get props => [message];
}

/// 取消收藏消息
class UnsaveMessage extends MessageActionEvent {
  final String messageId;

  const UnsaveMessage(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

/// 加载收藏消息
class LoadSavedMessages extends MessageActionEvent {
  const LoadSavedMessages();
}

/// 检查消息是否已收藏
class CheckMessageSaved extends MessageActionEvent {
  final String messageId;

  const CheckMessageSaved(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

