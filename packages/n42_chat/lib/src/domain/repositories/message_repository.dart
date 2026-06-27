import 'dart:typed_data';

import '../entities/group_album_entity.dart';
import '../entities/group_file_entity.dart';
import '../entities/message_entity.dart';

/// 消息仓库接口
///
/// 定义消息相关的业务操作
abstract class IMessageRepository {
  /// 获取房间消息列表
  Future<List<MessageEntity>> getMessages(
    String roomId, {
    int limit = 50,
    String? beforeEventId,
  });

  /// 监听房间消息更新
  Stream<List<MessageEntity>> watchMessages(String roomId);

  /// 监听单条消息更新
  Stream<MessageEntity?> watchMessage(String roomId, String messageId);

  /// 加载更多历史消息
  Future<List<MessageEntity>> loadMoreMessages(String roomId, {int limit = 50});

  /// 发送文本消息
  ///
  /// [selfDestructAfter] 阅后即焚秒数，null 表示不自毁
  /// [mentionedUserIds] 提及的用户ID列表
  /// [mentionsRoom] 是否 @全体成员
  Future<MessageEntity?> sendTextMessage(
    String roomId,
    String text, {
    int? selfDestructAfter,
    List<String>? mentionedUserIds,
    bool mentionsRoom = false,
  });

  /// 发送图片消息
  Future<MessageEntity?> sendImageMessage(
    String roomId, {
    required Uint8List imageBytes,
    required String filename,
    String? mimeType,
    int? selfDestructAfter,
  });

  /// 发送语音消息
  Future<MessageEntity?> sendVoiceMessage(
    String roomId, {
    required Uint8List audioBytes,
    required String filename,
    required int duration,
    String? mimeType,
    int? selfDestructAfter,
  });

  /// 发送视频消息
  Future<MessageEntity?> sendVideoMessage(
    String roomId, {
    required Uint8List videoBytes,
    required String filename,
    String? mimeType,
    Uint8List? thumbnailBytes,
    int? selfDestructAfter,
  });

  /// 发送文件消息
  Future<MessageEntity?> sendFileMessage(
    String roomId, {
    Uint8List? fileBytes,
    required String filename,
    String? mimeType,
    int? selfDestructAfter,
    String? filePath,
    Stream<List<int>>? fileStream,
    int? fileSize,
  });

  /// 发送位置消息
  Future<MessageEntity?> sendLocationMessage(
    String roomId, {
    required double latitude,
    required double longitude,
    String? description,
  });

  /// 发送 GIF 消息
  Future<MessageEntity?> sendGifMessage(
    String roomId, {
    required String gifUrl,
    String? previewUrl,
    int? width,
    int? height,
    String? title,
  });

  /// 发送贴纸消息
  Future<MessageEntity?> sendStickerMessage(
    String roomId, {
    required String stickerId,
    required String packId,
    required String url,
    String? httpUrl,
    String? name,
    String? emoji,
    int? width,
    int? height,
    String? mimeType,
    int? size,
  });

  /// 重发失败的消息
  Future<bool> resendMessage(String roomId, String messageId);

  /// 撤回消息
  Future<bool> redactMessage(String roomId, String messageId, {String? reason});

  /// 删除发送失败的消息（从本地和服务器）
  Future<bool> deleteFailedMessage(String roomId, String messageId);

  /// 回复消息
  Future<MessageEntity?> replyToMessage(
    String roomId,
    String replyToMessageId,
    String text, {
    int? selfDestructAfter,
    List<String>? mentionedUserIds,
    bool mentionsRoom = false,
  });

  /// 编辑消息
  Future<MessageEntity?> editMessage(
    String roomId,
    String messageId,
    String newText,
  );

  /// 添加表情回应
  Future<bool> addReaction(String roomId, String messageId, String emoji);

  /// 移除表情回应
  Future<bool> removeReaction(String roomId, String messageId, String emoji);

  /// 标记消息已读
  Future<void> markAsRead(String roomId, String messageId);

  /// 发送正在输入状态
  Future<void> sendTypingNotification(String roomId, bool isTyping);

  /// 发送系统通知/拍一拍消息
  Future<MessageEntity?> sendNoticeMessage({
    required String roomId,
    required String notice,
  });

  /// 获取房间成员的拍一拍后缀
  Future<String?> getMemberPokeText({
    required String roomId,
    required String userId,
  });

  /// 获取媒体下载URL
  String? getMediaUrl(String? mxcUrl, {int? width, int? height});

  /// 下载媒体文件
  Future<Uint8List?> downloadMedia(String mxcUrl);

  /// 转发媒体消息（使用现有的 mxc URL，不需要重新上传）
  Future<MessageEntity?> forwardMediaMessage(
    String roomId, {
    required String mxcUrl,
    required String msgType,
    required String filename,
    String? mimeType,
    int? width,
    int? height,
    int? size,
    int? duration,
    String? thumbnailUrl,
  });

  /// 获取当前用户ID
  Future<String?> getCurrentUserId();

