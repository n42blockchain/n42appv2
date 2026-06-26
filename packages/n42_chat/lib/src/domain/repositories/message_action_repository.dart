import '../entities/message_entity.dart';
import '../entities/message_reaction_entity.dart';

/// 消息操作仓库接口
abstract class IMessageActionRepository {
  // ============================================
  // 消息反应
  // ============================================

  /// 添加emoji反应
  Future<void> addReaction(String roomId, String eventId, String emoji);

  /// 移除emoji反应
  Future<void> removeReaction(String roomId, String eventId, String emoji);

  /// 切换反应（如果已有则移除，否则添加）
  Future<void> toggleReaction(String roomId, String eventId, String emoji);

  /// 获取消息的所有反应
  Future<List<MessageReactionEntity>> getReactions(String roomId, String eventId);

  // ============================================
  // 消息回复
  // ============================================

  /// 回复消息
  Future<MessageEntity?> replyToMessage(
    String roomId,
    String originalEventId,
    String content,
  );

  // ============================================
  // 消息编辑
  // ============================================

  /// 编辑消息
  Future<MessageEntity?> editMessage(
    String roomId,
    String originalEventId,
    String newContent,
  );

  /// 检查是否可以编辑
  bool canEdit(String roomId, String senderId);

  // ============================================
  // 消息撤回
  // ============================================

  /// 撤回消息
  Future<void> redactMessage(String roomId, String eventId, {String? reason});

  /// 检查是否可以撤回
  bool canRedact(String roomId, String senderId);

  // ============================================
  // 消息转发
  // ============================================

  /// 转发消息到指定房间
  Future<MessageEntity?> forwardMessage(
    String fromRoomId,
    String eventId,
    String toRoomId,
  );

  /// 转发消息到多个房间
  Future<Map<String, bool>> forwardToMultipleRooms(
    String fromRoomId,
    String eventId,
    List<String> toRoomIds,
  );

  // ============================================
  // 消息收藏
  // ============================================

  /// 收藏消息
  Future<void> saveMessage(MessageEntity message);

  /// 取消收藏
  Future<void> unsaveMessage(String messageId);

  /// 获取收藏的消息列表
  Future<List<MessageEntity>> getSavedMessages();

  /// 检查消息是否已收藏
  Future<bool> isMessageSaved(String messageId);

  /// 编辑收藏标签
  Future<void> editFavoriteTags(String favoriteId, List<String> tags);

  /// 编辑收藏备注
  Future<void> editFavoriteRemark(String favoriteId, String remark);
}

