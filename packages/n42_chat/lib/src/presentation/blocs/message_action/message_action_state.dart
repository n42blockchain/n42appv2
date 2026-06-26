import 'package:equatable/equatable.dart';

import '../../../domain/entities/message_entity.dart';
import '../../../domain/entities/message_reaction_entity.dart';

/// 消息操作状态基类
abstract class MessageActionState extends Equatable {
  const MessageActionState();

  @override
  List<Object?> get props => [];
}

/// 初始状态
class MessageActionInitial extends MessageActionState {
  const MessageActionInitial();
}

/// 处理中
class MessageActionLoading extends MessageActionState {
  final String action;

  const MessageActionLoading(this.action);

  @override
  List<Object?> get props => [action];
}

/// 反应加载完成
class ReactionsLoaded extends MessageActionState {
  final String eventId;
  final List<MessageReactionEntity> reactions;

  const ReactionsLoaded(this.eventId, this.reactions);

  @override
  List<Object?> get props => [eventId, reactions];
}

/// 操作成功
class MessageActionSuccess extends MessageActionState {
  final String action;
  final String? message;

  const MessageActionSuccess(this.action, {this.message});

  @override
  List<Object?> get props => [action, message];
}

/// 操作失败
class MessageActionFailure extends MessageActionState {
  final String action;
  final String error;

  const MessageActionFailure(this.action, this.error);

  @override
  List<Object?> get props => [action, error];
}

/// 转发结果
class ForwardResult extends MessageActionState {
  final Map<String, bool> results;

  const ForwardResult(this.results);

  int get successCount => results.values.where((v) => v).length;
  int get failureCount => results.values.where((v) => !v).length;

  @override
  List<Object?> get props => [results];

  bool get allSuccess => failureCount == 0;
}

/// 收藏消息列表
class SavedMessagesLoaded extends MessageActionState {
  final List<MessageEntity> messages;

  const SavedMessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// 消息收藏状态
class MessageSavedStatus extends MessageActionState {
  final String messageId;
  final bool isSaved;

  const MessageSavedStatus(this.messageId, this.isSaved);

  @override
  List<Object?> get props => [messageId, isSaved];
}