  /// 发送投票消息
  Future<MessageEntity?> sendPollMessage(
    String roomId, {
    required String question,
    required List<String> options,
    int maxSelections = 1,
    bool isAnonymous = false,
    int? quizCorrectIndex,
    String? quizExplanation,
  });

  /// 发送转发的投票快照（包含投票结果，不可再投票）
  Future<MessageEntity?> sendForwardedPollSnapshot(
    String roomId, {
    required String question,
    required List<String> options,
    required List<String> optionIds,
    required Map<String, int> voteCounts,
    required int totalVoters,
    int maxSelections = 1,
  });

  /// 投票响应
  Future<bool> voteOnPoll(
    String roomId, {
    required String pollEventId,
    required List<String> selectedOptionIds,
  });

  /// 获取投票聚合结果
  Future<Map<String, dynamic>?> getPollAggregations(
    String roomId,
    String pollEventId,
  );

  /// 监听投票响应事件
  Stream<Map<String, dynamic>>? watchPollResponses(String roomId);

  /// 结束投票
  Future<bool> endPoll(String roomId, String pollEventId);

  /// 获取消息反应聚合结果
  Future<Map<String, dynamic>?> getReactionAggregations(
    String roomId,
    String eventId,
  );

  /// 发送自定义消息（红包、转账等）
  Future<String?> sendCustomMessage(
    String roomId, {
    required String msgType,
    required String content,
    Map<String, dynamic>? additionalData,
  });

  /// 发送联系人名片消息
  Future<String?> sendContactCard(
    String roomId, {
    required String userId,
    required String displayName,
    String? avatarUrl,
    String? matrixId,
  });

  /// 获取房间的本地删除消息ID列表
  Future<Set<String>> getLocallyDeletedMessageIds(String roomId);

  /// 标记消息为本地删除（持久化存储）
  Future<void> markMessagesAsLocallyDeleted(
    String roomId,
    List<String> messageIds,
  );

  /// 清除房间的本地删除消息记录
  Future<void> clearLocallyDeletedMessages(String roomId);

  /// 发送阅后即焚消息
  ///
  /// [selfDestructAfter] 消息被阅读后多少秒自毁
  Future<MessageEntity?> sendSelfDestructingMessage(
    String roomId,
    String text, {
    required int selfDestructAfter,
  });

  /// 开始消息的自毁倒计时（消息被阅读时调用）
  ///
  /// 返回更新后的消息（设置了 destroyedAt）
  Future<MessageEntity?> startMessageDestruction(
    String roomId,
    String messageId,
  );

  /// 销毁已过期的消息
  ///
  /// 自动删除所有已过期的阅后即焚消息
  Future<void> destroyExpiredMessages(String roomId);

  // ============================================
  // 消息线程 (MSC3440)
  // ============================================

  /// 获取线程内的消息列表
  ///
  /// [roomId] 房间 ID
  /// [threadRootEventId] 线程根事件 ID
  /// [limit] 获取数量限制
  /// [fromEventId] 分页游标
  Future<List<MessageEntity>> getThreadMessages(
    String roomId,
    String threadRootEventId, {
    int limit = 50,
    String? fromEventId,
  });

  /// 监听线程消息更新
  Stream<List<MessageEntity>> watchThreadMessages(
    String roomId,
    String threadRootEventId,
  );

  /// 在线程内发送文本消息
  Future<MessageEntity?> sendThreadTextMessage(
    String roomId,
    String threadRootEventId,
    String text,
  );

  /// 在线程内发送图片消息
  Future<MessageEntity?> sendThreadImageMessage(
    String roomId,
    String threadRootEventId, {
    required Uint8List imageBytes,
    required String filename,
    String? mimeType,
  });

  /// 在线程内发送文件消息
  Future<MessageEntity?> sendThreadFileMessage(
    String roomId,
    String threadRootEventId, {
    required Uint8List fileBytes,
    required String filename,
    String? mimeType,
  });

  /// 获取房间内所有线程根消息
  Future<List<MessageEntity>> getRoomThreadRoots(String roomId);

  /// 获取房间媒体文件列表
  ///
  /// 从房间 timeline 中提取图片、视频等媒体文件
  /// [filter] 可按类型、发送者、日期范围筛选
  /// [limit] 单次获取数量限制
  /// [beforeEventId] 用于分页，获取此事件之前的媒体
  Future<List<AlbumMediaEntity>> getRoomMedia(
    String roomId, {
    AlbumFilter? filter,
    int limit = 50,
    String? beforeEventId,
  });

  // ============================================
  // 举报
  // ============================================

  /// 举报消息（Matrix reportEvent API）
  Future<void> reportMessage(
    String roomId,
    String eventId, {
    required String reason,
  });

  // ============================================
  // 群文件管理
  // ============================================

  /// 获取房间文件列表
  Future<List<GroupFileEntity>> getRoomFiles(
    String roomId, {
    GroupFileType? type,
    int limit = 50,
    String? fromEventId,
  });
}
