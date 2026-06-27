/// 通话管理器
///
/// 统一管理 1对1 通话和多人会议，提供简化的 API
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:matrix/matrix.dart' as matrix;

import '../../../l10n/app_localizations.dart';
import '../../n42_chat.dart';
import '../../core/utils/livekit_call_utils.dart';
import '../../core/services/system_integration_service.dart';
import 'voip_config.dart';
import 'webrtc_service.dart';
import 'livekit_service.dart';
import 'call_notification_service.dart';
import '../../presentation/pages/call/call_screen.dart';
import '../../presentation/pages/call/group_call_screen.dart';
import '../../core/utils/debug_log.dart';

/// 通话管理器
///
/// 提供以下功能：
/// - 1对1 语音/视频通话（WebRTC）
/// - 多人视频会议（LiveKit）
/// - 来电推送通知
/// - 通话记录
class CallManager {
  static final CallManager _instance = CallManager._internal();
  factory CallManager() => _instance;
  CallManager._internal();

  // 服务实例
  matrix.Client? _client;
  WebRTCService? _webRTCService;
  LiveKitService? _liveKitService;
  final CallNotificationService _notificationService =
      CallNotificationService();
  final VoIPConfig _config = VoIPConfig();
  // 系统级集成：通话进行中显示常驻"活动"通知（Android 真实生效）
  final SystemIntegrationService _systemIntegration =
      SystemIntegrationService();

  // 导航键
  GlobalKey<NavigatorState>? _navigatorKey;

  // 是否已初始化
  bool _isInitialized = false;

  // 通知动作订阅
  StreamSubscription<(CallAction, IncomingCallInfo)>? _callActionSubscription;

  // 是否已显示通话界面
  bool _isCallScreenShowing = false;

  // 锁屏接听标志：用户在锁屏/通知栏点击接听但 Matrix 邀请尚未到达时设为 true。
  // 当 _handleIncomingCall() 被调用时，若此标志为 true，则自动接听而非显示来电界面。
  bool _pendingAnswer = false;
  Timer? _pendingAnswerResetTimer;
  static const Duration _pendingAnswerTtl = Duration(seconds: 90);

  // 事件回调
  void Function(CallSession)? onIncomingCall;
  void Function(CallState)? onCallStateChanged;
  void Function(String error)? onError;

  // ============================================
  // Getters & Setters
  // ============================================

  /// 更新导航键（在 N42Chat.setNavigatorKey() 中调用）
  void setNavigatorKey(GlobalKey<NavigatorState>? key) {
    _navigatorKey = key;
    debugLog('CallManager: Navigator key updated');
  }

  VoIPConfig get config => _config;
  WebRTCService? get webRTCService => _webRTCService;
  LiveKitService? get liveKitService => _liveKitService;
  bool get isInitialized => _isInitialized;
  bool get isInCall => _webRTCService?.isInCall ?? false;
  bool get isInMeeting => _liveKitService?.isInMeeting ?? false;

  void _setPendingAnswer(bool pending) {
    _pendingAnswerResetTimer?.cancel();
    _pendingAnswerResetTimer = null;
    _pendingAnswer = pending;
    if (!pending) return;

    _pendingAnswerResetTimer = Timer(_pendingAnswerTtl, () {
      if (_pendingAnswer) {
        _pendingAnswer = false;
        debugLog('CallManager: Pending answer expired before invite arrived');
      }
    });
  }

  // ============================================
  // 初始化
  // ============================================

