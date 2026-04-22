import 'dart:async';

import '../../core/services/ai_service.dart';
import '../../core/services/local_llm/local_llm_service.dart';
import '../../core/utils/debug_log.dart';

/// 本地 AI 数据源——通过 [LocalLlmService] 实现 [AiService] 接口。
///
/// 将翻译、摘要、润色、智能回复等任务全部路由到设备端 Gemma 模型，
/// 无需网络连接。作为 `AiDatasource`（云端）的 fallback 或用户偏好替代。
class LocalAiDatasource implements AiService {
  final LocalLlmService _llm;

  LocalAiDatasource(this._llm);

  @override
  bool get isAvailable => _llm.isModelLoaded.value;

  // ============================================
  // 核心补全
  // ============================================

  @override
  Future<AiCompletionResult> completion(
    List<AiMessage> messages, {
    String? systemPrompt,
    String? model,
    double temperature = 0.7,
    int maxTokens = 512,
  }) async {
    final prompt = _buildPrompt(messages, systemPrompt: systemPrompt);
    final result = await _llm.generate(prompt, maxOutputTokens: maxTokens);
    return AiCompletionResult(
      text: result ?? '',
      model: 'local:${_llm.activeModelId.value ?? "unknown"}',
    );
  }

  @override
  Stream<String> streamCompletion(
    List<AiMessage> messages, {
    String? systemPrompt,
    String? model,
    double temperature = 0.7,
    int maxTokens = 512,
  }) {
    final prompt = _buildPrompt(messages, systemPrompt: systemPrompt);
    return _llm.generateStream(prompt, maxOutputTokens: maxTokens);
  }

  // ============================================
  // 高层任务（组装 prompt → 调用本地推理）
  // ============================================

  /// 单轮 prompt 快捷构建 + 推理。
  Future<String?> _singleTurn(String instruction, {int maxTokens = 512}) {
    final prompt = _buildSingleTurnPrompt(instruction);
    return _llm.generate(prompt, maxOutputTokens: maxTokens);
  }

  static String _buildSingleTurnPrompt(String instruction) =>
      '<start_of_turn>user\n$instruction\n<end_of_turn>\n<start_of_turn>model\n';

  @override
  Future<String> summarize(
    String text, {
    String? language,
    int maxLength = 200,
  }) async {
    final lang = language ?? '中文';
    final result = await _singleTurn(
      '请用$lang将以下内容总结为不超过$maxLength字的摘要：\n\n$text',
      maxTokens: maxLength,
    );
    return result?.trim() ?? '无法生成摘要';
  }

  @override
  Future<String> rewriteMessage(String text, AiTone tone) async {
    final toneLabel = switch (tone) {
      AiTone.formal => '正式',
      AiTone.casual => '轻松',
      AiTone.playful => '俏皮',
      AiTone.professional => '专业',
    };
    final result = await _singleTurn(
      '请用$toneLabel的语气改写以下消息，保持原意：\n\n$text',
      maxTokens: 256,
    );
    return result?.trim() ?? text;
  }

  @override
  Future<String> translateMessage(String text, String targetLanguage) async {
    final result = await _singleTurn(
      '将以下内容翻译为$targetLanguage，只输出翻译结果：\n\n$text',
    );
    return result?.trim() ?? text;
  }

  @override
  Future<String> summarizeUrl(String url, String pageContent) async {
    final truncated = pageContent.length > 4000
        ? pageContent.substring(0, 4000)
        : pageContent;
    final result = await _singleTurn(
      '请用中文为以下网页内容生成简短摘要（100字以内）：\nURL: $url\n\n$truncated',
      maxTokens: 150,
    );
    return result?.trim() ?? '无法生成摘要';
  }

  @override
  Future<List<String>> suggestReplies(
    List<AiMessage> messages, {
    int count = 3,
    String? language,
  }) async {
    final lang = language ?? '中文';
    final lastFew = messages.length > 5
        ? messages.sublist(messages.length - 5)
        : messages;
    final context = lastFew
        .map((m) => '${m.role == AiRole.user ? "我" : "对方"}: ${m.content}')
        .join('\n');
    final result = await _singleTurn(
      '根据以下对话上下文，用$lang给出$count条简短的回复建议，每条一行，不要编号：\n\n$context',
      maxTokens: 200,
    );
    if (result == null || result.trim().isEmpty) return const [];
    return result
        .trim()
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .take(count)
        .toList();
  }

  // ============================================
  // 内部工具
  // ============================================

  /// 将消息列表组装为 Gemma IT 格式 prompt。
  ///
  /// Gemma Instruct 模板：
  /// ```
  /// <start_of_turn>user
  /// {message}
  /// <end_of_turn>
  /// <start_of_turn>model
  /// {response}
  /// <end_of_turn>
  /// ```
  String _buildPrompt(
    List<AiMessage> messages, {
    String? systemPrompt,
  }) {
    final buffer = StringBuffer();

    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      buffer.writeln('<start_of_turn>user');
      buffer.writeln('System instruction: $systemPrompt');
      buffer.writeln('<end_of_turn>');
    }

    for (final msg in messages) {
      final role = msg.role == AiRole.user ? 'user' : 'model';
      buffer.writeln('<start_of_turn>$role');
      buffer.writeln(_sanitize(msg.content));
      buffer.writeln('<end_of_turn>');
    }

    buffer.writeln('<start_of_turn>model');
    return buffer.toString();
  }

  /// 过滤 Gemma 控制 token，防止 prompt injection。
  static String _sanitize(String input) {
    return input
        .replaceAll('<start_of_turn>', '< start_of_turn>')
        .replaceAll('<end_of_turn>', '< end_of_turn>')
        .replaceAll('<bos>', '< bos>')
        .replaceAll('<eos>', '< eos>');
  }

  @override
  void dispose() {
    debugLog('LocalAiDatasource: disposed');
  }
}
