import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:saver_gallery/saver_gallery.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/services/in_app_notification_service.dart';
import '../../../core/services/screenshot_protection_service.dart';
import '../../../core/services/self_destruct_service.dart';
import '../../../core/utils/face_blur_util.dart';
import '../../../core/theme/chat_background_presets.dart';
import '../../../data/datasources/local/preferences_datasource.dart';
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../n42_chat.dart';

import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/download_service.dart';
import '../../../core/services/red_packet_service.dart';
import '../../../core/utils/matrix_utils.dart' as mx_utils;
import '../../../core/utils/payment_request_status_utils.dart';
import '../../../domain/entities/red_packet_entity.dart';
import '../media/media_editor_page.dart';
import '../../../core/services/remark_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../domain/entities/contact_entity.dart';
import '../../../domain/entities/conversation_entity.dart';
import '../../../domain/entities/message_entity.dart';
import '../../../domain/entities/mini_app_entity.dart';
import '../../../domain/entities/transfer_entity.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/contact_repository.dart';
import '../../../domain/repositories/group_repository.dart';
import '../../../domain/repositories/message_repository.dart';
import '../../../domain/repositories/transfer_repository.dart';
import '../../blocs/chat/chat_bloc.dart';
import '../../blocs/chat/chat_event.dart';
import '../../blocs/chat/chat_state.dart';
import '../../blocs/message_action/message_action_bloc.dart';
import '../../blocs/message_action/message_action_event.dart' as action_event;
import '../../blocs/contact/contact_bloc.dart';
import '../../blocs/contact/contact_state.dart';
import '../../blocs/search/search_bloc.dart';
import '../../blocs/transfer/transfer_bloc.dart';
import '../../widgets/chat/chat_widgets.dart';
import '../../widgets/chat/gif_picker.dart';
import '../../widgets/chat/sticker_picker.dart';
import '../../widgets/chat/sticker_suggestion_bar.dart';
import '../../widgets/chat/custom_emoji_suggestion_bar.dart';
import '../../widgets/chat/expression_panel.dart';
import '../../../domain/repositories/sticker_repository.dart';
import '../../../domain/entities/custom_emoji.dart';
import '../../../core/utils/sticker_suggestion_utils.dart';
import '../../../core/utils/custom_emoji_parser.dart';
import '../../../core/services/giphy_service.dart';
import '../../../core/services/reminder_service.dart';
import '../../widgets/chat/red_packet_dialogs.dart';
import '../sticker/sticker_store_page.dart';
import '../../widgets/chat/edit_history_sheet.dart';
import '../../widgets/common/wechat_toast.dart';
import '../../../domain/entities/sticker_pack_entity.dart';
import '../../widgets/common/common_widgets.dart';
import '../contact/contact_detail_page.dart';
import '../search/chat_search_bar.dart';
import '../search/chat_search_page.dart';
import 'chat_detail_page.dart';
import '../favorite/favorite_list_page.dart';
import 'message_item.dart';
import 'live_location_page.dart';
import 'thread_detail_page.dart';
import '../../widgets/chat/quick_reply_sheet.dart';
import '../../widgets/chat/scheduled_send_picker.dart';
import '../settings/quick_replies_page.dart';
import '../ai/ai_assistant_page.dart';
import '../../../core/services/ai_service.dart';
import '../../../core/services/translation_service.dart';
import '../../helpers/ai_reply_suggestion_helper.dart';
import '../../helpers/chat_mention_helper.dart';
import '../../helpers/mini_app_launcher_helper.dart';
import '../../widgets/chat/ai_summary_bubble.dart';
import '../../../domain/repositories/ai_repository.dart';
import '../../widgets/chat/ai_rewrite_bar.dart';
import '../../widgets/chat/ai_smart_reply_bar.dart';
import '../../widgets/chat/translated_message.dart';
import 'viewers/image_viewer_page.dart';
import 'viewers/pdf_viewer_page.dart';
import 'viewers/text_document_preview_page.dart';
import 'location_picker_page.dart';
import 'viewers/video_player_page.dart';
import '../../widgets/chat/chat_confirm_sheets.dart';
import '../../widgets/chat/contact_card_select_sheet.dart';
import '../../widgets/chat/contact_select_dialog.dart';
import '../../widgets/chat/forward_message_sheet.dart';
import '../../widgets/chat/member_picker_sheet.dart';
import '../../widgets/chat/multi_forward_sheet.dart';
import '../../widgets/chat/music_select_sheet.dart';
import '../../widgets/chat/poll_create_sheet.dart';
import '../mini_app/mini_app_market_page.dart';
import '../../../core/services/bot_command_processor.dart';
import '../../../core/utils/bridge_detection_utils.dart';
import '../../../domain/entities/bot_command_entity.dart';
import '../../../integration/bridge/bridge_platform.dart';
import '../../../integration/wallet_bridge.dart';
import '../group/group_topics_page.dart';
import '../group/bot_settings_page.dart';
import '../transfer/receive_page.dart';
import '../transfer/transfer_page.dart';
import '../../../core/utils/debug_log.dart';