  /// 初始化通话管理器
  ///
  /// [client] Matrix 客户端实例
  /// [navigatorKey] 用于导航到通话页面的 GlobalKey
  Future<void> initialize({
    required matrix.Client client,
    GlobalKey<NavigatorState>? navigatorKey,
  }) async {
    if (_isInitialized) {
      debugLog('CallManager: Already initialized');
      return;
    }

    _navigatorKey = navigatorKey;
    _client = client;

    // 初始化通知服务
    await _notificationService.initialize();

    // 监听来电通知动作
    _callActionSubscription = _notificationService.callActions.listen((event) {
      final (action, callInfo) = event;
      _handleNotificationAction(action, callInfo);
    });

    // 初始化 WebRTC 服务
    _webRTCService = WebRTCService(client);
    await _webRTCService!.initialize();

    // 设置 WebRTC 回调
    _webRTCService!.onIncomingCall = _handleIncomingCall;
    _webRTCService!.onStateChanged = _handleCallStateChanged;
    _webRTCService!.onError = (error) => onError?.call(error);

    // 初始化 LiveKit 服务
    _liveKitService = LiveKitService();

    _isInitialized = true;
    debugLog('CallManager: Initialized');

    // 检查是否有在 app 冷启动期间（CallManager 尚未就绪时）用户已点击接听的缓存事件。
    // 若有，设置 _pendingAnswer 标志，待 Matrix 邀请到达时自动接听。
    unawaited(
      Future.microtask(() async {
        try {
          final pending = _notificationService.consumePendingAcceptAction();
          if (pending != null) {
            final (_, callInfo) = pending;
            debugLog(
              'CallManager: Found pending accept action from ${callInfo.callerName}, '
              'setting _pendingAnswer=true',
            );
            _setPendingAnswer(true);
          }
        } catch (e) {
          debugLog('CallManager: Error checking pending accept action: $e');
        }

        // 同时检查系统中是否有活跃的 CallKit 通话记录
        try {
          final activeCalls = await _notificationService.getActiveCalls();
          if (activeCalls.isNotEmpty) {
            debugLog(
              'CallManager: ${activeCalls.length} active CallKit call(s) found '
              'after initialization — awaiting Matrix sync to deliver invite',
            );
          }
        } catch (e) {
          debugLog('CallManager: Error checking active calls: $e');
        }
      }),
    );
  }

  /// 配置 TURN 服务器
  void configureTurn({
    required List<String> uris,
    String? username,
    String? password,
    int? ttl,
  }) {
    _config.turnUris = uris;
    _config.turnUsername = username;
    _config.turnPassword = password;
    if (ttl != null) _config.turnTtl = ttl;
    debugLog('CallManager: TURN configured with ${uris.length} URIs');
  }

  /// 配置 LiveKit
  void configureLiveKit({
    required String url,
    String? apiKey,
    String? apiSecret,
  }) {
    _config.configureLiveKit(url: url, apiKey: apiKey, apiSecret: apiSecret);
  }

  // ============================================
  // 1对1 通话
  // ============================================

  /// 发起语音通话
  Future<bool> startVoiceCall({
    required String roomId,
    required String peerId,
    required String peerName,
    String? peerAvatarUrl,
  }) async {
    return _startCall(
      roomId: roomId,
      peerId: peerId,
      peerName: peerName,
      peerAvatarUrl: peerAvatarUrl,
      type: CallType.voice,
    );
  }

  /// 发起视频通话
  Future<bool> startVideoCall({
    required String roomId,
    required String peerId,
    required String peerName,
    String? peerAvatarUrl,
  }) async {
    return _startCall(
      roomId: roomId,
      peerId: peerId,
      peerName: peerName,
      peerAvatarUrl: peerAvatarUrl,
      type: CallType.video,
    );
  }

  Future<bool> _startCall({
    required String roomId,
    required String peerId,
    required String peerName,
    String? peerAvatarUrl,
    required CallType type,
  }) async {
    if (_webRTCService == null) {
      onError?.call('call_not_initialized');
      return false;
    }

    if (isInCall || isInMeeting) {
      onError?.call('already_in_call');
      return false;
    }

    // 设置活跃房间，禁用该房间的消息通知
    N42Chat.pushService?.setActiveRoom(roomId);
    // 设置通话状态，禁用所有消息通知
    N42Chat.pushService?.setInCall(true);

    // 显示去电通知
    await _notificationService.showOutgoingCall(
      calleeId: peerId,
      calleeName: peerName,
      calleeAvatarUrl: peerAvatarUrl,
      isVideo: type == CallType.video,
      roomId: roomId,
    );

    // 发起通话
    final success = await _webRTCService!.startCall(
      roomId: roomId,
      type: type,
      peerId: peerId,
      peerName: peerName,
      peerAvatarUrl: peerAvatarUrl,
    );

    if (success) {
      // 导航到通话页面
      _navigateToCallScreen();
    } else {
      await _notificationService.endAllCalls();
      // 通话失败，恢复推送通知状态
      N42Chat.pushService?.setActiveRoom(null);
      N42Chat.pushService?.setInCall(false);
    }

    return success;
  }

