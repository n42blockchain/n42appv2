import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../../domain/entities/content_filter_entity.dart';
import '../../../domain/entities/message_entity.dart';

/// 聊天事件
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// 初始化聊天室
class InitializeChat extends ChatEvent {
  final String roomId;

  const InitializeChat(this.roomId);

  @override
  List<Object?> get props => [roomId];
}

/// 加载消息
class LoadMessages extends ChatEvent {
  final String roomId;
  final int limit;

  const LoadMessages(this.roomId, {this.limit = 100});

  @override
  List<Object?> get props => [roomId, limit];
}

/// 加载更多历史消息
class LoadMoreMessages extends ChatEvent {
  const LoadMoreMessages();
}

/// 订阅消息更新
class SubscribeMessages extends ChatEvent {
  const SubscribeMessages();
}

/// 取消订阅
class UnsubscribeMessages extends ChatEvent {
  const UnsubscribeMessages();
}

/// 发送文本消息
class SendTextMessage extends ChatEvent {
  final String text;
  final int? selfDestructAfter;
  final List<String>? mentionedUserIds;
  final bool mentionsRoom;

  const SendTextMessage(
    this.text, {
    this.selfDestructAfter,
    this.mentionedUserIds,
    this.mentionsRoom = false,
  });

  @override
  List<Object?> get props => [
    text,
    selfDestructAfter,
    mentionedUserIds,
    mentionsRoom,
  ];
}

/// 发送图片消息
class SendImageMessage extends ChatEvent {
  final Uint8List imageBytes;
  final String filename;
  final String? mimeType;
  final int? selfDestructAfter;

  const SendImageMessage({
    required this.imageBytes,
    required this.filename,
    this.mimeType,
    this.selfDestructAfter,
  });

  @override
  List<Object?> get props => [
    imageBytes,
    filename,
    mimeType,
    selfDestructAfter,
  ];
}

/// 发送语音消息
class SendVoiceMessage extends ChatEvent {
  final Uint8List audioBytes;
  final String filename;
  final int duration;
  final String? mimeType;
  final int? selfDestructAfter;

  const SendVoiceMessage({
    required this.audioBytes,
    required this.filename,
    required this.duration,
    this.mimeType,
    this.selfDestructAfter,
  });

  @override
  List<Object?> get props => [
    audioBytes,
    filename,
    duration,
    mimeType,
    selfDestructAfter,
  ];
}

/// 发送文件消息
class SendFileMessage extends ChatEvent {
  final Uint8List? fileBytes;
  final String filename;
  final String? mimeType;
  final int? selfDestructAfter;
  final String? filePath;
  final Stream<List<int>>? fileStream;
  final int? fileSize;

  const SendFileMessage({
    this.fileBytes,
    required this.filename,
    this.mimeType,
    this.selfDestructAfter,
    this.filePath,
    this.fileStream,
    this.fileSize,
  }) : assert(
         fileBytes != null || filePath != null || fileStream != null,
         'SendFileMessage requires bytes, filePath, or fileStream',
       );

  @override
  List<Object?> get props => [
    fileBytes,
    filename,
    mimeType,
    selfDestructAfter,
    filePath,
    fileStream,
    fileSize,
  ];
}

/// 发送视频消息（带缩略图）
class SendVideoMessage extends ChatEvent {
  final Uint8List videoBytes;
  final String filename;
  final String? mimeType;
  final Uint8List? thumbnailBytes;
  final int? selfDestructAfter;

  const SendVideoMessage({
    required this.videoBytes,
    required this.filename,
    this.mimeType,
    this.thumbnailBytes,
    this.selfDestructAfter,
  });

  @override
  List<Object?> get props => [
    videoBytes,
    filename,
    mimeType,
    thumbnailBytes,
    selfDestructAfter,
  ];
}

/// 发送位置消息
class SendLocationMessage extends ChatEvent {
  final double latitude;
  final double longitude;
  final String? description;

  const SendLocationMessage({
    required this.latitude,
    required this.longitude,
    this.description,
  });

  @override
  List<Object?> get props => [latitude, longitude, description];
}

/// 重发消息
class ResendMessage extends ChatEvent {
  final String messageId;

