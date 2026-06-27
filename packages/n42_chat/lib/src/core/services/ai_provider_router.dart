import 'dart:typed_data';

import 'ai_service.dart';
import 'local_llm_service.dart';

/// AI 提供方路由
///
/// 实现 [AiService]，在**云端**（OpenAI 兼容）与**端侧**（[LocalLlmService] 经
/// MediaPipe/Core ML）之间路由：本地启用且就绪→走端侧；否则→云端；端侧失败→
/// 回退云端。原生端侧未接入时 [LocalLlmService] 恒 unavailable，等价于纯云端。
class AiProviderRouter implements AiService {
  final AiService? cloud;
  final LocalLlmService local;

  AiProviderRouter({required this.cloud, required this.local});

  bool get _useLocal => local.isReady;

  @override
  bool get isAvailable => (cloud?.isAvailable ?? false) || local.isReady;

  String _messagesToPrompt(List<AiMessage> messages, {String? systemPrompt}) {
    final sb = StringBuffer();
    if (systemPrompt != null && systemPrompt.isNotEmpty) {
      sb.writeln('System: $systemPrompt');
    }
    for (final m in messages) {
      sb.writeln('${m.role.name}: ${m.content}');
    }
    sb.write('assistant:');
    return sb.toString();
  }

  @override
  Stream<String> streamCompletion(
    List<AiMessage> messages, {
    String? systemPrompt,
    String? model,
    double temperature = 0.7,
    int maxTokens = 1024,
  }) async* {
    if (_useLocal) {
      final t = await local.generate(
        _messagesToPrompt(messages, systemPrompt: systemPrompt),
        maxTokens: maxTokens,
      );
      if (t != null && t.trim().isNotEmpty) {
        yield t.trim();
        return;
      }
    }
    if (cloud != null) {
      yield* cloud!.streamCompletion(
        messages,
        systemPrompt: systemPrompt,
        model: model,
        temperature: temperature,
        maxTokens: maxTokens,
      );
    }
  }

  @override
  Future<AiCompletionResult> completion(
    List<AiMessage> messages, {
    String? systemPrompt,
    String? model,
    double temperature = 0.7,
    int maxTokens = 1024,
  }) async {
    if (_useLocal) {
      final t = await local.generate(
        _messagesToPrompt(messages, systemPrompt: systemPrompt),
        maxTokens: maxTokens,
      );
      if (t != null && t.trim().isNotEmpty) {
        return AiCompletionResult(text: t.trim(), model: 'local');
      }
    }
    if (cloud != null) {
      return cloud!.completion(
        messages,
        systemPrompt: systemPrompt,
        model: model,
        temperature: temperature,
        maxTokens: maxTokens,
      );
    }
    return const AiCompletionResult(text: '');
  }

  Future<String> _localOrCloud(
    String prompt,
    Future<String> Function() cloudCall, {
    String fallback = '',
  }) async {
    if (_useLocal) {
      final t = await local.generate(prompt);
      if (t != null && t.trim().isNotEmpty) return t.trim();
    }
    if (cloud != null) return cloudCall();
    return fallback;
  }

  @override
  Future<String> summarize(String text, {String? language, int maxLength = 200}) =>
      _localOrCloud(
        'Summarize the following${language != null ? ' in $language' : ''} '
        'within $maxLength characters:\n\n$text',
        () => cloud!.summarize(text, language: language, maxLength: maxLength),
        fallback: text,
      );

  @override
  Future<String> rewriteMessage(String text, AiTone tone) => _localOrCloud(
        'Rewrite the following message in a ${tone.name} tone:\n\n$text',
        () => cloud!.rewriteMessage(text, tone),
        fallback: text,
      );

  @override
  Future<String> translateMessage(String text, String targetLanguage) =>
      _localOrCloud(
        'Translate the following to $targetLanguage:\n\n$text',
        () => cloud!.translateMessage(text, targetLanguage),
        fallback: text,
      );

  @override
  Future<String> summarizeUrl(String url, String pageContent) => _localOrCloud(
        'Summarize this web page ($url):\n\n$pageContent',
        () => cloud!.summarizeUrl(url, pageContent),
        fallback: '',
      );

  @override
  Future<List<String>> suggestReplies(
    List<AiMessage> messages, {
    int count = 3,
    String? language,
  }) async {
    if (_useLocal) {
      final t = await local.generate(
        'Suggest $count short replies (one per line) to this conversation:\n\n'
        '${_messagesToPrompt(messages)}',
      );
      if (t != null && t.trim().isNotEmpty) {
        return t
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .take(count)
            .toList();
      }
    }
    if (cloud != null) {
      return cloud!.suggestReplies(messages, count: count, language: language);
    }
    return const [];
  }

  @override
  bool get supportsImageGeneration => cloud?.supportsImageGeneration ?? false;

  @override
  bool get supportsVision => cloud?.supportsVision ?? false;

  @override
  Future<String> describeImage(
    Uint8List imageBytes, {
    String? prompt,
    String? model,
    String mimeType = 'image/png',
  }) {
    // 端侧（Gemma 文本）不做视觉，统一走云端。
    final c = cloud;
    if (c == null) {
      throw const AiServiceException('Image understanding unavailable (no cloud AI)');
    }
    return c.describeImage(
      imageBytes,
      prompt: prompt,
      model: model,
      mimeType: mimeType,
    );
  }

  @override
  Future<AiImageResult> generateImage(
    String prompt, {
    String? model,
    String size = '1024x1024',
  }) {
    // 端侧（Gemma）不做文生图，统一走云端。
    final c = cloud;
    if (c == null) {
      throw const AiServiceException('Image generation unavailable (no cloud AI)');
    }
    return c.generateImage(prompt, model: model, size: size);
  }

  @override
  void dispose() => cloud?.dispose();
}