part 'chat_page_app_bar.dart';
part 'chat_page_message_list.dart';
part 'chat_page_input.dart';
part 'chat_page_media_actions.dart';
part 'chat_page_message_actions.dart';
part 'chat_page_message_menu.dart';
part 'chat_page_more_features.dart';
part 'chat_page_ai_features.dart';
part 'chat_page_event_handlers.dart';

/// 聊天页面
class ChatPage extends StatefulWidget {
  /// 会话实体
  final ConversationEntity conversation;

  /// 进入会话后需要定位的目标消息 ID
  final String? initialTargetMessageId;

  /// 返回回调
  final VoidCallback? onBack;

  /// 更多按钮点击回调
  final VoidCallback? onMorePressed;

  const ChatPage({
    super.key,
    required this.conversation,
    this.initialTargetMessageId,
    this.onBack,
    this.onMorePressed,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  bool _showScrollToBottom = false;
  bool _showSearchBar = false;
  bool _showMorePanel = false;
  bool _showEmojiPicker = false;
  bool _showStickerPicker = false;
  // 统一表情面板初始分页（emoji 按钮→emoji；"+"菜单贴纸/GIF→对应分页）
  ExpressionTab _expressionInitialTab = ExpressionTab.emoji;
  String? _highlightedMessageId;

  // 录音状态
  bool _isRecording = false;
  bool _isRecordingCancelled = false;
  Duration _recordingDuration = Duration.zero;

  // 消息 GlobalKey 映射，用于获取消息气泡位置
  final Map<String, GlobalKey> _messageKeys = {};

  // ChatInputBar 的 GlobalKey，用于调用取消录音方法
  final GlobalKey<ChatInputBarState> _inputBarKey =
      GlobalKey<ChatInputBarState>();

  // 撤回的消息ID，用于显示"重新编辑"
  final Set<String> _recalledMessageIds = {};
  String? _lastRecalledContent;

  // 多选模式
  bool _isMultiSelectMode = false;
  final Set<String> _selectedMessageIds = {};

  // 收藏的消息（本地存储）
  final Set<String> _favoritedMessageIds = {};

  // 当前用户ID（用于表情回应高亮）
  String? _currentUserId;

  // 贴纸输入联想（按词推荐贴纸）
  List<StickerHit> _stickerSuggestions = const [];
  int _stickerSuggestionToken = 0;

  // 自定义 emoji 输入联想（输入 `:partial` 推荐动画 emoji）
  List<CustomEmoji> _customEmojiSuggestions = const [];

  // @ 提醒相关状态
  bool _showMentionPicker = false;
  int _mentionTriggerPosition = -1; // @ 符号的位置
  String _mentionSearchQuery = ''; // @ 后面输入的搜索关键词
  List<ChatMentionSelection> _composerMentions = const [];
  Future<List<ChatMentionMember>>? _groupMembersFuture;
  List<ChatMentionMember> _groupMembers = const [];

  // View Once 模式（阅后即焚媒体）
  bool _isViewOnce = false;

  // 文字消息阅后即焚定时器（秒，null 表示关闭）
  int? _selfDestructAfter;

  // 自动人脸模糊设置
  bool _autoFaceBlur = false;

  // 备注更新订阅
  StreamSubscription<RemarkUpdateEvent>? _remarkSubscription;

  // 私聊对方的用户ID（用于获取备注名）
  String? _otherUserId;

  // 投票防抖 - 正在投票的pollId集合
  final Set<String> _votingPollIds = {};

  // AI 改写状态
  bool _showRewriteBar = false;
  String _rewriteOriginalText = '';
  String? _rewriteResult;
  bool _isRewriting = false;
  AiTone? _selectedTone;

  // AI 群聊消息摘要状态
  String? _aiSummaryResult;
  bool _isAiSummarizing = false;
  List<String> _smartReplySuggestions = const [];
  bool _isLoadingSmartReplySuggestions = false;
  String? _smartReplyAnchorMessageId;
  String? _dismissedSmartReplyAnchorMessageId;

  // 聊天背景 key（如 solid_0, gradient_1, default 等）
  String? _backgroundKey;

  // 消息字体大小
  double _messageFontSize = 16.0;
  bool _showLinkPreviews = true;
  bool _sessionPrivacyShieldEnabled = false;
  int _privacyPreferencesLoadVersion = 0;
  String? _pendingInitialTargetMessageId;

  @override
  void initState() {
    super.initState();

    // 设置当前活跃房间（避免弹出通知）
    N42Chat.pushService?.setActiveRoom(widget.conversation.id);

    // 清除该房间的通知
    N42Chat.clearNotificationsForRoom(widget.conversation.id);

    // 初始化聊天室
    context.read<ChatBloc>().add(InitializeChat(widget.conversation.id));
    _pendingInitialTargetMessageId = widget.initialTargetMessageId;

    if (widget.conversation.isGroup) {
      _groupMembersFuture = _loadGroupMembers();
    }

    // 获取当前用户ID
    _loadCurrentUserId();

    // 加载人脸模糊设置
    _loadFaceBlurSetting();

    // 获取私聊对方的用户ID
    _loadOtherUserId();

    // 监听滚动
    _scrollController.addListener(_onScroll);

    // 监听输入框焦点，获取焦点时隐藏更多面板
    _inputFocusNode.addListener(_onInputFocusChanged);

    // 监听备注更新
    _remarkSubscription = RemarkService.instance.onRemarkUpdated.listen((
      event,
    ) {
      // 如果是当前会话的联系人备注更新，刷新界面
      final targetUserId = _otherUserId ?? widget.conversation.id;
      if (event.userId == targetUserId && mounted) {
        debugLog('ChatPage: Remark updated for $targetUserId, refreshing UI');
        setState(() {});
      }
    });

    // 加载聊天背景
    _loadBackground();

    // 加载字体大小
    _loadFontSize();

    // 加载草稿
    _loadDraft();

    // 加载隐私相关配置（链接预览、私密聊天截图防护）
    unawaited(_loadPrivacyPreferences());

    // 如果是从搜索/通知进入，初始化后尝试跳转到目标消息
    unawaited(_jumpToInitialTargetMessage());

    // 设置当前聊天房间（应用内通知过滤）
    InAppNotificationService.instance.setCurrentChatRoom(
      widget.conversation.id,
    );

    // 设置通话错误回调
    N42Chat.callManager?.onError = _handleCallError;
  }

  /// 处理通话错误
  void _handleCallError(String errorCode) {
    if (!mounted) return;

    final l10n = S.of(context);
    String message;

    switch (errorCode) {
      case 'call_not_initialized':
        message =
            l10n?.chatCallServiceNotInitialized ??
            'Call service not initialized';
        break;
      case 'already_in_call':
        message = l10n?.chatAlreadyInCall ?? 'Already in a call';
        break;
      case 'call_failed':
        message = l10n?.commonConnectionFailed ?? 'Call failed';
        break;
      case 'answer_failed':
        message = l10n?.commonConnectionFailed ?? 'Failed to answer';
        break;
      case 'connection_failed':
        message = l10n?.commonConnectionFailed ?? 'Connection failed';
        break;
      case 'meeting_not_initialized':
        message =
            l10n?.chatCallServiceNotInitialized ??
            'Call service not initialized';
        break;
      case 'livekit_not_configured':
        message =
            l10n?.callLivekitNotConfigured ??
            'Group call service not configured';
        break;
      case 'livekit_token_fetch_failed':
        message =
            l10n?.callJoinMeetingFailed('token') ??
            'Failed to prepare group call';
        break;
      case 'call_rejected':
        message = l10n?.chatCallRejected ?? 'Call rejected';
        break;
      case 'no_answer':
        message = l10n?.chatNoAnswer ?? 'No answer';
        break;
      default:
        message = errorCode;
    }

    WeChatToast.show(context, message, type: ToastType.warning);
  }

  /// 获取私聊对方的用户ID
  void _loadOtherUserId() {
    if (widget.conversation.type == ConversationType.group) {
      return;
    }

    // 直接使用 conversation.directUserId
    _otherUserId = widget.conversation.directUserId;
    debugLog(
      'ChatPage: directUserId=$_otherUserId for room ${widget.conversation.id}',
    );
  }

  void _onInputFocusChanged() {
    if (_inputFocusNode.hasFocus) {
      setState(() {
        _showMorePanel = false;
        _showEmojiPicker = false;
      });
    }
  }

  /// 加载当前用户ID
  void _loadCurrentUserId() {
    try {
      final authRepository = getIt<IAuthRepository>();
      _currentUserId = authRepository.currentUser?.userId;
      debugLog('ChatPage: Loaded current user ID: $_currentUserId');
    } catch (e) {
      debugLog('ChatPage: Failed to load current user ID: $e');
    }
  }

  /// 加载人脸模糊设置
  Future<void> _loadFaceBlurSetting() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('auto_face_blur') ?? false;
      if (mounted && enabled != _autoFaceBlur) {
        setState(() {
          _autoFaceBlur = enabled;
        });
      }
    } catch (e) {
      debugLog('ChatPage: Failed to load face blur setting: $e');
    }
  }

