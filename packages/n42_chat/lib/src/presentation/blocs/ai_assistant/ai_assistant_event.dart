import 'package:equatable/equatable.dart';

import '../../../core/services/ai_service.dart';
import '../../../domain/entities/ai_assistant_entity.dart';

/// AI 助手事件
abstract class AiAssistantEvent extends Equatable {
  const AiAssistantEvent();

  @override
  List<Object?> get props => [];
}

/// 初始化 AI 助手
class InitializeAiAssistant extends AiAssistantEvent {
  final String? assistantId;

  const InitializeAiAssistant({this.assistantId});

  @override
  List<Object?> get props => [assistantId];
}

/// 发送消息给 AI
class SendAiMessage extends AiAssistantEvent {
  final String text;

  const SendAiMessage(this.text);

  @override
  List<Object?> get props => [text];
}

/// AI 流式响应片段
class AiStreamChunkReceived extends AiAssistantEvent {
  final String chunk;
  final int? requestId;

  const AiStreamChunkReceived(this.chunk, {this.requestId});

  @override
  List<Object?> get props => [chunk, requestId];
}

/// AI 流式响应完成
class AiStreamCompleted extends AiAssistantEvent {
  final int? requestId;

  const AiStreamCompleted({this.requestId});

  @override
  List<Object?> get props => [requestId];
}

/// AI 流式响应出错
class AiStreamError extends AiAssistantEvent {
  final String error;
  final int? requestId;

  const AiStreamError(this.error, {this.requestId});

  @override
  List<Object?> get props => [error, requestId];
}

/// 清除 AI 会话历史
class ClearAiChatHistory extends AiAssistantEvent {
  const ClearAiChatHistory();
}

/// 切换 AI 助手
class SwitchAiAssistant extends AiAssistantEvent {
  final AiAssistantEntity assistant;

  const SwitchAiAssistant(this.assistant);

  @override
  List<Object?> get props => [assistant];
}

/// 停止 AI 响应生成
class StopAiGeneration extends AiAssistantEvent {
  const StopAiGeneration();
}

/// AI 摘要请求（群聊未读摘要）
class SummarizeMessages extends AiAssistantEvent {
  final List<String> messageTexts;
  final String? language;

  const SummarizeMessages({required this.messageTexts, this.language});

  @override
  List<Object?> get props => [messageTexts, language];
}

/// AI 消息改写请求
class RewriteMessage extends AiAssistantEvent {
  final String text;
  final AiTone tone;

  const RewriteMessage({required this.text, required this.tone});

  @override
  List<Object?> get props => [text, tone];
}

/// AI 链接摘要请求
class SummarizeLink extends AiAssistantEvent {
  final String url;
  final String pageContent;

  const SummarizeLink({required this.url, required this.pageContent});

  @override
  List<Object?> get props => [url, pageContent];
}
