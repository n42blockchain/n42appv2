import 'dart:async';

import '../ai_service.dart';
import '../../../data/datasources/local_ai_datasource.dart';
import '../../utils/debug_log.dart';

/// AI Provider 路由器——在云端和本地 LLM 之间智能切换。
///
/// 路由策略（可通过 [preferLocal] 切换）：
/// 1. **preferLocal = true**（隐私优先）：本地模型可用时全部走本地；不可用时 fallback 到云端。
/// 2. **preferLocal = false**（默认）：云端可用时走云端；离线或云端异常时 fallback 到本地。
class AiProviderRouter implements AiService {
  AiProviderRouter({
    required AiService cloudProvider,
    required LocalAiDatasource localProvider,
    this.preferLocal = false,
  })  : _cloud = cloudProvider,
        _local = localProvider;

  final AiService _cloud;
  final LocalAiDatasource _local;
  bool preferLocal;

  AiService get _primary => preferLocal ? _effectiveLocal : _cloud;
  AiService get _fallback => preferLocal ? _cloud : _effectiveLocal;

  AiService get _effectiveLocal => _local.isAvailable ? _local : _cloud;

  @override
  bool get isAvailable => _cloud.isAvailable || _local.isAvailable;

  String get activeProvider {
    if (preferLocal && _local.isAvailable) return 'local';
    if (_cloud.isAvailable) return 'cloud';
    if (_local.isAvailable) return 'local';
    return 'none';
  }

  Future<T> _withFallback<T>(
    Future<T> Function(AiService) action,
  ) async {
    try {
      if (_primary.isAvailable) {
        return await action(_primary);
      }
    } catch (e) {
      debugLog('AiRouter: Primary ($activeProvider) failed: $e, trying fallback');
    }
    return action(_fallback);
  }

  @override
  Future<AiCompletionResult> completion(
    List<AiMessage> messages, {
    String? systemPrompt,
    String? model,
    double temperature = 0.7,
    int maxTokens = 512,
  }) => _withFallback((p) => p.completion(
        messages,
        systemPrompt: systemPrompt,
        model: model,
        temperature: temperature,
        maxTokens: maxTokens,
      ));

  @override
  Stream<String> streamCompletion(
    List<AiMessage> messages, {
    String? systemPrompt,
    String? model,
    double temperature = 0.7,
    int maxTokens = 512,
  }) {
    final provider = _primary.isAvailable ? _primary : _fallback;
    return provider.streamCompletion(
      messages,
      systemPrompt: systemPrompt,
      model: model,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }

  @override
  Future<String> summarize(String text,
      {String? language, int maxLength = 200}) =>
      _withFallback((p) => p.summarize(text,
          language: language, maxLength: maxLength));

  @override
  Future<String> rewriteMessage(String text, AiTone tone) =>
      _withFallback((p) => p.rewriteMessage(text, tone));

  @override
  Future<String> translateMessage(String text, String targetLanguage) =>
      _withFallback((p) => p.translateMessage(text, targetLanguage));

  @override
  Future<String> summarizeUrl(String url, String pageContent) =>
      _withFallback((p) => p.summarizeUrl(url, pageContent));

  @override
  Future<List<String>> suggestReplies(
    List<AiMessage> messages, {
    int count = 3,
    String? language,
  }) => _withFallback((p) => p.suggestReplies(messages,
      count: count, language: language));

  @override
  void dispose() {
    // Router 不拥有 providers 的生命周期，由 DI 分别管理
  }
}
