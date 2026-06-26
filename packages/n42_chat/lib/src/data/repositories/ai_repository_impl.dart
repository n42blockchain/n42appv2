import 'dart:convert';
import 'dart:async';


import '../../core/services/ai_service.dart';
import '../../domain/entities/ai_assistant_entity.dart';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/local/preferences_datasource.dart';
import '../../core/utils/debug_log.dart';

/// AI 仓库实现
class AiRepositoryImpl implements IAiRepository {
  static const String _keyAssistants = 'n42_chat_ai_assistants';
  static const String _keyChatHistoryPrefix = 'n42_chat_ai_history_';

  final AiService _aiService;
  final PreferencesDataSource _storage;
  final Map<String, Future<void>> _writeQueues = {};

  AiRepositoryImpl({
    required AiService aiService,
    required PreferencesDataSource storage,
  })  : _aiService = aiService,
        _storage = storage;

  @override
  AiService get aiService => _aiService;

  @override
  bool get isAvailable => _aiService.isAvailable;

  @override
  Future<List<AiAssistantEntity>> getAssistants() async {
    try {
      final data = await _storage.read(_keyAssistants);
      if (data == null) {
        return [AiAssistantEntity.defaultAssistant];
      }
      final list = jsonDecode(data) as List<dynamic>;
      final assistants = list
          .map((e) => AiAssistantEntity.fromJson(e as Map<String, dynamic>))
          .toList();
      // 确保默认助手总是存在
      if (!assistants.any((a) => a.id == 'default')) {
        assistants.insert(0, AiAssistantEntity.defaultAssistant);
      }
      return assistants;
    } catch (e) {
      debugLog('AiRepository: Failed to load assistants: $e');
      return [AiAssistantEntity.defaultAssistant];
    }
  }

  @override
  Future<AiAssistantEntity> getDefaultAssistant() async {
    final assistants = await getAssistants();
    return assistants.firstWhere(
      (a) => a.id == 'default',
      orElse: () => AiAssistantEntity.defaultAssistant,
    );
  }

  @override
  Future<void> saveAssistant(AiAssistantEntity assistant) async {
    try {
      await _serializeWrite(_keyAssistants, () async {
        final assistants = await getAssistants();
        final index = assistants.indexWhere((a) => a.id == assistant.id);
        if (index >= 0) {
          assistants[index] = assistant;
        } else {
          assistants.add(assistant);
        }
        final data = jsonEncode(assistants.map((a) => a.toJson()).toList());
        await _storage.write(_keyAssistants, data);
      });
    } catch (e) {
      debugLog('AiRepository: Failed to save assistant: $e');
    }
  }

  @override
  Future<void> deleteAssistant(String assistantId) async {
    if (assistantId == 'default') return; // 不允许删除默认助手
    try {
      await _serializeWrite(_keyAssistants, () async {
        final assistants = await getAssistants();
        assistants.removeWhere((a) => a.id == assistantId);
        final data = jsonEncode(assistants.map((a) => a.toJson()).toList());
        await _storage.write(_keyAssistants, data);
      });
      await clearChatHistory(assistantId);
    } catch (e) {
      debugLog('AiRepository: Failed to delete assistant: $e');
    }
  }

  @override
  Future<List<AiChatMessage>> getChatHistory(String assistantId) async {
    try {
      final data = await _storage.read('$_keyChatHistoryPrefix$assistantId');
      if (data == null) return [];
      final list = jsonDecode(data) as List<dynamic>;
      return list
          .map((e) => AiChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugLog('AiRepository: Failed to load chat history: $e');
      return [];
    }
  }

  @override
  Future<void> saveChatMessage(String assistantId, AiChatMessage message) async {
    final historyKey = _historyKey(assistantId);
    try {
      await _serializeWrite(historyKey, () async {
        final history = await getChatHistory(assistantId);
        history.add(message);

        // 保持最近 100 条消息
        final trimmed = history.length > 100
            ? history.sublist(history.length - 100)
            : history;

        final data = jsonEncode(trimmed.map((m) => m.toJson()).toList());
        await _storage.write(historyKey, data);
      });
    } catch (e) {
      debugLog('AiRepository: Failed to save chat message: $e');
    }
  }

  @override
  Future<void> clearChatHistory(String assistantId) async {
    final historyKey = _historyKey(assistantId);
    try {
      await _serializeWrite(historyKey, () => _storage.delete(historyKey));
    } catch (e) {
      debugLog('AiRepository: Failed to clear chat history: $e');
    }
  }

  String _historyKey(String assistantId) => '$_keyChatHistoryPrefix$assistantId';

  Future<void> _serializeWrite(
    String key,
    Future<void> Function() operation,
  ) async {
    final previous = _writeQueues[key] ?? Future<void>.value();
    final completer = Completer<void>();
    _writeQueues[key] = completer.future;

    try {
      await previous.catchError((_) {});
      await operation();
    } finally {
      completer.complete();
      if (identical(_writeQueues[key], completer.future)) {
        unawaited(_writeQueues.remove(key));
      }
    }
  }
}
