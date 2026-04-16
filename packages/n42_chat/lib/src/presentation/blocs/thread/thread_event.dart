import 'package:equatable/equatable.dart';

import '../../../domain/entities/message_entity.dart';

/// 线程事件基类
abstract class ThreadEvent extends Equatable {
  const ThreadEvent();

  @override
  List<Object?> get props => [];
}

/// 初始化线程
class InitializeThread extends ThreadEvent {
  final String roomId;
  final String threadRootEventId;

  const InitializeThread({
    required this.roomId,
    required this.threadRootEventId,
  });

  @override
  List<Object?> get props => [roomId, threadRootEventId];
}

/// 加载线程消息
class LoadThreadMessages extends ThreadEvent {
  const LoadThreadMessages();
}

/// 加载更多历史消息
class LoadMoreThreadMessages extends ThreadEvent {
  const LoadMoreThreadMessages();
}

/// 发送线程文本消息
class SendThreadTextMessage extends ThreadEvent {
  final String text;

  const SendThreadTextMessage(this.text);

  @override
  List<Object?> get props => [text];
}

/// 发送线程图片消息
class SendThreadImageMessage extends ThreadEvent {
  final List<int> imageBytes;
  final String filename;
  final String? mimeType;

  const SendThreadImageMessage({
    required this.imageBytes,
    required this.filename,
    this.mimeType,
  });

  @override
  List<Object?> get props => [imageBytes, filename, mimeType];
}

/// 发送线程文件消息
class SendThreadFileMessage extends ThreadEvent {
  final List<int> fileBytes;
  final String filename;
  final String? mimeType;

  const SendThreadFileMessage({
    required this.fileBytes,
    required this.filename,
    this.mimeType,
  });

  @override
  List<Object?> get props => [fileBytes, filename, mimeType];
}

/// 设置线程内回复目标
class SetThreadReplyTarget extends ThreadEvent {
  final MessageEntity? target;

  const SetThreadReplyTarget(this.target);

  @override
  List<Object?> get props => [target];
}

/// 线程消息更新（来自流订阅）
class ThreadMessagesUpdated extends ThreadEvent {
  final List<MessageEntity> messages;

  const ThreadMessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// 释放线程资源
class DisposeThread extends ThreadEvent {
  const DisposeThread();
}
