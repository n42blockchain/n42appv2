import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/services/ai_service.dart';
import '../../core/utils/debug_log.dart';

/// AI API 数据源实现
///
/// 使用 OpenAI 兼容 API（支持 OpenAI, Claude via proxy, DeepSeek 等）
/// 支持 SSE 流式响应
class AiDatasource implements AiService {
  final Dio _dio;
  final String _baseUrl;
  final String _apiKey;
  final String _defaultModel;
  final bool _useProxyEndpoint;

  static final _newlineRegExp = RegExp(r'[\r\n]+');
  static final _arrayRegExp = RegExp(r'\[[\s\S]*\]');
  static final _listPrefixRegExp = RegExp(r'^[-*•\d\.)\s]+');
  static final _trailingSlashRegExp = RegExp(r'/$');

  AiDatasource({
    required String baseUrl,
    required String apiKey,
    String defaultModel = 'gpt-4o-mini',
    bool useProxyEndpoint = false,
    Dio? dio,
  }) : _baseUrl = baseUrl.endsWith('/')
           ? baseUrl.substring(0, baseUrl.length - 1)
           : baseUrl,
       _apiKey = apiKey,
       _defaultModel = defaultModel,
       _useProxyEndpoint = useProxyEndpoint,
       _dio = dio ?? Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'Content-Type': 'application/json',
      if (_apiKey.isNotEmpty) 'Authorization': 'Bearer $_apiKey',
    };
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(minutes: 3);
  }

  @override
  bool get isAvailable =>
      _baseUrl.isNotEmpty && (_apiKey.isNotEmpty || _useProxyEndpoint);

  String get _chatCompletionsUrl =>
      _useProxyEndpoint ? _baseUrl : _buildChatCompletionsUrl();

  /// 消息总字符数上限（约 ~32k tokens）
  static const int _maxTotalCharacters = 128000;

  /// 校验消息总长度
  void _validateMessageLength(List<AiMessage> messages, String? systemPrompt) {
    var totalLength = systemPrompt?.length ?? 0;
    for (final m in messages) {
      totalLength += m.content.length;
    }
    if (totalLength > _maxTotalCharacters) {
      throw AiServiceException(
        'Total message length exceeds limit ($totalLength > $_maxTotalCharacters characters)',
      );
    }
  }

  @override
  Stream<String> streamCompletion(
    List<AiMessage> messages, {
    String? systemPrompt,
    String? model,
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async* {
    _validateMessageLength(messages, systemPrompt);

    final allMessages = <Map<String, String>>[];
    if (systemPrompt != null) {
      allMessages.add({'role': 'system', 'content': systemPrompt});
    }
    allMessages.addAll(messages.map((m) => m.toJson()));

    try {
      final response = await _dio.post<ResponseBody>(
        _chatCompletionsUrl,
        data: {
          'model': model ?? _defaultModel,
          'messages': allMessages,
          'temperature': temperature,
          'max_tokens': maxTokens,
          'stream': true,
        },
        options: Options(responseType: ResponseType.stream),
      );

      if (response.data == null) {
        throw const AiServiceException('Empty response from server');
      }
      final lines = utf8.decoder
          .bind(response.data!.stream)
          .transform(const LineSplitter());

      await for (final rawLine in lines) {
        final line = rawLine.trim();
        if (line.isEmpty || line.startsWith(':')) continue;
        if (!line.startsWith('data: ')) continue;

        final data = line.substring(6).trim();
        if (data == '[DONE]') return;

        Map<String, dynamic> json;
        try {
          json = jsonDecode(data) as Map<String, dynamic>;
        } catch (e) {
          // 跳过无法解析的行
          debugLog('AiDatasource: Failed to parse SSE data: $e');
          continue;
        }

        final errorMessage = _extractInlineErrorMessage(json);
        if (errorMessage != null) {
          throw AiServiceException(errorMessage);
        }

        final choices = json['choices'] as List<dynamic>?;
        if (choices == null || choices.isEmpty) continue;

        final delta = choices[0]['delta'] as Map<String, dynamic>?;
        final content =
            _extractMessageText(delta?['content']) ??
            _extractMessageText(delta?['text']);
        if (content != null && content.isNotEmpty) {
          yield content;
        }
      }
    } on DioException catch (e) {
      debugLog('AiDatasource: Stream completion error: ${e.message}');
      final errorMsg = _parseErrorMessage(e);
      throw AiServiceException(errorMsg);
    } catch (e) {
      if (e is AiServiceException) rethrow;
      debugLog('AiDatasource: Stream completion read error: $e');
      throw AiServiceException('Failed to read streaming response: $e');
    }
  }

  @override
  Future<AiCompletionResult> completion(
    List<AiMessage> messages, {
    String? systemPrompt,
    String? model,
    double temperature = 0.7,
    int maxTokens = 2048,
  }) async {
    _validateMessageLength(messages, systemPrompt);

    final allMessages = <Map<String, String>>[];
    if (systemPrompt != null) {
      allMessages.add({'role': 'system', 'content': systemPrompt});
    }
    allMessages.addAll(messages.map((m) => m.toJson()));

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _chatCompletionsUrl,
        data: {
          'model': model ?? _defaultModel,
          'messages': allMessages,
          'temperature': temperature,
          'max_tokens': maxTokens,
          'stream': false,
        },
      );

      final data = response.data;
      if (data == null) {
        throw const AiServiceException('Empty response from server');
      }
      final choices = data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) {
        throw const AiServiceException('No choices in response');
      }
      final message = choices[0]['message'] as Map<String, dynamic>?;
      final content =
          _extractMessageText(message?['content']) ??
          _extractMessageText(message?['text']) ??
          '';
      final usage = data['usage'] as Map<String, dynamic>?;

      return AiCompletionResult(
        text: content,
        promptTokens: usage?['prompt_tokens'] as int? ?? 0,
        completionTokens: usage?['completion_tokens'] as int? ?? 0,
        model: data['model'] as String?,
      );
    } on DioException catch (e) {
      debugLog('AiDatasource: Completion error: ${e.message}');
      final errorMsg = _parseErrorMessage(e);
      throw AiServiceException(errorMsg);
    }
  }

  @override
  Future<String> summarize(
    String text, {
    String? language,
    int maxLength = 200,
  }) async {
    final lang = language ?? 'the same language as the input text';
    final result = await completion(
      [AiMessage(role: AiRole.user, content: text)],
      systemPrompt:
          'You are a concise summarizer. Summarize the following text in $lang. '
          'Keep the summary under $maxLength characters. '
          'Focus on key points and main ideas. Output only the summary, no extra text.',
      temperature: 0.3,
      maxTokens: 512,
    );
    return result.text.trim();
  }

  @override
  Future<String> rewriteMessage(String text, AiTone tone) async {
    final toneDesc = switch (tone) {
      AiTone.formal => 'formal and polite',
      AiTone.casual => 'casual and relaxed',
      AiTone.playful => 'playful and fun',
      AiTone.professional => 'professional and business-like',
    };

    final result = await completion(
      [AiMessage(role: AiRole.user, content: text)],
      systemPrompt:
          'Rewrite the following message in a $toneDesc tone. '
          'Keep the same meaning and language. '
          'Output only the rewritten message, no explanation.',
      temperature: 0.6,
      maxTokens: 512,
    );
    return result.text.trim();
  }

  @override
  Future<String> translateMessage(String text, String targetLanguage) async {
    final result = await completion(
      [AiMessage(role: AiRole.user, content: text)],
      systemPrompt:
          'Translate the following text to $targetLanguage. '
          'Output only the translation, no explanation or original text.',
      temperature: 0.3,
      maxTokens: 1024,
    );
    return result.text.trim();
  }

  @override
  Future<String> summarizeUrl(String url, String pageContent) async {
    // 截取前 4000 字符避免 token 超限（避免截断多字节字符）
    final truncated = pageContent.length > 4000
        ? String.fromCharCodes(pageContent.runes.take(4000))
        : pageContent;

    final result = await completion(
      [
        AiMessage(
          role: AiRole.user,
          content: 'URL: $url\n\nContent:\n$truncated',
        ),
      ],
      systemPrompt:
          'Summarize the content of this web page in 2-3 sentences. '
          'Focus on the main topic and key information. '
          'Use the same language as the page content. '
          'Output only the summary.',
      temperature: 0.3,
      maxTokens: 256,
    );
    return result.text.trim();
  }

  @override
  Future<List<String>> suggestReplies(
    List<AiMessage> messages, {
    int count = 3,
    String? language,
  }) async {
    final safeCount = count.clamp(1, 6);
    final languageInstruction = language == null || language.trim().isEmpty
        ? 'Use the same language as the conversation.'
        : 'Write every suggestion in $language.';
    final result = await completion(
      messages,
      systemPrompt:
          'You generate short smart-reply suggestions for a chat conversation. '
          'Return a JSON array with exactly $safeCount strings. '
          'Each suggestion must be natural, standalone, and under 60 characters. '
          '$languageInstruction '
          'Do not include numbering, markdown, quotes, or explanations.',
      temperature: 0.5,
      maxTokens: 256,
    );
    return _parseReplySuggestions(result.text, expectedCount: safeCount);
  }

  String _parseErrorMessage(DioException e) {
    if (e.response?.data != null) {
      try {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          final error = data['error'];
          if (error is Map<String, dynamic>) {
            return error['message'] as String? ?? 'API error';
          }
          if (error is String) return error;
        }
      } catch (e) {
        debugLog('Error: $e');
      }
    }

    return switch (e.type) {
      DioExceptionType.connectionTimeout => 'Connection timeout',
      DioExceptionType.receiveTimeout => 'Response timeout',
      DioExceptionType.connectionError => 'Connection failed',
      _ => e.message ?? 'Unknown error',
    };
  }

  String? _extractInlineErrorMessage(Map<String, dynamic> data) {
    final error = data['error'];
    if (error is String && error.isNotEmpty) {
      return error;
    }
    if (error is Map<String, dynamic>) {
      final message = error['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }
    return null;
  }

  String? _extractMessageText(dynamic content) {
    if (content is String) {
      return content;
    }
    if (content is List) {
      final buffer = StringBuffer();
      for (final part in content) {
        final text = _extractTextPart(part);
        if (text != null && text.isNotEmpty) {
          buffer.write(text);
        }
      }
      final combined = buffer.toString();
      return combined.isEmpty ? null : combined;
    }
    return _extractTextPart(content);
  }

  String? _extractTextPart(dynamic part) {
    if (part is String) {
      return part;
    }
    if (part is! Map<String, dynamic>) {
      return null;
    }

    final directText = part['text'];
    if (directText is String && directText.isNotEmpty) {
      return directText;
    }
    if (directText is Map<String, dynamic>) {
      final value = directText['value'];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }

    final nestedContent = part['content'];
    if (nestedContent is String && nestedContent.isNotEmpty) {
      return nestedContent;
    }

    return null;
  }

  List<String> _parseReplySuggestions(
    String raw, {
    required int expectedCount,
  }) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const [];

    final parsedJson = _tryParseSuggestionJson(trimmed);
    if (parsedJson.isNotEmpty) {
      return parsedJson.take(expectedCount).toList();
    }

    final suggestions = trimmed
        .split(_newlineRegExp)
        .map((line) => _stripReplyListPrefix(line.trim()))
        .where((line) => line.isNotEmpty)
        .fold<List<String>>(<String>[], (list, line) {
          if (!list.contains(line)) {
            list.add(line);
          }
          return list;
        });
    return suggestions.take(expectedCount).toList();
  }

  List<String> _tryParseSuggestionJson(String raw) {
    List<String> normalize(List<dynamic> values) {
      return values
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .fold<List<String>>(<String>[], (list, item) {
            if (!list.contains(item)) {
              list.add(item);
            }
            return list;
          });
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List<dynamic>) {
        return normalize(decoded);
      }
    } catch (_) {
      final arrayMatch = _arrayRegExp.firstMatch(raw);
      if (arrayMatch == null) {
        return const [];
      }
      try {
        final decoded = jsonDecode(arrayMatch.group(0)!);
        if (decoded is List<dynamic>) {
          return normalize(decoded);
        }
      } catch (_) {
        return const [];
      }
    }
    return const [];
  }

  String _stripReplyListPrefix(String line) {
    return line.replaceFirst(_listPrefixRegExp, '').trim();
  }

  String _buildChatCompletionsUrl() {
    final baseUri = Uri.tryParse(_baseUrl);
    if (baseUri == null) return '$_baseUrl/v1/chat/completions';

    final normalizedPath = baseUri.path.replaceFirst(_trailingSlashRegExp, '');
    final endpointPath = switch (normalizedPath) {
      '' => '/v1/chat/completions',
      '/v1' => '/v1/chat/completions',
      '/chat/completions' => '/v1/chat/completions',
      final String path when path.endsWith('/v1/chat/completions') => path,
      final String path when path.endsWith('/v1') => '$path/chat/completions',
      final String path => '$path/v1/chat/completions',
    };

    return baseUri
        .replace(path: endpointPath, queryParameters: null)
        .toString();
  }

  @override
  void dispose() {
    _dio.close();
  }
}

/// AI 服务异常
class AiServiceException implements Exception {
  final String message;
  const AiServiceException(this.message);

  @override
  String toString() => 'AiServiceException: $message';
}
