import 'package:equatable/equatable.dart';

import '../../../domain/entities/ai_assistant_entity.dart';

/// AI 助手状态
class AiAssistantState extends Equatable {
  /// 当前 AI 助手
  final AiAssistantEntity? assistant;

  /// 对话消息列表
  final List<AiChatMessage> messages;

  /// 是否正在加载
  final bool isLoading;

  /// AI 是否正在生成响应
  final bool isGenerating;

  /// 当前流式响应的累积文本
  final String streamingText;

  /// 错误信息
  final String? error;

  /// 摘要结果（给群聊用）
  final String? summaryResult;

  /// 是否正在生成摘要
  final bool isSummarizing;

  /// 改写结果
  final String? rewriteResult;

  /// 是否正在改写
  final bool isRewriting;

  /// 链接摘要结果
  final String? linkSummaryResult;

  /// 是否正在生成链接摘要
  final bool isSummarizingLink;

  /// AI 服务是否可用
  final bool isAvailable;

  const AiAssistantState({
    this.assistant,
    this.messages = const [],
    this.isLoading = false,
    this.isGenerating = false,
    this.streamingText = '',
    this.error,
    this.summaryResult,
    this.isSummarizing = false,
    this.rewriteResult,
    this.isRewriting = false,
    this.linkSummaryResult,
    this.isSummarizingLink = false,
    this.isAvailable = false,
  });

  factory AiAssistantState.initial() => const AiAssistantState(isLoading: true);

  AiAssistantState copyWith({
    AiAssistantEntity? assistant,
    List<AiChatMessage>? messages,
    bool? isLoading,
    bool? isGenerating,
    String? streamingText,
    String? error,
    String? summaryResult,
    bool? isSummarizing,
    String? rewriteResult,
    bool? isRewriting,
    String? linkSummaryResult,
    bool? isSummarizingLink,
    bool? isAvailable,
    bool clearError = false,
    bool clearSummary = false,
    bool clearRewrite = false,
    bool clearLinkSummary = false,
  }) {
    return AiAssistantState(
      assistant: assistant ?? this.assistant,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isGenerating: isGenerating ?? this.isGenerating,
      streamingText: streamingText ?? this.streamingText,
      error: clearError ? null : (error ?? this.error),
      summaryResult: clearSummary ? null : (summaryResult ?? this.summaryResult),
      isSummarizing: isSummarizing ?? this.isSummarizing,
      rewriteResult: clearRewrite ? null : (rewriteResult ?? this.rewriteResult),
      isRewriting: isRewriting ?? this.isRewriting,
      linkSummaryResult: clearLinkSummary ? null : (linkSummaryResult ?? this.linkSummaryResult),
      isSummarizingLink: isSummarizingLink ?? this.isSummarizingLink,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  List<Object?> get props => [
    assistant, messages, isLoading, isGenerating, streamingText,
    error, summaryResult, isSummarizing, rewriteResult, isRewriting,
    linkSummaryResult, isSummarizingLink, isAvailable,
  ];
}