  const ResendMessage(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

/// 撤回消息
class RedactMessage extends ChatEvent {
  final String messageId;
  final String? reason;

  const RedactMessage(this.messageId, {this.reason});

  @override
  List<Object?> get props => [messageId, reason];
}

/// 本地删除消息（不发送到服务器，仅从 UI 中移除）
class DeleteMessagesLocally extends ChatEvent {
  final List<String> messageIds;

  const DeleteMessagesLocally(this.messageIds);

  @override
  List<Object?> get props => [messageIds];
}

/// 删除发送失败的消息（从本地和服务器）
class DeleteFailedMessage extends ChatEvent {
  final String messageId;

  const DeleteFailedMessage(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

/// 回复消息
class ReplyToMessage extends ChatEvent {
  final String replyToMessageId;
  final String text;
  final int? selfDestructAfter;
  final List<String>? mentionedUserIds;
  final bool mentionsRoom;

  const ReplyToMessage({
    required this.replyToMessageId,
    required this.text,
    this.selfDestructAfter,
    this.mentionedUserIds,
    this.mentionsRoom = false,
  });

  @override
  List<Object?> get props => [
    replyToMessageId,
    text,
    selfDestructAfter,
    mentionedUserIds,
    mentionsRoom,
  ];
}

/// 设置回复目标
class SetReplyTarget extends ChatEvent {
  final MessageEntity? message;

  const SetReplyTarget(this.message);

  @override
  List<Object?> get props => [message];
}

/// 设置编辑目标（进入编辑模式）
class SetEditTarget extends ChatEvent {
  final MessageEntity? message;

  const SetEditTarget(this.message);

  @override
  List<Object?> get props => [message];
}

/// 添加表情回应
class AddReaction extends ChatEvent {
  final String messageId;
  final String emoji;

  const AddReaction({required this.messageId, required this.emoji});

  @override
  List<Object?> get props => [messageId, emoji];
}

/// 标记消息已读
class MarkMessageAsRead extends ChatEvent {
  final String messageId;

  const MarkMessageAsRead(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

/// 发送正在输入状态
class SendTypingNotification extends ChatEvent {
  final bool isTyping;

  const SendTypingNotification(this.isTyping);

  @override
  List<Object?> get props => [isTyping];
}

/// 消息列表更新（内部事件）
class MessagesUpdated extends ChatEvent {
  final List<MessageEntity> messages;

  const MessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// 正在输入的用户列表更新（内部事件）
class TypingUsersUpdated extends ChatEvent {
  final List<String> typingUsers;

  const TypingUsersUpdated(this.typingUsers);

  @override
  List<Object?> get props => [typingUsers];
}

/// 清理聊天室
class DisposeChat extends ChatEvent {
  const DisposeChat();
}

/// 发送系统通知/拍一拍消息
class SendSystemNotice extends ChatEvent {
  final String notice;

  const SendSystemNotice(this.notice);

  @override
  List<Object?> get props => [notice];
}

/// 发送拍一拍消息
class SendPokeMessage extends ChatEvent {
  final String pokerName;
  final String targetUserId;
  final String targetName;
  final String? pokerPokeText; // 拍人者的 pokeText（用于拍自己时）

  const SendPokeMessage({
    required this.pokerName,
    required this.targetUserId,
    required this.targetName,
    this.pokerPokeText,
  });

  @override
  List<Object?> get props => [
    pokerName,
    targetUserId,
    targetName,
    pokerPokeText,
  ];
}

/// 发送投票消息
class SendPollMessage extends ChatEvent {
  final String question;
  final List<String> options;
  final int maxSelections; // 1 = 单选, 0 = 多选（不限）
  final bool isAnonymous;

  const SendPollMessage({
    required this.question,
    required this.options,
    this.maxSelections = 1,
    this.isAnonymous = false,
  });

  @override
  List<Object?> get props => [question, options, maxSelections, isAnonymous];
}

/// 投票响应事件
class VoteOnPoll extends ChatEvent {
  final String pollEventId;
  final List<String> selectedOptionIds;

  const VoteOnPoll({
    required this.pollEventId,
    required this.selectedOptionIds,
  });

  @override
  List<Object?> get props => [pollEventId, selectedOptionIds];
}

/// 投票响应接收事件（从其他用户或服务器同步）
class PollResponseReceived extends ChatEvent {
  final String pollEventId;
  final List<String> selectedOptionIds;
  final String senderId;
  final bool isCurrentUser;

  const PollResponseReceived({
    required this.pollEventId,
    required this.selectedOptionIds,
    required this.senderId,
    required this.isCurrentUser,
  });

  @override
  List<Object?> get props => [
    pollEventId,
    selectedOptionIds,
    senderId,
    isCurrentUser,
  ];
}

/// 结束投票事件（主动结束）
class EndPoll extends ChatEvent {
  final String pollEventId;

  const EndPoll({required this.pollEventId});

  @override
  List<Object?> get props => [pollEventId];
}

/// 投票已结束事件（从服务器接收）
class PollEnded extends ChatEvent {
  final String pollEventId;

  const PollEnded({required this.pollEventId});

  @override
  List<Object?> get props => [pollEventId];
}

/// 发送自定义消息（红包、转账等）
class SendCustomMessage extends ChatEvent {
  final String content;
  final MessageType type;
  final MessageMetadata? metadata;

  const SendCustomMessage({
    required this.content,
    required this.type,
    this.metadata,
  });

  @override
  List<Object?> get props => [content, type, metadata];
}

/// 清空聊天记录（本地）
class ClearChatHistory extends ChatEvent {
  const ClearChatHistory();
}

/// 开始消息的自毁倒计时（消息被阅读时触发）
class StartMessageDestruction extends ChatEvent {
  final String messageId;

  const StartMessageDestruction(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

/// 销毁已过期的阅后即焚消息
class DestroyExpiredMessages extends ChatEvent {
  const DestroyExpiredMessages();
}

/// 更新阅后即焚消息的倒计时状态
class UpdateDestructionCountdown extends ChatEvent {
  final String messageId;
  final DateTime destroyedAt;

  const UpdateDestructionCountdown({
    required this.messageId,
    required this.destroyedAt,
  });

  @override
  List<Object?> get props => [messageId, destroyedAt];
}

/// 发送定时消息
class SendScheduledMessage extends ChatEvent {
  final String text;
  final MessageType type;
  final Map<String, dynamic>? payload;
  final DateTime scheduledAt;
  final int? selfDestructAfter;
  final List<String>? mentionedUserIds;
  final bool mentionsRoom;

  const SendScheduledMessage({
    required this.text,
    this.type = MessageType.text,
    this.payload,
    required this.scheduledAt,
    this.selfDestructAfter,
    this.mentionedUserIds,
    this.mentionsRoom = false,
  });

  @override
  List<Object?> get props => [
    text,
    type,
    payload == null ? null : jsonEncode(payload),
    scheduledAt,
    selfDestructAfter,
    mentionedUserIds,
    mentionsRoom,
  ];
}

/// 取消定时消息
class CancelScheduledMessage extends ChatEvent {
  final String messageId;

  const CancelScheduledMessage(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

/// 发送到期的定时消息（内部事件，由定时器触发）
class SendDueScheduledMessages extends ChatEvent {
  const SendDueScheduledMessages();
}

/// 语音消息转文字
class TranscribeVoiceMessage extends ChatEvent {
  final String messageId;
  final String? audioPath;
  final String language;

  const TranscribeVoiceMessage({
    required this.messageId,
    this.audioPath,
    this.language = 'zh-TW',
  });

  @override
  List<Object?> get props => [messageId, audioPath, language];
}

/// 语音转文字完成（内部事件）
class VoiceTranscriptionCompleted extends ChatEvent {
  final String messageId;
  final String? transcription;
  final bool success;

  const VoiceTranscriptionCompleted({
    required this.messageId,
    this.transcription,
    required this.success,
  });

  @override
  List<Object?> get props => [messageId, transcription, success];
}

/// 发送 GIF 消息
class SendGifMessage extends ChatEvent {
  final String gifUrl;
  final String? previewUrl;
  final int? width;
  final int? height;
  final String? title;

  const SendGifMessage({
    required this.gifUrl,
    this.previewUrl,
    this.width,
    this.height,
    this.title,
  });

  @override
  List<Object?> get props => [gifUrl, previewUrl, width, height, title];
}

/// 发送贴纸消息
class SendStickerMessage extends ChatEvent {
  final String stickerId;
  final String packId;
  final String url;
  final String? httpUrl;
  final String? name;
  final String? emoji;
  final int? width;
  final int? height;
  final String? mimeType;
  final int? size;

  const SendStickerMessage({
    required this.stickerId,
    required this.packId,
    required this.url,
    this.httpUrl,
    this.name,
    this.emoji,
    this.width,
    this.height,
    this.mimeType,
    this.size,
  });

  @override
  List<Object?> get props => [
    stickerId,
    packId,
    url,
    httpUrl,
    name,
    emoji,
    width,
    height,
    mimeType,
    size,
  ];
}

// ============================================
// 置顶消息事件
// ============================================

/// 加载置顶消息
class LoadPinnedMessages extends ChatEvent {
  const LoadPinnedMessages();
}

/// 置顶消息
class PinMessage extends ChatEvent {
  final String messageId;

  const PinMessage(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

/// 取消置顶消息
class UnpinMessage extends ChatEvent {
  final String messageId;

  const UnpinMessage(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

/// 切换到下一个/上一个置顶消息
class NavigatePinnedMessage extends ChatEvent {
  final int delta; // 1 = 下一个, -1 = 上一个

  const NavigatePinnedMessage(this.delta);

  @override
  List<Object?> get props => [delta];
}

// ============================================
// 消息翻译事件
// ============================================

/// 翻译消息
class TranslateMessage extends ChatEvent {
  final String messageId;
  final String targetLanguage;

  const TranslateMessage({
    required this.messageId,
    required this.targetLanguage,
  });

  @override
  List<Object?> get props => [messageId, targetLanguage];
}

/// 翻译完成（内部事件）
class TranslationCompleted extends ChatEvent {
  final String messageId;
  final String? translatedText;
  final String? detectedSourceLanguage;
  final bool success;
  final String? error;

  const TranslationCompleted({
    required this.messageId,
    this.translatedText,
    this.detectedSourceLanguage,
    required this.success,
    this.error,
  });

  @override
  List<Object?> get props => [
    messageId,
    translatedText,
    detectedSourceLanguage,
    success,
    error,
  ];
}

/// 清除消息翻译
class ClearTranslation extends ChatEvent {
  final String messageId;

  const ClearTranslation(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

/// 更新翻译设置
class UpdateTranslationSettings extends ChatEvent {
  final bool? autoTranslate;
  final String? defaultTargetLanguage;
  final bool? smartReplyTranslate;

  const UpdateTranslationSettings({
    this.autoTranslate,
    this.defaultTargetLanguage,
    this.smartReplyTranslate,
  });

  @override
  List<Object?> get props => [
    autoTranslate,
    defaultTargetLanguage,
    smartReplyTranslate,
  ];
}

/// 翻译设置加载完成（内部事件）
class TranslationSettingsLoaded extends ChatEvent {
  final bool autoTranslate;
  final String defaultTargetLanguage;
  final bool smartReplyTranslate;

  const TranslationSettingsLoaded({
    required this.autoTranslate,
    required this.defaultTargetLanguage,
    this.smartReplyTranslate = false,
  });

  @override
  List<Object?> get props => [
    autoTranslate,
    defaultTargetLanguage,
    smartReplyTranslate,
  ];
}

// ============================================
// 离线消息自动重试事件
// ============================================

/// 连接恢复后自动重试待发送的消息
class RetryPendingMessages extends ChatEvent {
  const RetryPendingMessages();
}

/// 连接状态变化
class ConnectionStatusChanged extends ChatEvent {
  final bool isConnected;

  const ConnectionStatusChanged(this.isConnected);

  @override
  List<Object?> get props => [isConnected];
}

/// 销毁时间加载完成（内部事件，替代 Future.microtask + 直接 emit）
class DestructionTimesLoaded extends ChatEvent {
  final Map<String, DateTime> destructionTimes;

  const DestructionTimesLoaded(this.destructionTimes);

  @override
  List<Object?> get props => [destructionTimes];
}

/// 发送联系人名片消息
class SendContactCardMessage extends ChatEvent {
  final String userId;
  final String displayName;
  final String? avatarUrl;

  const SendContactCardMessage({
    required this.userId,
    required this.displayName,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [userId, displayName, avatarUrl];
}

/// 执行斜杠命令
class ExecuteSlashCommand extends ChatEvent {
  final String command; // 命令名（如 "announce"）
  final String args; // 命令参数部分

  const ExecuteSlashCommand({required this.command, required this.args});

  @override
  List<Object?> get props => [command, args];
}

/// 房间信息加载完成（频道判断、发言权限等）
class RoomInfoLoaded extends ChatEvent {
  final bool isChannel;
  final bool canSendMessages;
  final int slowModeInterval;

  const RoomInfoLoaded({
    required this.isChannel,
    required this.canSendMessages,
    this.slowModeInterval = 0,
  });

  @override
  List<Object?> get props => [isChannel, canSendMessages, slowModeInterval];
}

/// 清除待处理的斜杠命令信号
class ClearPendingCommand extends ChatEvent {
  const ClearPendingCommand();

  @override
  List<Object?> get props => [];
}

/// 举报消息
class ReportMessage extends ChatEvent {
  final String messageId;
  final String reason;

  const ReportMessage(this.messageId, this.reason);

  @override
  List<Object?> get props => [messageId, reason];
}

/// 关键词过滤配置加载完成（内部事件）
class ContentFilterLoaded extends ChatEvent {
  final ContentFilterConfig? config;

  const ContentFilterLoaded(this.config);

  @override
  List<Object?> get props => [config];
}

/// 定时消息预览加载完成（内部事件）
class ScheduledMessagesPreviewLoaded extends ChatEvent {
  final List<MessageEntity> previewMessages;

  const ScheduledMessagesPreviewLoaded(this.previewMessages);

  @override
  List<Object?> get props => [previewMessages];
}

/// 对方语言检测完成（内部事件）
class RecipientLanguageDetected extends ChatEvent {
  final String language;

  const RecipientLanguageDetected(this.language);

  @override
  List<Object?> get props => [language];
}
