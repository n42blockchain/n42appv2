import 'package:equatable/equatable.dart';

import '../../../domain/entities/content_filter_entity.dart';
import '../../../domain/entities/message_entity.dart';

/// 聊天状态
class ChatState extends Equatable {
  /// 房间ID
  final String? roomId;

  /// 消息列表（按时间倒序）
  final List<MessageEntity> messages;

  /// 是否正在加载
  final bool isLoading;

  /// 是否正在加载更多
  final bool isLoadingMore;

  /// 是否还有更多历史消息
  final bool hasMore;

  /// 是否正在发送消息
  final bool isSending;

  /// 错误信息
  final String? error;

  /// 回复目标消息
  final MessageEntity? replyTarget;

  /// 正在编辑的消息（编辑模式）
  final MessageEntity? editingMessage;

  /// 正在输入的用户
  final List<String> typingUsers;

  /// 草稿
  final String? draft;

  /// 置顶消息列表
  final List<MessageEntity> pinnedMessages;

  /// 当前显示的置顶消息索引
  final int currentPinnedIndex;

  /// 当前用户是否可以置顶消息
  final bool canPinMessages;

  /// 消息翻译结果 (messageId -> translatedText)
  final Map<String, String> translatedMessages;

  /// 正在翻译的消息ID
  final Set<String> translatingMessageIds;

  /// 翻译检测到的源语言 (messageId -> sourceLanguage)
  final Map<String, String> detectedSourceLanguages;

  /// 是否自动翻译收到的消息
  final bool autoTranslate;

  /// 默认翻译目标语言
  final String defaultTargetLanguage;

  /// 是否启用智能回复翻译（发送时自动翻译为对方语言）
  final bool smartReplyTranslate;

  /// 检测到的对方最近消息语言
  final String? detectedRecipientLanguage;

  /// 智能回复原文映射 (messageId → 我方原文)
  final Map<String, String> smartReplyOriginals;

  /// 当前房间的关键词过滤配置
  final ContentFilterConfig? contentFilter;

  /// 待处理的斜杠命令（null 表示无）
  final String? pendingCommand;

  /// 是否为频道（公告频道）
  final bool isChannel;

  /// 当前用户是否可以在此房间发送消息
  final bool canSendMessages;

  /// 慢速模式间隔（秒），0 表示无慢速模式
  final int slowModeInterval;

  /// 上次发送消息的时间
  final DateTime? lastMessageSentAt;

  const ChatState({
    this.roomId,
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.isSending = false,
    this.error,
    this.replyTarget,
    this.editingMessage,
    this.typingUsers = const [],
    this.draft,
    this.pinnedMessages = const [],
    this.currentPinnedIndex = 0,
    this.canPinMessages = false,
    this.translatedMessages = const {},
    this.translatingMessageIds = const {},
    this.detectedSourceLanguages = const {},
    this.autoTranslate = false,
    this.defaultTargetLanguage = 'en',
    this.smartReplyTranslate = false,
    this.detectedRecipientLanguage,
    this.smartReplyOriginals = const {},
    this.contentFilter,
    this.pendingCommand,
    this.isChannel = false,
    this.canSendMessages = true,
    this.slowModeInterval = 0,
    this.lastMessageSentAt,
  });

  /// 初始状态
  factory ChatState.initial() {
    return const ChatState(isLoading: true);
  }

  /// 是否为空
  bool get isEmpty => messages.isEmpty;

  /// 是否有回复目标
  bool get hasReplyTarget => replyTarget != null;

  /// 是否处于编辑模式
  bool get isEditing => editingMessage != null;

  /// 是否有人正在输入
  bool get hasTypingUsers => typingUsers.isNotEmpty;

  /// 是否有置顶消息
  bool get hasPinnedMessages => pinnedMessages.isNotEmpty;

  /// 检查消息是否正在翻译
  bool isTranslating(String messageId) => translatingMessageIds.contains(messageId);

  /// 获取消息的翻译结果
  String? getTranslation(String messageId) => translatedMessages[messageId];

  /// 获取检测到的源语言
  String? getDetectedLanguage(String messageId) => detectedSourceLanguages[messageId];