  /// 加载聊天背景设置
  Future<void> _loadBackground() async {
    final storage = getIt<PreferencesDataSource>();
    // 先尝试获取房间特定背景
    var bg = await storage.getChatBackground(widget.conversation.id);
    // 如果没有，尝试默认背景
    bg ??= await storage.getDefaultChatBackground();
    if (mounted && bg != null) {
      setState(() => _backgroundKey = bg);
    }
  }

  /// 加载消息字体大小
  Future<void> _loadFontSize() async {
    final storage = getIt<PreferencesDataSource>();
    final size = await storage.getMessageFontSize();
    if (mounted) {
      setState(() => _messageFontSize = size);
    }
  }

  /// 加载草稿
  Future<void> _loadDraft() async {
    final storage = getIt<PreferencesDataSource>();
    final draft = await storage.getDraft(widget.conversation.id);
    if (mounted && draft != null && draft.isNotEmpty) {
      _inputController.text = draft;
      _inputController.selection = TextSelection.fromPosition(
        TextPosition(offset: draft.length),
      );
    }
  }

  Future<void> _loadPrivacyPreferences() async {
    final loadVersion = ++_privacyPreferencesLoadVersion;
    try {
      final storage = getIt<PreferencesDataSource>();
      final privacySettings = await storage.getPrivacySettingsModel();
      if (!mounted || loadVersion != _privacyPreferencesLoadVersion) {
        return;
      }
      if (_showLinkPreviews != privacySettings.showLinkPreviews) {
        setState(() => _showLinkPreviews = privacySettings.showLinkPreviews);
      }

      final shouldProtect =
          privacySettings.privateChatMode &&
          (widget.conversation.type == ConversationType.direct ||
              widget.conversation.isEncrypted);
      if (!shouldProtect) {
        return;
      }

      await ScreenshotProtectionService.instance.initialize();
      if (!mounted || loadVersion != _privacyPreferencesLoadVersion) {
        return;
      }
      await ScreenshotProtectionService.instance.enableForSession();
      if (!mounted || loadVersion != _privacyPreferencesLoadVersion) {
        await ScreenshotProtectionService.instance.restoreDefault();
        return;
      }
      _sessionPrivacyShieldEnabled = true;
    } catch (e) {
      debugLog('ChatPage: Failed to apply privacy session protection: $e');
    }
  }