  /// 接听来电
  Future<bool> answerCall() async {
    debugLog('CallManager: answerCall called');
    debugLog(
      'CallManager: _isInitialized=$_isInitialized, _webRTCService=${_webRTCService != null ? "exists" : "null"}',
    );

    if (_webRTCService == null) {
      debugLog('CallManager: ERROR - webRTCService is null in answerCall');
      return false;
    }

    final state = _webRTCService!.state;
    final session = _webRTCService!.currentSession;
    debugLog(
      'CallManager: current state=$state, session=${session != null ? "exists (callId=${session.callId})" : "null"}',
    );

    if (state != CallState.incoming || session == null) {
      _setPendingAnswer(true);
      debugLog(
        'CallManager: Incoming invite not ready yet, deferring answer until session arrives',
      );
      return false;
    }

    // 清除锁屏接听标志（用户已主动接听）
    _setPendingAnswer(false);

    // 立即停止来电铃声和通知
    await _notificationService.endAllCalls();

    final success = await _webRTCService!.answerCall();
    debugLog('CallManager: answerCall result=$success');
    if (success) {
      _navigateToCallScreen(isIncoming: true, session: session);
    }
    return success;
  }

  /// 拒绝来电
  Future<void> rejectCall() async {
    _setPendingAnswer(false);
    await _webRTCService?.rejectCall();
    await _notificationService.endAllCalls();
    // 清除活跃房间
    N42Chat.pushService?.setActiveRoom(null);
    // 清除通话状态，恢复消息通知
    N42Chat.pushService?.setInCall(false);
  }

  /// 停止来电铃声（不挂断通话）
  Future<void> stopRingtone() async {
    await _notificationService.endAllCalls();
  }

  /// 挂断通话
  Future<void> hangupCall() async {
    await _webRTCService?.hangup();
    await _notificationService.endAllCalls();
    // 清除活跃房间
    N42Chat.pushService?.setActiveRoom(null);
    // 清除通话状态，恢复消息通知
    N42Chat.pushService?.setInCall(false);
  }

  // ============================================
  // 多人会议
  // ============================================

  /// 创建会议
  ///
  /// [roomName] 会议名称
  /// [participantName] 参与者名称
  /// [token] LiveKit 访问令牌（从服务端获取）
  Future<bool> createMeeting({
    required String roomName,
    required String participantName,
    required String token,
    String? meetingDisplayName,
    String? participantAvatarUrl,
    bool enableVideo = true,
    bool enableAudio = true,
  }) async {
    return joinMeeting(
      roomName: roomName,
      participantName: participantName,
      token: token,
      meetingDisplayName: meetingDisplayName,
      participantAvatarUrl: participantAvatarUrl,
      enableVideo: enableVideo,
      enableAudio: enableAudio,
    );
  }

  /// 加入会议
  Future<bool> joinMeeting({
    required String roomName,
    required String participantName,
    required String token,
    String? meetingDisplayName,
    String? participantAvatarUrl,
    bool enableVideo = true,
    bool enableAudio = true,
  }) async {
    if (_liveKitService == null) {
      onError?.call('meeting_not_initialized');
      return false;
    }

    if (!_config.hasLiveKitConfig) {
      onError?.call('livekit_not_configured');
      return false;
    }

    if (isInCall || isInMeeting) {
      onError?.call('already_in_call');
      return false;
    }

    final success = await _liveKitService!.joinMeeting(
      roomName: roomName,
      token: token,
      participantName: participantName,
      participantAvatarUrl: participantAvatarUrl,
      enableVideo: enableVideo,
      enableAudio: enableAudio,
    );

    if (success) {
      _navigateToGroupCallScreen(meetingDisplayName ?? roomName);
    }

    return success;
  }

  Future<bool> startGroupVoiceCall({
    required String conversationId,
    required String roomDisplayName,
    String? participantName,
    String? participantAvatarUrl,
  }) {
    return _startGroupCall(
      conversationId: conversationId,
      roomDisplayName: roomDisplayName,
      participantName: participantName,
      participantAvatarUrl: participantAvatarUrl,
      enableVideo: false,
    );
  }

