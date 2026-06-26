/// AI 服务统一接口
///
/// 提供 AI 补全、摘要、改写、翻译等功能
/// 支持 OpenAI / Claude 等兼容后端
library;

/// AI 消息角色
enum AiRole { system, user, assistant }

/// AI 消息语气
enum AiTone {
  formal,       // 正式
  casual,       // 轻松
  playful,      // 俏皮
  professional, // 专业
}

/// AI 消息
class AiMessage {
  final AiRole role;
  final String content;

  const AiMessage({required this.role, required this.content});

  Map<String, String> toJson() => {
    'role': role.name,
    'content': content,
  };
}

/// AI 补全结果
class AiCompletionResult {
  final String text;
  final int promptTokens;
  final int completionTokens;
  final String? model;

  const AiCompletionResult({
    required this.text,
    this.promptTokens = 0,
    this.completionTokens = 0,
    this.model,
  });
}

/// AI 服务抽象接口
abstract class AiService {
  /// 流式补全（逐 token 返回）
  Stream<String> streamCompletion(
    List<AiMessage> messages, {
    String? systemPrompt,
    String? model,
    double temperature,
    int maxTokens,
  });

  /// 非流式补全
  Future<AiCompletionResult> completion(
    List<AiMessage> messages, {
    String? systemPrompt,
    String? model,
    double temperature,
    int maxTokens,
  });

  /// 文本摘要
  Future<String> summarize(
    String text, {
    String? language,
    int maxLength,
  });

  /// 消息改写
  Future<String> rewriteMessage(String text, AiTone tone);

  /// 翻译
  Future<String> translateMessage(String text, String targetLanguage);

  /// 链接内容摘要
  Future<String> summarizeUrl(String url, String pageContent);

  /// 智能回复建议
  Future<List<String>> suggestReplies(
    List<AiMessage> messages, {
    int count,
    String? language,
  });

  /// 检查服务是否可用
  bool get isAvailable;

  /// 释放资源
  void dispose();
}
