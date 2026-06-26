import '../../domain/entities/conversation_entity.dart';

/// 会话仓库接口
///
/// 定义会话相关的业务操作
abstract class IConversationRepository {
  /// 获取所有会话列表
  Future<List<ConversationEntity>> getConversations();

  /// 获取会话列表流（实时更新）
  Stream<List<ConversationEntity>> watchConversations();

  /// 根据ID获取单个会话
  Future<ConversationEntity?> getConversationById(String id);

  /// 监听单个会话变化
  Stream<ConversationEntity?> watchConversation(String id);

  /// 创建私聊会话
  Future<ConversationEntity> createDirectChat(String userId);

  /// 创建群聊会话
  Future<ConversationEntity> createGroupChat({
    required String name,
    String? topic,
    List<String>? memberIds,
    bool encrypted,
  });

  /// 加入会话
  Future<void> joinConversation(String conversationIdOrAlias);

  /// 离开会话
  Future<void> leaveConversation(String conversationId);

  /// 删除会话（本地）
  Future<void> deleteConversation(String conversationId);

  /// 设置会话免打扰
  Future<void> setMuted(String conversationId, bool muted);

  /// 设置会话通知模式
  Future<void> setNotificationMode(
    String conversationId,
    ConversationNotificationMode mode,
  );

  /// 获取会话通知模式
  Future<ConversationNotificationMode> getNotificationMode(
    String conversationId,
  );

  /// 设置会话置顶
  Future<void> setPinned(String conversationId, bool pinned);

  /// 设置强提醒
  Future<void> setStrongReminder(String conversationId, bool enabled);

  /// 获取强提醒状态
  Future<bool> getStrongReminder(String conversationId);

  /// 标记会话已读
  Future<void> markAsRead(String conversationId);

  /// 获取未读消息总数
  Future<int> getTotalUnreadCount();

  /// 监听未读消息总数
  Stream<int> watchTotalUnreadCount();

  /// 搜索会话
  Future<List<ConversationEntity>> searchConversations(String query);
}