  /// 保存草稿
  void _saveDraft() {
    final storage = getIt<PreferencesDataSource>();
    storage.saveDraft(widget.conversation.id, _inputController.text);
  }

  /// 构建聊天背景装饰
  BoxDecoration? _buildBackgroundDecoration() {
    return ChatBackgroundPresets.resolveDecoration(_backgroundKey);
  }

  /// 切换人脸模糊设置
  Future<void> _toggleFaceBlur() async {
    final newValue = !_autoFaceBlur;
    setState(() {
      _autoFaceBlur = newValue;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_face_blur', newValue);
    } catch (e) {
      debugLog('ChatPage: Failed to save face blur setting: $e');
    }
  }

  @override
  void dispose() {
    _privacyPreferencesLoadVersion++;

    // 清除当前活跃房间
    N42Chat.pushService?.setActiveRoom(null);

    // 清除当前聊天房间（应用内通知过滤）
    InAppNotificationService.instance.setCurrentChatRoom(null);

    // 清除通话错误回调
    if (N42Chat.callManager?.onError == _handleCallError) {
      N42Chat.callManager?.onError = null;
    }

    // 取消备注更新订阅
    _remarkSubscription?.cancel();

    // 先清理聊天室（在 super.dispose 之前）
    try {
      context.read<ChatBloc>().add(const DisposeChat());
    } catch (e) {
      debugLog('ChatPage: Error disposing ChatBloc: $e');
    }

    // 保存草稿
    _saveDraft();

    // 移除监听器（必须在 dispose 之前）
    _scrollController.removeListener(_onScroll);
    _inputFocusNode.removeListener(_onInputFocusChanged);

    // 释放人脸检测器资源
    FaceBlurUtil.dispose();

    // 释放资源
    if (_sessionPrivacyShieldEnabled) {
      unawaited(ScreenshotProtectionService.instance.restoreDefault());
    }
    _scrollController.dispose();
    _inputController.dispose();
    _inputFocusNode.dispose();

    super.dispose();
  }

  void _onScroll() {
    // 检查是否需要加载更多
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ChatBloc>().add(const LoadMoreMessages());
    }

    // 显示/隐藏回到底部按钮
    final shouldShow = _scrollController.position.pixels > 500;
    if (_showScrollToBottom != shouldShow) {
      setState(() {
        _showScrollToBottom = shouldShow;
      });
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final mentionPayload = ChatMentionHelper.buildPayload(
      text: text,
      selections: _composerMentions,
      members: _groupMembers,
    );

    if (_smartReplySuggestions.isNotEmpty || _isLoadingSmartReplySuggestions) {
      _dismissAiSmartReplyBar();
    }

    // 斜杠命令拦截（编辑模式下不拦截）
    final chatBloc = context.read<ChatBloc>();
    final editingMsg = chatBloc.state.editingMessage;

    if (editingMsg == null &&
        text.startsWith('/') &&
        !text.startsWith('/ ') &&
        text.length > 1) {
      _inputController.clear();
      _clearComposerMentions();
      _processBotCommand(text);
      return;
    }

    if (editingMsg != null) {
      final actionBloc = getIt<MessageActionBloc>();
      actionBloc.add(
        action_event.EditMessage(widget.conversation.id, editingMsg.id, text),
      );
      chatBloc.add(const SetEditTarget(null));
    } else {
      chatBloc.add(
        SendTextMessage(
          text,
          selfDestructAfter: _selfDestructAfter,
          mentionedUserIds: mentionPayload.mentionedUserIds,
          mentionsRoom: mentionPayload.mentionsRoom,
        ),
      );
    }
    _inputController.clear();
    _clearComposerMentions();
  }

  /// 处理 Bot 斜杠命令
  Future<void> _processBotCommand(String text) async {
    final config = N42Chat.config;
    final processor = BotCommandProcessor(
      walletBridge: getIt<IWalletBridge>(),
      priceApiBase: config?.marketBaseUrl ?? 'https://api.coingecko.com/api/v3',
      authToken: config?.proxyAuthToken,
      useProxyEndpoint: config?.marketUseProxyEndpoint ?? false,
    );
    final result = await processor.processRaw(text);

    if (!mounted) return;

    switch (result.type) {
      case BotCommandResultType.showPanel:
        _showBotResultPanel(result.panelTitle!, result.panelContent!);
      case BotCommandResultType.sendMessage:
        context.read<ChatBloc>().add(SendTextMessage(result.messageText!));
      case BotCommandResultType.error:
        _showBotResultPanel(
          '⚠️ Command Error',
          result.errorMessage ?? 'Unknown error',
        );
      case BotCommandResultType.unknown:
        _showBotResultPanel(
          '❓ Unknown Command',
          'Type /help to see available commands.',
        );
      case BotCommandResultType.dismiss:
        break;
    }
  }

  /// 展示 Bot 命令结果底部面板
  void _showBotResultPanel(String title, String content) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BotResultSheet(title: title, content: content),
    );
  }

  void _onInputChanged(String text) {
    // 发送正在输入状态
    context.read<ChatBloc>().add(SendTypingNotification(text.isNotEmpty));

    if (text.trim().isNotEmpty) {
      if (_smartReplySuggestions.isNotEmpty ||
          _isLoadingSmartReplySuggestions) {
        setState(() {
          _resetAiSmartReplyState();
        });
      }
    } else {
      _handleSmartReplyStateChanged(context.read<ChatBloc>().state);
    }

    // 检测 @ 提醒（仅群聊）
    if (widget.conversation.isGroup) {
      final prunedMentions = ChatMentionHelper.pruneSelections(
        text,
        _composerMentions,
      );
      if (!listEquals(prunedMentions, _composerMentions)) {
        setState(() {
          _composerMentions = prunedMentions;
        });
      }
      _checkMentionTrigger(text);
    }

    // 输入联想：自定义 emoji（`:partial`）优先于贴纸（按词）
    _updateComposerSuggestions(text);
  }

  /// 更新输入联想：`:partial` 命中时推荐自定义 emoji，否则按词推荐贴纸
  void _updateComposerSuggestions(String text) {
    final cursor = _inputController.selection.baseOffset;
    final emojiTrigger = CustomEmojiParser.extractTrigger(text, cursor);
    if (emojiTrigger != null) {
      // `:` 后至少 1 个字符才推荐，避免单个冒号刷屏
      final hits = emojiTrigger.isEmpty
          ? const <CustomEmoji>[]
          : BuiltinCustomEmojis.search(emojiTrigger, limit: 12);
      if (!listEquals(hits, _customEmojiSuggestions) ||
          _stickerSuggestions.isNotEmpty) {
        setState(() {
          _customEmojiSuggestions = hits;
          _stickerSuggestions = const [];
        });
      }
      return;
    }
    if (_customEmojiSuggestions.isNotEmpty) {
      setState(() => _customEmojiSuggestions = const []);
    }
    _updateStickerSuggestions(text);
  }

  /// 选中联想的自定义 emoji：把 `:partial` 替换为完整 `:shortcode:`
  void _onCustomEmojiSuggestionSelected(CustomEmoji emoji) {
    final text = _inputController.text;
    final cursor = _inputController.selection.baseOffset;
    final offset = (cursor < 0 || cursor > text.length) ? text.length : cursor;
    final before = text.substring(0, offset);
    final triggerStart = before.lastIndexOf(':');
    if (triggerStart < 0) return;

    final insertion = ':${emoji.shortcode}: ';
    final newText = text.replaceRange(triggerStart, offset, insertion);
    _inputController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: triggerStart + insertion.length,
      ),
    );
    setState(() => _customEmojiSuggestions = const []);
    _inputFocusNode.requestFocus();
  }

  /// 按当前输入词更新贴纸联想候选
  void _updateStickerSuggestions(String text) {
    if (!getIt.isRegistered<IStickerRepository>()) return;

    final query = StickerSuggestionUtils.extractQuery(
      text,
      _inputController.selection.baseOffset,
    );
    if (query == null) {
      if (_stickerSuggestions.isNotEmpty) {
        _stickerSuggestionToken++;
        setState(() => _stickerSuggestions = const []);
      }
      return;
    }

    final token = ++_stickerSuggestionToken;
    unawaited(() async {
      try {
        final hits = await getIt<IStickerRepository>().searchStickers(
          query,
          limit: 12,
        );
        if (!mounted || token != _stickerSuggestionToken) return;
        setState(() => _stickerSuggestions = hits);
      } catch (_) {
        if (!mounted || token != _stickerSuggestionToken) return;
        setState(() => _stickerSuggestions = const []);
      }
    }());
  }

  /// 选中联想贴纸：发送并清空候选
  void _onStickerSuggestionSelected(Sticker sticker, String packId) {
    _stickerSuggestionToken++;
    setState(() => _stickerSuggestions = const []);
    _onStickerSelected(sticker, packId);
  }

  /// 检测 @ 触发
  void _checkMentionTrigger(String text) {
    final cursorPos = _inputController.selection.baseOffset;
    final trigger = ChatMentionHelper.findTrigger(
      text: text,
      cursorOffset: cursorPos,
    );
    if (trigger == null) {
      _hideMentionPicker();
      return;
    }

    setState(() {
      _showMentionPicker = true;
      _mentionTriggerPosition = trigger.triggerPosition;
      _mentionSearchQuery = trigger.query;
    });
  }

  /// 隐藏 @ 选择器
  void _hideMentionPicker() {
    if (_showMentionPicker) {
      setState(() {
        _showMentionPicker = false;
        _mentionTriggerPosition = -1;
        _mentionSearchQuery = '';
      });
    }
  }

  void _clearComposerMentions() {
    if (_composerMentions.isEmpty && !_showMentionPicker) {
      return;
    }
    setState(() {
      _composerMentions = const [];
      _showMentionPicker = false;
      _mentionTriggerPosition = -1;
      _mentionSearchQuery = '';
    });
  }

  /// 选择要 @ 的成员
  void _onMentionSuggestionSelected(ChatMentionSuggestion suggestion) {
    if (_mentionTriggerPosition < 0) return;

    final text = _inputController.text;
    final cursorPos = _inputController.selection.baseOffset;
    final insertion = ChatMentionHelper.applySuggestion(
      text: text,
      triggerPosition: _mentionTriggerPosition,
      cursorOffset: cursorPos,
      suggestion: suggestion,
    );

    _inputController.text = insertion.text;
    _inputController.selection = TextSelection.fromPosition(
      TextPosition(offset: insertion.cursorOffset),
    );

    setState(() {
      _composerMentions = ChatMentionHelper.mergeSelection(
        selections: _composerMentions,
        selection: insertion.selection,
      );
      _showMentionPicker = false;
      _mentionTriggerPosition = -1;
      _mentionSearchQuery = '';
    });
    _inputFocusNode.requestFocus();
  }

  void _toggleSearch() {
    final shouldShowSearchBar = !_showSearchBar;
    setState(() {
      _showSearchBar = shouldShowSearchBar;
      if (_showSearchBar) {
        _resetAiSmartReplyState();
      } else {
        _highlightedMessageId = null;
      }
    });
    if (!shouldShowSearchBar && _inputController.text.trim().isEmpty) {
      _handleSmartReplyStateChanged(context.read<ChatBloc>().state);
    }
  }

  void _navigateToMessage(String eventId) {
    unawaited(_scrollToMessage(eventId));
  }

  Future<void> _jumpToInitialTargetMessage() async {
    final targetMessageId = _pendingInitialTargetMessageId;
    if (targetMessageId == null || targetMessageId.isEmpty) {
      return;
    }

    final chatBloc = context.read<ChatBloc>();
    if (chatBloc.state.roomId != widget.conversation.id) {
      await chatBloc.stream.firstWhere(
        (state) => state.roomId == widget.conversation.id,
      );
      if (!mounted) {
        return;
      }
    }

    _pendingInitialTargetMessageId = null;
    await _scrollToMessage(targetMessageId);
  }

  Future<bool> _ensureMessageLoaded(String eventId) async {
    final chatBloc = context.read<ChatBloc>();
    var currentState = chatBloc.state;
    if (currentState.messages.any((message) => message.id == eventId)) {
      return true;
    }

    var attempts = 0;
    var lastMessageCount = currentState.messages.length;

    while (mounted && currentState.hasMore && attempts < 8) {
      attempts++;

      if (!currentState.isLoadingMore) {
        chatBloc.add(const LoadMoreMessages());
      }

      currentState = await chatBloc.stream.firstWhere(
        (state) => !state.isLoadingMore,
      );
      if (!mounted) {
        return false;
      }

      if (currentState.messages.any((message) => message.id == eventId)) {
        return true;
      }

      if (currentState.messages.length <= lastMessageCount) {
        break;
      }
      lastMessageCount = currentState.messages.length;
    }

    return false;
  }

  /// 滚动到指定消息并高亮显示
  Future<void> _scrollToMessage(String eventId) async {
    final isLoaded = await _ensureMessageLoaded(eventId);
    if (!mounted || !isLoaded) {
      return;
    }

    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) {
      return;
    }

    // 先检查消息是否在当前视图中
    final messageKey = _messageKeys[eventId];
    if (messageKey?.currentContext != null) {
      // 消息已加载，使用 Scrollable.ensureVisible 精确滚动
      await Scrollable.ensureVisible(
        messageKey!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        alignment: 0.5, // 滚动到屏幕中间
      );
      _highlightMessage(eventId);
    } else {
      // 消息可能还没加载，尝试使用索引估算滚动
      final chatBloc = context.read<ChatBloc>();
      final state = chatBloc.state;
      final index = state.messages.indexWhere((m) => m.id == eventId);

      if (index != -1) {
        // 使用估算位置滚动
        unawaited(
          _scrollController.animateTo(
            index * 80.0, // 估算每条消息高度
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          ),
        );
        // 滚动后延迟设置高亮
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) {
            _highlightMessage(eventId);
          }
        });
      }
    }
  }

  /// 高亮显示指定消息（2秒后自动取消）
  void _highlightMessage(String eventId) {
    setState(() {
      _highlightedMessageId = eventId;
    });
    // 2秒后自动取消高亮
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _highlightedMessageId == eventId) {
        setState(() {
          _highlightedMessageId = null;
        });
      }
    });
  }

  bool _shouldShowTimeSeparator(
    MessageEntity current,
    MessageEntity? previous,
  ) {
    if (previous == null) return true;

    final diff = current.timestamp.difference(previous.timestamp).abs();
    return diff.inMinutes >= 5;
  }

  /// 将 mxc:// URL 转换为 HTTP URL
  String? _convertMxcToHttpUrl(String? mxcUrl) {
    return mx_utils.MatrixUtils.getMediaDownloadUrl(
      mxcUrl,
      client: MatrixClientManager.instance.client,
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    if (now.difference(time).inMinutes < 1) {
      return S.of(context)?.chatJustNow ?? 'Just now';
    } else if (now.day == time.day) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 获取显示名称，私聊优先使用备注名
  String _getDisplayName() {
    // 群聊直接返回群名称
    if (widget.conversation.type == ConversationType.group) {
      final name = widget.conversation.name;
      // 如果群名为空或为默认值，显示成员数
      if (name.isEmpty || name == 'Empty Chat' || name == 'empty chat') {
        return S
                .of(context)
                ?.chatGroupChatCount(widget.conversation.memberCount) ??
            'Group Chat(${widget.conversation.memberCount})';
      }
      return name;
    }

    // 私聊：直接使用 conversation.directUserId 获取备注名
    final otherUserId = widget.conversation.directUserId;
    if (otherUserId != null) {
      return RemarkService.instance.getDisplayName(
        otherUserId,
        widget.conversation.name,
      );
    }

    // 如果名称为空或为默认值，返回简化的用户ID或默认文本
    final name = widget.conversation.name;
    if (name.isEmpty || name == 'Empty Chat' || name == 'empty chat') {
      return S.of(context)?.chatPrivateChat ?? 'Private Chat';
    }
    return name;
  }

  /// 检查位置权限
  Future<bool> _checkLocationPermission() async {
    try {
      // 检查位置服务是否启用
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          final shouldOpen = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(
                S.of(context)?.chatLocationServiceNotEnabled ??
                    'Location service is not enabled',
              ),
              content: Text(
                S.of(context)?.chatEnableLocationService ??
                    'Please enable location service to use this feature',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    S.of(context)?.chatGoToSettings ?? 'Go to Settings',
                  ),
                ),
              ],
            ),
          );
          if (shouldOpen == true) {
            await Geolocator.openLocationSettings();
          }
        }
        return false;
      }

      // 检查权限
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  S.of(context)?.chatLocationPermissionRequired ??
                      'Location permission is required for this feature',
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context)?.chatLocationPermissionDeniedPermanent ??
                    'Location permission has been permanently denied. Please enable it in settings.',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return false;
      }

      return true;
    } catch (e) {
      debugLog('Check location permission error: $e');
      return false;
    }
  }

  /// 加载群成员
  Future<List<ChatMentionMember>> _loadGroupMembers() async {
    try {
      final groupRepository = getIt<IGroupRepository>();
      final members = await groupRepository.getGroupMembers(
        widget.conversation.id,
      );

      final mappedMembers = members
          .map(
            (m) => ChatMentionMember(
              id: m.userId,
              name: m.displayName.isNotEmpty ? m.displayName : m.userId,
              avatarUrl: m.avatarUrl ?? '',
            ),
          )
          .toList();
      _groupMembers = mappedMembers;
      return mappedMembers;
    } catch (e) {
      debugLog('Error loading group members: $e');
      return [];
    }
  }

  /// 处理 BLoC 发出的 pendingCommand 信号
  void _handlePendingCommand(String command) {
    switch (command) {
      case 'poll':
        _createPoll();
        break;
      case 'welcome':
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BotSettingsPage(roomId: widget.conversation.id),
          ),
        );
        break;
      default:
        debugLog('ChatPage: Unknown pending command: $command');
    }
  }

  Widget _buildScrollToBottomButton() {
    return FloatingActionButton.small(
      onPressed: _scrollToBottom,
      backgroundColor: AppColors.surface,
      child: const Icon(
        Icons.keyboard_arrow_down,
        color: AppColors.textSecondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 检查 ContactBloc 是否可用
    bool hasContactBloc = false;
    try {
      context.read<ContactBloc>();
      hasContactBloc = true;
    } catch (e) {
      // ContactBloc 不可用
      debugLog('Error: $e');
    }

    final Widget content = Stack(
      children: [
        Scaffold(
          backgroundColor: context.pageBackground,
          appBar: _buildAppBar(),
          body: Column(
            children: [
              // 聊天内搜索栏
              if (_showSearchBar)
                BlocProvider(
                  create: (_) => getIt<SearchBloc>(),
                  child: ChatSearchBar(
                    roomId: widget.conversation.id,
                    onClose: _toggleSearch,
                    onNavigateToMessage: _navigateToMessage,
                  ),
                ),

              // 置顶消息横幅
              _buildPinnedMessageBanner(),

              // 消息列表
              Expanded(
                child: Container(
                  decoration: _buildBackgroundDecoration(),
                  child: Stack(
                    children: [
                      _buildMessageList(),

                      // 回到底部按钮
                      if (_showScrollToBottom)
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: _buildScrollToBottomButton(),
                        ),
                    ],
                  ),
                ),
              ),

              // 回复预览
              if (!_isMultiSelectMode) _buildReplyPreview(),

              // 编辑预览
              if (!_isMultiSelectMode) _buildEditPreview(),

              // @ 提醒成员选择器（群聊时）
              if (_showMentionPicker && !_isMultiSelectMode)
                _buildMentionPicker(),

              // AI 改写栏
              if (_showRewriteBar && !_isMultiSelectMode) _buildAiRewriteBar(),

              if (!_showSearchBar &&
                  !_isMultiSelectMode &&
                  !_showRewriteBar &&
                  (_smartReplySuggestions.isNotEmpty ||
                      _isLoadingSmartReplySuggestions))
                _buildAiSmartReplyBar(),

              // View Once 提示条
              if (_isViewOnce && !_isMultiSelectMode && !_showSearchBar)
                _buildViewOnceIndicator(),

              // 阅后即焚定时器提示条
              if (_selfDestructAfter != null &&
                  !_isMultiSelectMode &&
                  !_showSearchBar)
                _buildSelfDestructTimerBar(),

              // 自定义 emoji 联想条（输入 `:partial`）
              if (_customEmojiSuggestions.isNotEmpty &&
                  !_isMultiSelectMode &&
                  !_showSearchBar &&
                  !_showMentionPicker)
                CustomEmojiSuggestionBar(
                  suggestions: _customEmojiSuggestions,
                  onSelected: _onCustomEmojiSuggestionSelected,
                ),

              // 贴纸输入联想条（按词推荐贴纸）
              if (_stickerSuggestions.isNotEmpty &&
                  !_isMultiSelectMode &&
                  !_showSearchBar &&
                  !_showMentionPicker)
                StickerSuggestionBar(
                  suggestions: _stickerSuggestions,
                  onSelected: _onStickerSuggestionSelected,
                ),

              // 多选模式下显示操作栏，否则显示输入栏
              if (_isMultiSelectMode)
                _buildMultiSelectBottomBar()
              else if (!_showSearchBar)
                _buildInputBar(),

              // 表情选择器
              if (_showEmojiPicker && !_isMultiSelectMode) _buildEmojiPicker(),

              // 贴纸选择器
              if (_showStickerPicker && !_isMultiSelectMode)
                _buildStickerPicker(),

              // 更多功能面板（仅在非多选模式下）
              if (_showMorePanel && !_isMultiSelectMode) _buildMorePanel(),
            ],
          ),
        ),

        // 全屏录音浮层
        if (_isRecording) _buildRecordingOverlay(),
      ],
    );

    // 使用 MultiBlocListener 包装：1) pendingCommand 信号 2) ContactBloc 备注更新
    final List<BlocListener<dynamic, dynamic>> listeners = [
      BlocListener<ChatBloc, ChatState>(
        listenWhen: (prev, curr) => prev.pendingCommand != curr.pendingCommand,
        listener: (context, state) {
          if (state.pendingCommand == null) return;
          final command = state.pendingCommand!;
          // 立即清除信号，防止重复触发
          context.read<ChatBloc>().add(const ClearPendingCommand());
          _handlePendingCommand(command);
        },
      ),
      BlocListener<ChatBloc, ChatState>(
        listenWhen: (prev, curr) => prev.messages != curr.messages,
        listener: (context, state) {
          _handleSmartReplyStateChanged(state);
        },
      ),
    ];

    if (hasContactBloc) {
      listeners.add(
        BlocListener<ContactBloc, ContactState>(
          listener: (context, state) {
            if (state.status == ContactStatus.loaded) {
              _loadOtherUserId();
              if (mounted) setState(() {});
            } else if (state.status == ContactStatus.remarkUpdated) {
              if (mounted) setState(() {});
            }
          },
        ),
      );
    }

    return MultiBlocListener(listeners: listeners, child: content);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bot 命令结果展示面板
// ─────────────────────────────────────────────────────────────────────────────

class _BotResultSheet extends StatelessWidget {
  final String title;
  final String content;

  const _BotResultSheet({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽条
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: context.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(AppIcons.close, size: 20),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: context.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
