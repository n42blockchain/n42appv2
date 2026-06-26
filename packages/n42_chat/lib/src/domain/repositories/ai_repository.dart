import '../entities/ai_assistant_entity.dart';
import '../../core/services/ai_service.dart';

/// AI 仓库接口
///
/// 管理 AI 助手配置、会话历史的持久化
abstract class IAiRepository {
  /// 获取 AI 服务实例
  AiService get aiService;

  /// 获取所有 AI 助手
  Future<List<AiAssistantEntity>> getAssistants();

  /// 获取默认 AI 助手
  Future<AiAssistantEntity> getDefaultAssistant();

  /// 保存自定义 AI 助手
  Future<void> saveAssistant(AiAssistantEntity assistant);

  /// 删除 AI 助手
  Future<void> deleteAssistant(String assistantId);

  /// 获取 AI 会话历史
  Future<List<AiChatMessage>> getChatHistory(String assistantId);

  /// 保存 AI 会话消息
  Future<void> saveChatMessage(String assistantId, AiChatMessage message);

  /// 清除 AI 会话历史
  Future<void> clearChatHistory(String assistantId);

  /// AI 是否可用
  bool get isAvailable;
}