  /// 当前置顶消息
  MessageEntity? get currentPinnedMessage =>
      pinnedMessages.isNotEmpty && currentPinnedIndex < pinnedMessages.length
          ? pinnedMessages[currentPinnedIndex]
          : null;

  /// 获取正在输入提示文本
  /// Note: This returns a raw value that UI layer should localize
  String get typingText {
    if (typingUsers.isEmpty) return '';
    if (typingUsers.length == 1) {
      return '${typingUsers.first} is typing...';
    }
    return '${typingUsers.length} people typing...';
  }

  ChatState copyWith({
    String? roomId,
    List<MessageEntity>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    bool? isSending,
    String? error,
    MessageEntity? replyTarget,
    MessageEntity? editingMessage,
    List<String>? typingUsers,
    String? draft,
    List<MessageEntity>? pinnedMessages,
    int? currentPinnedIndex,
    bool? canPinMessages,
    Map<String, String>? translatedMessages,
    Set<String>? translatingMessageIds,
    Map<String, String>? detectedSourceLanguages,
    bool? autoTranslate,
    String? defaultTargetLanguage,
    bool? smartReplyTranslate,
    String? detectedRecipientLanguage,
    Map<String, String>? smartReplyOriginals,
    ContentFilterConfig? contentFilter,
    String? pendingCommand,
    bool? isChannel,
    bool? canSendMessages,
    int? slowModeInterval,
    DateTime? lastMessageSentAt,
    bool clearError = false,
    bool clearReplyTarget = false,
    bool clearEditingMessage = false,
    bool clearPendingCommand = false,
  }) {
    return ChatState(
      roomId: roomId ?? this.roomId,
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
      replyTarget: clearReplyTarget ? null : (replyTarget ?? this.replyTarget),
      editingMessage: clearEditingMessage ? null : (editingMessage ?? this.editingMessage),
      typingUsers: typingUsers ?? this.typingUsers,
      draft: draft ?? this.draft,
      pinnedMessages: pinnedMessages ?? this.pinnedMessages,
      currentPinnedIndex: currentPinnedIndex ?? this.currentPinnedIndex,
      canPinMessages: canPinMessages ?? this.canPinMessages,
      translatedMessages: translatedMessages ?? this.translatedMessages,
      translatingMessageIds: translatingMessageIds ?? this.translatingMessageIds,
      detectedSourceLanguages: detectedSourceLanguages ?? this.detectedSourceLanguages,
      autoTranslate: autoTranslate ?? this.autoTranslate,
      defaultTargetLanguage: defaultTargetLanguage ?? this.defaultTargetLanguage,
      smartReplyTranslate: smartReplyTranslate ?? this.smartReplyTranslate,
      detectedRecipientLanguage: detectedRecipientLanguage ?? this.detectedRecipientLanguage,
      smartReplyOriginals: smartReplyOriginals ?? this.smartReplyOriginals,
      contentFilter: contentFilter ?? this.contentFilter,
      pendingCommand: clearPendingCommand ? null : (pendingCommand ?? this.pendingCommand),
      isChannel: isChannel ?? this.isChannel,
      canSendMessages: canSendMessages ?? this.canSendMessages,
      slowModeInterval: slowModeInterval ?? this.slowModeInterval,
      lastMessageSentAt: lastMessageSentAt ?? this.lastMessageSentAt,
    );
  }

  @override
  List<Object?> get props => [
        roomId,
        messages,
        isLoading,
        isLoadingMore,
        hasMore,
        isSending,
        error,
        replyTarget,
        editingMessage,
        typingUsers,
        draft,
        pinnedMessages,
        currentPinnedIndex,
        canPinMessages,
        translatedMessages,
        translatingMessageIds,
        detectedSourceLanguages,
        autoTranslate,
        defaultTargetLanguage,
        smartReplyTranslate,
        detectedRecipientLanguage,
        smartReplyOriginals,
        contentFilter,
        pendingCommand,
        isChannel,
        canSendMessages,
        slowModeInterval,
        lastMessageSentAt,
      ];
}

