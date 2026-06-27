import 'dart:async';
import 'dart:io';
import 'dart:math' show min;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix/matrix.dart' show SyncStatus, SyncStatusUpdate;
import 'package:mime/mime.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../core/services/speech_to_text_service.dart';
import '../../../core/services/translation_service.dart';
import '../../../core/utils/content_filter_utils.dart';
import '../../../data/datasources/local/preferences_datasource.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/entities/scheduled_message_draft.dart';
import '../../../domain/repositories/group_repository.dart';
import '../../../domain/repositories/message_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';
import '../../../core/utils/debug_log.dart';

part 'chat_bloc_message_handlers.part.dart';
part 'chat_bloc_send_handlers.part.dart';
part 'chat_bloc_action_handlers.part.dart';
part 'chat_bloc_poll_handlers.part.dart';
part 'chat_bloc_feature_handlers.part.dart';
part 'chat_bloc_retry_handlers.part.dart';

/// 聊天BLoC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final IMessageRepository _messageRepository;
  final PreferencesDataSource _secureStorage;
  final IGroupRepository? _groupRepository;
  final ITranslationService? _translationService;
  final MatrixClientManager? _clientManager;

  StreamSubscription<List<MessageEntity>>? _messagesSubscription;
  StreamSubscription<Map<String, dynamic>>? _pollResponsesSubscription;
  String? _currentRoomId;

  // 阅后即焚定时器
  Timer? _destructionTimer;

  // 定时发送检查定时器
  Timer? _scheduledMessageTimer;

  // 输入状态过期刷新定时器
  Timer? _typingUsersTimer;

  // 已本地删除的消息ID集合（防止被消息订阅恢复）
  final Set<String> _locallyDeletedMessageIds = {};

  // ============================================
  // 离线消息自动重试
  // ============================================

  /// 待重试的消息ID及其重试次数
  final Map<String, int> _pendingRetryMessages = {};

  /// 已耗尽自动重试次数的消息ID集合
  ///
  /// 防止 _scanFailedMessages 在 _pendingRetryMessages 移除 key 后
  /// 将同一消息重新以计数 0 加入队列，导致无限死循环。
  final Set<String> _permanentlyFailedMessages = {};

  /// 最大重试次数
  static const int _maxRetryCount = 3;

  /// 基础重试间隔（毫秒）
  static const int _baseRetryDelayMs = 2000;

  /// 同步状态订阅
  StreamSubscription<SyncStatusUpdate>? _syncStatusSubscription;

  /// 重试定时器
  Timer? _retryTimer;

  /// 当前是否处于连接状态
  bool _isConnected = true;

  ChatBloc({
    required IMessageRepository messageRepository,
    required PreferencesDataSource secureStorage,
    IGroupRepository? groupRepository,
    ITranslationService? translationService,
    MatrixClientManager? clientManager,
  }) : _messageRepository = messageRepository,
       _secureStorage = secureStorage,
       _groupRepository = groupRepository,
       _translationService = translationService,
       _clientManager = clientManager,
       super(ChatState.initial()) {
    // 消息加载/订阅/更新
    on<InitializeChat>(_onInitializeChat);
    on<LoadMessages>(onLoadMessages);
    on<LoadMoreMessages>(onLoadMoreMessages);
    on<SubscribeMessages>(onSubscribeMessages);
    on<UnsubscribeMessages>(onUnsubscribeMessages);
    on<MessagesUpdated>(onMessagesUpdated);
    on<TypingUsersUpdated>(onTypingUsersUpdated);
    on<DisposeChat>(onDisposeChat);

    // 消息发送（各类型）
    on<SendTextMessage>(onSendTextMessage);
    on<SendImageMessage>(onSendImageMessage);
    on<SendVoiceMessage>(onSendVoiceMessage);
    on<SendFileMessage>(onSendFileMessage);
    on<SendVideoMessage>(onSendVideoMessage);
    on<SendLocationMessage>(onSendLocationMessage);
    on<SendGifMessage>(onSendGifMessage);
    on<SendStickerMessage>(onSendStickerMessage);
    on<SendCustomMessage>(onSendCustomMessage);
    on<SendContactCardMessage>(onSendContactCardMessage);
    on<SendSystemNotice>(onSendSystemNotice);
    on<SendPokeMessage>(onSendPokeMessage);

    // 消息操作（重发、撤回、删除、回复、编辑、表情）
    on<ResendMessage>(onResendMessage);
    on<RedactMessage>(onRedactMessage);
    on<DeleteMessagesLocally>(onDeleteMessagesLocally);
    on<DeleteFailedMessage>(onDeleteFailedMessage);
    on<ReplyToMessage>(onReplyToMessage);
    on<SetReplyTarget>(onSetReplyTarget);
    on<SetEditTarget>(onSetEditTarget);
    on<AddReaction>(onAddReaction);
    on<MarkMessageAsRead>(onMarkMessageAsRead);
    on<SendTypingNotification>(onSendTypingNotification);
    on<ClearChatHistory>(onClearChatHistory);
    on<ExecuteSlashCommand>(onExecuteSlashCommand);
    on<ClearPendingCommand>(_onClearPendingCommand);
    on<ReportMessage>(onReportMessage);

    // 投票
    on<SendPollMessage>(onSendPollMessage);
    on<VoteOnPoll>(onVoteOnPoll);
    on<PollResponseReceived>(onPollResponseReceived);
    on<EndPoll>(onEndPoll);
    on<PollEnded>(onPollEnded);

    // 阅后即焚
    on<StartMessageDestruction>(onStartMessageDestruction);
    on<DestroyExpiredMessages>(onDestroyExpiredMessages);
    on<UpdateDestructionCountdown>(onUpdateDestructionCountdown);
    on<DestructionTimesLoaded>(_onDestructionTimesLoaded);

    // 定时消息
    on<SendScheduledMessage>(onSendScheduledMessage);
    on<CancelScheduledMessage>(onCancelScheduledMessage);
    on<SendDueScheduledMessages>(onSendDueScheduledMessages);

    // 语音转文字
    on<TranscribeVoiceMessage>(onTranscribeVoiceMessage);
    on<VoiceTranscriptionCompleted>(onVoiceTranscriptionCompleted);

    // 置顶消息
    on<LoadPinnedMessages>(onLoadPinnedMessages);
    on<PinMessage>(onPinMessage);
    on<UnpinMessage>(onUnpinMessage);
    on<NavigatePinnedMessage>(onNavigatePinnedMessage);

    // 消息翻译
    on<TranslateMessage>(onTranslateMessage);
    on<TranslationCompleted>(onTranslationCompleted);
    on<ClearTranslation>(onClearTranslation);
    on<UpdateTranslationSettings>(onUpdateTranslationSettings);
    on<TranslationSettingsLoaded>(_onTranslationSettingsLoaded);

    // 离线重试
    on<RetryPendingMessages>(onRetryPendingMessages);
    on<ConnectionStatusChanged>(onConnectionStatusChanged);

    // 房间信息（频道/权限）
    on<RoomInfoLoaded>(_onRoomInfoLoaded);
    on<ContentFilterLoaded>(_onContentFilterLoaded);
    on<ScheduledMessagesPreviewLoaded>(_onScheduledMessagesPreviewLoaded);
    on<RecipientLanguageDetected>(_onRecipientLanguageDetected);
  }

  Future<int?> _resolveSelfDestructAfter(int? explicitValue) async {
    if (explicitValue != null) {
      return explicitValue > 0 ? explicitValue : null;
    }

    final defaultSeconds = await _secureStorage.getDefaultSelfDestructSeconds();
    if (defaultSeconds == null || defaultSeconds <= 0) {
      return null;
    }
    return defaultSeconds;
  }

  /// 处理销毁时间加载完成事件
  Future<void> _onDestructionTimesLoaded(
    DestructionTimesLoaded event,
    Emitter<ChatState> emit,
  ) async {
    final updatedMessages = state.messages.map((msg) {
      final destroyedAt = event.destructionTimes[msg.id];
      if (destroyedAt != null &&
          msg.isSelfDestructing &&
          !msg.isDestructionStarted) {
        return msg.copyWith(destroyedAt: destroyedAt);
      }
      return msg;
    }).toList();
    emit(state.copyWith(messages: updatedMessages));
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _pollResponsesSubscription?.cancel();
    _destructionTimer?.cancel();
    _scheduledMessageTimer?.cancel();
    _typingUsersTimer?.cancel();
    _syncStatusSubscription?.cancel();
    _retryTimer?.cancel();
    return super.close();
  }

  /// 初始化聊天室
  ///
  /// 采用本地优先策略：先显示缓存数据，后台静默同步
  /// 将首屏时间从 2s 降至约 100ms
  Future<void> _onInitializeChat(
    InitializeChat event,
    Emitter<ChatState> emit,
  ) async {
    _currentRoomId = event.roomId;
    _locallyDeletedMessageIds.clear();

    // 从持久化存储加载已删除的消息ID（异步，不阻塞）
    _loadDeletedMessageIds(event.roomId);

    // 立即显示界面，不等待网络
    emit(
      state.copyWith(roomId: event.roomId, isLoading: false, clearError: true),
    );

    // 先尝试快速加载本地缓存消息
    try {
      final cachedMessages = await _messageRepository.getMessages(
        event.roomId,
        limit: 30, // 首屏只需要 30 条
      );

      if (cachedMessages.isNotEmpty && !isClosed) {
        // 过滤已删除的消息
        final filteredMessages = cachedMessages
            .where((m) => !_locallyDeletedMessageIds.contains(m.id))
            .toList();

        emit(
          state.copyWith(
            messages: filteredMessages,
            isLoading: false,
            hasMore: true,
          ),
        );
        debugLog(
          'ChatBloc: Displayed ${filteredMessages.length} cached messages instantly',
        );
      }
    } catch (e) {
      debugLog('ChatBloc: Failed to load cached messages: $e');
    }

    // 订阅消息更新（后台同步）
    add(const SubscribeMessages());

    // 订阅投票响应事件
    _subscribeToPollResponses(event.roomId);

    // 后台静默加载完整数据（不阻塞 UI）
    _loadFullMessagesInBackground(event.roomId);

    // 启动阅后即焚定时器
    _startDestructionTimer();

    // 启动定时消息检查定时器
    _startScheduledMessageTimer();

    // 加载已保存的销毁时间
    _loadSavedDestructionTimes(event.roomId);

    // 加载定时消息
    _loadScheduledMessages(event.roomId);

    // 加载置顶消息
    add(const LoadPinnedMessages());

    // 启动离线消息自动重试监听
    setupAutoRetry();

    // 加载关键词过滤配置
    _loadContentFilter(event.roomId);

    // 加载翻译设置
    _loadTranslationSettings();

    // 加载房间信息（频道/权限判断）
    _loadRoomInfo(event.roomId);
  }

  void _loadContentFilter(String roomId) {
    Future.microtask(() async {
      try {
        final filter = await _groupRepository?.getContentFilter(roomId);
        if (!isClosed) {
          add(ContentFilterLoaded(filter));
        }
      } catch (e) {
        // content filter 不影响聊天主流程，静默忽略错误
      }
    });
  }

  void _onContentFilterLoaded(
    ContentFilterLoaded event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(contentFilter: event.config));
  }

  void _loadTranslationSettings() {
    Future.microtask(() async {
      try {
        final settings = await _secureStorage.getTranslationSettings();
        if (!isClosed && settings != null) {
          add(
            TranslationSettingsLoaded(
              autoTranslate: settings['autoTranslate'] as bool? ?? false,
              defaultTargetLanguage: normalizeTranslationLanguageCode(
                settings['defaultTargetLanguage'] as String? ??
                    getDeviceLanguageCode(),
              ),
              smartReplyTranslate:
                  settings['smartReplyTranslate'] as bool? ?? false,
            ),
          );
        }
      } catch (e) {
        debugLog('ChatBloc: Failed to load translation settings: $e');
      }
    });
  }

  /// 启动阅后即焚销毁定时器
  void _startDestructionTimer() {
    _destructionTimer?.cancel();
    // 每秒检查一次是否有消息需要销毁
    _destructionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed && _currentRoomId != null) {
        add(const DestroyExpiredMessages());
      }
    });
  }

  /// 加载已保存的销毁时间
  void _loadSavedDestructionTimes(String roomId) {
    Future.microtask(() async {
      try {
        final destructionTimes = await _secureStorage
            .getMessageDestructionTimes(roomId);
        if (destructionTimes.isEmpty || isClosed) return;
        add(DestructionTimesLoaded(destructionTimes));
      } catch (e) {
        debugLog('ChatBloc: Failed to load saved destruction times: $e');
      }
    });
  }

  /// 后台加载完整消息数据
  void _loadFullMessagesInBackground(String roomId) {
    Future.microtask(() async {
      if (isClosed || _currentRoomId != roomId) return;

      try {
        // 延迟加载 reactions 和 polls，避免阻塞首屏
        await Future<void>.delayed(const Duration(milliseconds: 100));

        if (isClosed || _currentRoomId != roomId) return;

        // 触发完整消息加载（包含 reactions 和 polls）
        add(LoadMessages(roomId));
      } catch (e) {
        debugLog('ChatBloc: Background load failed: $e');
      }
    });
  }

  /// 异步加载已删除消息ID
  void _loadDeletedMessageIds(String roomId) {
    Future.microtask(() async {
      try {
        final persistedDeletedIds = await _messageRepository
            .getLocallyDeletedMessageIds(roomId);
        _locallyDeletedMessageIds.addAll(persistedDeletedIds);
        debugLog(
          'ChatBloc: Loaded ${persistedDeletedIds.length} locally deleted message IDs from storage',
        );
      } catch (e) {
        debugLog('ChatBloc: Failed to load locally deleted message IDs: $e');
      }
    });
  }

  /// 订阅投票响应事件
  void _subscribeToPollResponses(String roomId) {
    _pollResponsesSubscription?.cancel();
    final stream = _messageRepository.watchPollResponses(roomId);
    if (stream == null) return;

    _pollResponsesSubscription = stream.listen(
      (response) {
        // 防止在 BLoC 关闭后添加事件
        if (isClosed) return;

        final type = response['type'] as String?;
        final pollEventId = response['pollEventId'] as String?;

        if (pollEventId == null) return;

        if (type == 'vote') {
          final answers =
              (response['answers'] as List<dynamic>?)?.cast<String>() ?? [];
          final senderId = response['senderId'] as String? ?? '';
          final isCurrentUser = response['isCurrentUser'] as bool? ?? false;

          add(
            PollResponseReceived(
              pollEventId: pollEventId,
              selectedOptionIds: answers,
              senderId: senderId,
              isCurrentUser: isCurrentUser,
            ),
          );
        } else if (type == 'end') {
          add(PollEnded(pollEventId: pollEventId));
        }
      },
      onError: (Object error) {
        debugLog('ChatBloc: Poll responses stream error: $error');
      },
    );
  }

  /// 启动定时消息检查定时器
  void _startScheduledMessageTimer() {
    _scheduledMessageTimer?.cancel();
    // 每分钟检查一次是否有到期的定时消息
    _scheduledMessageTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!isClosed) {
        add(const SendDueScheduledMessages());
      }
    });
  }

  /// 加载定时消息
  void _loadScheduledMessages(String roomId) {
    Future.microtask(() async {
      try {
        final scheduledMessages = await _secureStorage.getScheduledMessages(
          roomId,
        );
        if (scheduledMessages.isEmpty || isClosed) return;

        // 获取当前用户ID
        final currentUserId = await _messageRepository.getCurrentUserId() ?? '';

        // 为每个定时消息创建临时消息实体显示在UI中
        final tempMessages = scheduledMessages
            .map(
              (draft) => draft.toPreviewMessage(
                roomId: roomId,
                senderId: currentUserId,
              ),
            )
            .toList(growable: false);

        if (tempMessages.isNotEmpty && !isClosed) {
          add(ScheduledMessagesPreviewLoaded(tempMessages));
        }
      } catch (e) {
        debugLog('ChatBloc: Failed to load scheduled messages: $e');
      }
    });
  }

  void _onScheduledMessagesPreviewLoaded(
    ScheduledMessagesPreviewLoaded event,
    Emitter<ChatState> emit,
  ) {
    final allMessages = [...state.messages, ...event.previewMessages];
    allMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    emit(state.copyWith(messages: allMessages));
  }
}