  Future<bool> startGroupVideoCall({
    required String conversationId,
    required String roomDisplayName,
    String? participantName,
    String? participantAvatarUrl,
  }) {
    return _startGroupCall(
      conversationId: conversationId,
      roomDisplayName: roomDisplayName,
      participantName: participantName,
      participantAvatarUrl: participantAvatarUrl,
      enableVideo: true,
    );
  }

  Future<bool> _startGroupCall({
    required String conversationId,
    required String roomDisplayName,
    String? participantName,
    String? participantAvatarUrl,
    required bool enableVideo,
  }) async {
    final client = _client;
    final userId = client?.userID;
    if (client == null || userId == null || userId.isEmpty) {
      onError?.call('call_not_initialized');
      return false;
    }

    if (!_config.hasLiveKitConfig || N42Chat.liveKitJwtUrl == null) {
      onError?.call('livekit_not_configured');
      return false;
    }

    final currentDisplayName = N42Chat.currentUser?.displayName.trim();
    final resolvedParticipantName = participantName?.trim().isNotEmpty == true
        ? participantName!.trim()
        : (currentDisplayName != null && currentDisplayName.isNotEmpty
              ? currentDisplayName
              : userId);
    final roomName = buildLiveKitRoomName(conversationId);

    final token = await _fetchLiveKitToken(
      conversationId: conversationId,
      roomName: roomName,
      participantId: userId,
      participantName: resolvedParticipantName,
      enableVideo: enableVideo,
    );
    if (token == null) {
      return false;
    }

    return joinMeeting(
      roomName: roomName,
      meetingDisplayName: roomDisplayName,
      participantName: resolvedParticipantName,
      participantAvatarUrl: participantAvatarUrl,
      token: token,
      enableVideo: enableVideo,
      enableAudio: true,
    );
  }

  Future<String?> _fetchLiveKitToken({
    required String conversationId,
    required String roomName,
    required String participantId,
    required String participantName,
    required bool enableVideo,
  }) async {
    final client = _client;
    final jwtUrl = N42Chat.liveKitJwtUrl?.trim();
    final accessToken = client?.accessToken?.trim();
    if (client == null ||
        jwtUrl == null ||
        jwtUrl.isEmpty ||
        accessToken == null ||
        accessToken.isEmpty) {
      onError?.call('livekit_not_configured');
      return null;
    }

    final uri = Uri.parse(jwtUrl);
    final headers = <String, String>{
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    final payload = <String, Object?>{
      'room': roomName,
      'identity': participantId,
      'name': participantName,
      'video': enableVideo,
      'conversation_id': conversationId,
      'metadata': jsonEncode({
        'conversation_id': conversationId,
        'video': enableVideo,
      }),
    };

    try {
      final postResponse = await client.httpClient.post(
        uri,
        headers: headers,
        body: jsonEncode(payload),
      );
      final token = _extractTokenFromResponse(postResponse);
      if (token != null) {
        return token;
      }
      debugLog(
        'CallManager: LiveKit token POST returned ${postResponse.statusCode} without token',
      );
    } catch (e) {
      debugLog('CallManager: LiveKit token POST failed: $e');
    }

    try {
      final getUri = buildLiveKitTokenUri(
        jwtUrl,
        roomName: roomName,
        participantId: participantId,
        participantName: participantName,
        enableVideo: enableVideo,
        conversationId: conversationId,
      );
      final getResponse = await client.httpClient.get(getUri, headers: headers);
      final token = _extractTokenFromResponse(getResponse);
      if (token != null) {
        return token;
      }
      debugLog(
        'CallManager: LiveKit token GET returned ${getResponse.statusCode} without token',
      );
    } catch (e) {
      debugLog('CallManager: LiveKit token GET failed: $e');
    }

    onError?.call('livekit_token_fetch_failed');
    return null;
  }

  String? _extractTokenFromResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }
    return extractLiveKitToken(response.body);
  }

  /// 离开会议
  Future<void> leaveMeeting() async {
    await _liveKitService?.leaveMeeting();
  }

  // ============================================
  // 私有方法
  // ============================================

  void _handleIncomingCall(CallSession session) async {
    try {
      debugLog('CallManager: Incoming call from ${session.peerName}');

      // 设置活跃房间，禁用该房间的消息通知
      N42Chat.pushService?.setActiveRoom(session.roomId);
      // 设置通话状态，禁用所有消息通知
      N42Chat.pushService?.setInCall(true);

      // === 锁屏接听自动应答 ===
      // 用户在锁屏/通知栏点击接听，但 Matrix 邀请此时才到达时，自动接听
      if (_pendingAnswer) {
        _setPendingAnswer(false);
        debugLog(
          'CallManager: Auto-answering call (user tapped Accept before Matrix invite arrived)',
        );
        // 清除 CallKit 通知
        await _notificationService.endAllCalls();
        // 直接接听
        final success = await _webRTCService!.answerCall();
        if (success) {
          _navigateToCallScreen(isIncoming: true, session: session);
        } else {
          debugLog(
            'CallManager: Auto-answer failed, falling through to show incoming screen',
          );
          _navigateToCallScreen(isIncoming: true, session: session);
        }
        onIncomingCall?.call(session);
        return;
      }

      // 检查是否已有活跃的 CallKit 来电（由后台推送触发）
      // 避免重复显示来电界面
      bool alreadyShowing = false;
      try {
        final activeCalls = await _notificationService.getActiveCalls();
        alreadyShowing = activeCalls.isNotEmpty;
      } catch (e) {
        debugLog('CallManager: Failed to check active calls: $e');
      }

      if (!alreadyShowing) {
        // 获取本地化字符串
        final context = _navigatorKey?.currentContext;
        final l10n = (context != null && context.mounted)
            ? S.of(context)
            : null;

        // 显示来电通知
        await _notificationService.showIncomingCall(
          callerId: session.peerId,
          callerName: session.peerName,
          callerAvatarUrl: session.peerAvatarUrl,
          isVideo: session.type == CallType.video,
          roomId: session.roomId,
          textAccept: l10n?.callAnswer ?? 'Answer',
          textDecline: l10n?.callDecline ?? 'Decline',
          missedCallText: l10n?.callMissedCall ?? 'Missed call',
          callbackText: l10n?.chatCallBack ?? 'Call back',
          incomingCallChannelName: l10n?.callIncomingCall ?? 'Incoming call',
          missedCallChannelName: l10n?.callMissedCall ?? 'Missed call',
        );
      } else {
        debugLog(
          'CallManager: CallKit already showing from background push, skipping duplicate',
        );
      }

      // 直接导航到来电界面（如果应用在前台）
      _navigateToCallScreen(isIncoming: true, session: session);

      onIncomingCall?.call(session);
    } catch (e, stack) {
      debugLog('CallManager: Error handling incoming call: $e\n$stack');
    }
  }

  void _handleCallStateChanged(CallState state) {
    debugLog('CallManager: Call state changed to $state');

    if (state == CallState.connected) {
      final callKitId = _notificationService.currentCallId;
      if (callKitId != null) {
        _notificationService.setCallConnected(callKitId);
      }
      // 进行中活动：常驻通知（Android 真实生效；iOS Live Activity 待原生）
      final ctx = _navigatorKey?.currentContext;
      final title = (ctx != null && ctx.mounted)
          ? (S.of(ctx)?.chatInCall ?? 'In call')
          : 'In call';
      _systemIntegration.updateLiveActivity(id: 'call', title: title);
      // 确保通话界面已显示
      if (!_isCallScreenShowing) {
        debugLog(
          'CallManager: Call connected but screen not showing, navigating now',
        );
        _navigateToCallScreen();
      }
    } else if (state == CallState.ended || state == CallState.failed) {
      _notificationService.endAllCalls();
      _systemIntegration.endLiveActivity('call');
      _isCallScreenShowing = false;
      // 清除活跃房间，恢复该房间的消息通知
      N42Chat.pushService?.setActiveRoom(null);
      // 清除通话状态，恢复消息通知
      N42Chat.pushService?.setInCall(false);
    }

    onCallStateChanged?.call(state);
  }

  void _handleNotificationAction(CallAction action, IncomingCallInfo callInfo) {
    // 获取本地化字符串
    final context = _navigatorKey?.currentContext;
    final l10n = (context != null && context.mounted) ? S.of(context) : null;

    switch (action) {
      case CallAction.accept:
        _notificationService.consumePendingAcceptAction();
        answerCall();
        break;
      case CallAction.decline:
        _setPendingAnswer(false);
        rejectCall();
        break;
      case CallAction.timeout:
        _setPendingAnswer(false);
        // 显示未接来电
        _notificationService.showMissedCall(
          callerId: callInfo.callerId,
          callerName: callInfo.callerName,
          callerAvatarUrl: callInfo.callerAvatarUrl,
          isVideo: callInfo.isVideo,
          missedVideoCallText: l10n?.chatMissedVideoCall ?? 'Missed video call',
          missedVoiceCallText: l10n?.chatMissedVoiceCall ?? 'Missed voice call',
          callbackText: l10n?.chatCallBack ?? 'Call back',
        );
        break;
      case CallAction.callback:
        _setPendingAnswer(false);
        // 回拨
        if (callInfo.roomId != null) {
          startVoiceCall(
            roomId: callInfo.roomId!,
            peerId: callInfo.callerId,
            peerName: callInfo.callerName,
            peerAvatarUrl: callInfo.callerAvatarUrl,
          );
        }
        break;
    }
  }

  void _navigateToCallScreen({
    bool isIncoming = false,
    CallSession? session,
    int retryCount = 0,
  }) {
    debugLog(
      'CallManager: _navigateToCallScreen called, isIncoming=$isIncoming, _isCallScreenShowing=$_isCallScreenShowing, retry=$retryCount',
    );

    if (_isCallScreenShowing) {
      debugLog('CallManager: Call screen already showing, skipping navigation');
      return;
    }

    if (_navigatorKey == null) {
      debugLog(
        'CallManager: ERROR - navigatorKey is null! Did you call N42Chat.setNavigatorKey()?',
      );
      return;
    }

    final context = _navigatorKey?.currentContext;
    if (context == null) {
      // App 冷启动时 context 可能暂时为 null，重试最多 10 次（间隔 1s，共等待约 10s）
      // 覆盖 app 从锁屏/killed 状态启动后 UI 就绪所需的时间
      if (retryCount < 10) {
        debugLog(
          'CallManager: Context null, retrying in 1s (attempt ${retryCount + 1}/10)',
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (_isInitialized) {
            _navigateToCallScreen(
              isIncoming: isIncoming,
              session: session,
              retryCount: retryCount + 1,
            );
          } else {
            debugLog('CallManager: Retry cancelled - CallManager was disposed');
          }
        });
      } else {
        debugLog(
          'CallManager: ERROR - navigatorKey.currentContext still null after 10 retries (10s)',
        );
      }
      return;
    }

    if (_webRTCService == null) {
      debugLog('CallManager: ERROR - webRTCService is null!');
      return;
    }

    debugLog('CallManager: Navigating to CallScreen');
    _isCallScreenShowing = true;

    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (context) => CallScreen(
              webRTCService: _webRTCService!,
              session: session,
              isIncoming: isIncoming,
            ),
          ),
        )
        .then((_) {
          debugLog('CallManager: CallScreen closed');
          _isCallScreenShowing = false;
        });
  }

  void _navigateToGroupCallScreen(String roomName) {
    final context = _navigatorKey?.currentContext;
    if (context == null || _liveKitService == null) return;

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => GroupCallScreen(
          liveKitService: _liveKitService!,
          roomName: roomName,
        ),
      ),
    );
  }

  // ============================================
  // 资源释放
  // ============================================

  /// 释放资源
  Future<void> dispose() async {
    await _callActionSubscription?.cancel();
    _callActionSubscription = null;
    await _webRTCService?.dispose();
    _webRTCService = null;
    // LiveKitService.dispose() 是同步的（ChangeNotifier 要求）
    // 如需异步清理，应先调用 leaveMeeting()
    await _liveKitService?.leaveMeeting();
    _liveKitService?.dispose();
    _liveKitService = null;
    _notificationService.dispose();
    _client = null;
    _navigatorKey = null;
    _isCallScreenShowing = false;
    _setPendingAnswer(false);
    _isInitialized = false;
    debugLog('CallManager: Disposed');
  }
}
