/// 来电推送服务
///
/// 处理来电通知，包括 iOS CallKit 和 Android 前台通知
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart' as callkit;
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/debug_log.dart';
import 'incoming_call_ringtone_preference.dart';

/// 来电动作类型
enum CallAction { accept, decline, timeout, callback }

/// 来电信息
class IncomingCallInfo {
  final String callId;
  final String callerId;
  final String callerName;
  final String? callerAvatarUrl;
  final bool isVideo;
  final String? roomId;
  final Map<String, dynamic>? extra;

  IncomingCallInfo({
    required this.callId,
    required this.callerId,
    required this.callerName,
    this.callerAvatarUrl,
    this.isVideo = false,
    this.roomId,
    this.extra,
  });

  factory IncomingCallInfo.fromMap(Map<String, dynamic> map) {
    return IncomingCallInfo(
      callId: map['id'] as String? ?? '',
      callerId: map['callerId'] as String? ?? '',
      callerName: map['nameCaller'] as String? ?? 'Unknown',
      callerAvatarUrl: map['avatar'] as String?,
      isVideo: map['type'] == 1,
      roomId: map['extra']?['roomId'] as String?,
      extra: map['extra'] as Map<String, dynamic>?,
    );
  }
}

/// 来电通知服务
class CallNotificationService {
  static final CallNotificationService _instance =
      CallNotificationService._internal();
  factory CallNotificationService() => _instance;

  /// 构造函数中立即开始监听 CallKit 事件，防止 app 从锁屏/冷启动时丢失
  /// action_call_accept 事件（用户在通知中点击接听但 Flutter 引擎尚未就绪的情况）
  CallNotificationService._internal() {
    _callKitSubscription = FlutterCallkitIncoming.onEvent.listen(
      _handleCallKitEvent,
    );
    debugLog('CallNotificationService: Event listener attached in constructor');
  }

  StreamSubscription<dynamic>? _callKitSubscription;
  final _uuid = const Uuid();

  // 事件流
  final _callActionController =
      StreamController<(CallAction, IncomingCallInfo)>.broadcast();
  Stream<(CallAction, IncomingCallInfo)> get callActions =>
      _callActionController.stream;

  // 当前 CallKit 通话 ID
  String? _currentCallId;

  /// 获取当前 CallKit 通话 ID
  String? get currentCallId => _currentCallId;

  // 锁屏接听缓存：当用户从通知栏/锁屏点击"接听"时，app 可能尚未初始化，
  // 在此暂存该动作，CallManager.initialize() 完成后取出并自动接听。
  (CallAction, IncomingCallInfo)? _pendingAcceptAction;
  DateTime? _pendingAcceptTime;
  static const Duration _kPendingActionTtl = Duration(seconds: 90);

  /// 取出并清除待处理的接听动作（TTL 内有效）
  (CallAction, IncomingCallInfo)? consumePendingAcceptAction() {
    final action = _pendingAcceptAction;
    final time = _pendingAcceptTime;
    _pendingAcceptAction = null;
    _pendingAcceptTime = null;
    if (action == null || time == null) return null;
    if (DateTime.now().difference(time) > _kPendingActionTtl) {
      debugLog(
        'CallNotificationService: Pending accept action expired (TTL exceeded)',
      );
      return null;
    }
    return action;
  }

  /// 初始化（事件监听已在构造函数中设置，此处仅作日志标记）
  Future<void> initialize() async {
    debugLog(
      'CallNotificationService: Initialized (listener was attached in constructor)',
    );
  }

  /// 处理 CallKit 事件
  void _handleCallKitEvent(dynamic event) {
    if (event == null) return;

    final eventType = _parseCallKitEvent(event.event);
    debugLog('CallNotificationService: Event - ${event.event}');

    final body = event.body;
    if (body is! Map) return;

    final callInfo = IncomingCallInfo.fromMap(Map<String, dynamic>.from(body));

    if (eventType == callkit.Event.actionCallIncoming) {
      debugLog(
        'CallNotificationService: Incoming call from ${callInfo.callerName}',
      );
    } else if (eventType == callkit.Event.actionCallAccept) {
      debugLog('CallNotificationService: Call accepted by user');
      // 同时存入缓存，防止 CallManager 尚未初始化时事件丢失
      _pendingAcceptAction = (CallAction.accept, callInfo);
      _pendingAcceptTime = DateTime.now();
      _callActionController.add((CallAction.accept, callInfo));
    } else if (eventType == callkit.Event.actionCallDecline) {
      debugLog('CallNotificationService: Call declined');
      _callActionController.add((CallAction.decline, callInfo));
      _currentCallId = null;
    } else if (eventType == callkit.Event.actionCallTimeout) {
      debugLog('CallNotificationService: Call timeout');
      _callActionController.add((CallAction.timeout, callInfo));
      _currentCallId = null;
    } else if (eventType == callkit.Event.actionCallCallback) {
      debugLog('CallNotificationService: Callback');
      _callActionController.add((CallAction.callback, callInfo));
    } else if (eventType == callkit.Event.actionCallEnded) {
      debugLog('CallNotificationService: Call ended');
      _currentCallId = null;
    } else if (eventType == callkit.Event.actionCallStart) {
      debugLog('CallNotificationService: Call started');
    }
  }

  callkit.Event? _parseCallKitEvent(Object? rawEvent) {
    if (rawEvent is callkit.Event) return rawEvent;
    final normalized = rawEvent?.toString().toLowerCase();
    if (normalized == null) return null;

    if (normalized.contains('actioncallincoming') ||
        normalized.contains('action_call_incoming')) {
      return callkit.Event.actionCallIncoming;
    }
    if (normalized.contains('actioncallstart') ||
        normalized.contains('action_call_start')) {
      return callkit.Event.actionCallStart;
    }
    if (normalized.contains('actioncallaccept') ||
        normalized.contains('action_call_accept')) {
      return callkit.Event.actionCallAccept;
    }
    if (normalized.contains('actioncalldecline') ||
        normalized.contains('action_call_decline')) {
      return callkit.Event.actionCallDecline;
    }
    if (normalized.contains('actioncallended') ||
        normalized.contains('action_call_ended')) {
      return callkit.Event.actionCallEnded;
    }
    if (normalized.contains('actioncalltimeout') ||
        normalized.contains('action_call_timeout')) {
      return callkit.Event.actionCallTimeout;
    }
    if (normalized.contains('actioncallcallback') ||
        normalized.contains('action_call_callback')) {
      return callkit.Event.actionCallCallback;
    }
    return null;
  }

  /// 显示来电通知
  Future<String> showIncomingCall({
    required String callerId,
    required String callerName,
    String? callerAvatarUrl,
    bool isVideo = false,
    String? roomId,
    int durationSeconds = 60,
    Map<String, dynamic>? extra,
    // 本地化字符串参数
    String textAccept = 'Answer',
    String textDecline = 'Decline',
    String missedCallText = 'Missed call',
    String callbackText = 'Call back',
    String incomingCallChannelName = 'Incoming call',
    String missedCallChannelName = 'Missed call',
  }) async {
    final callId = _uuid.v4();
    _currentCallId = callId;
    final ringtonePreference = await IncomingCallRingtonePreference.load();

    final params = CallKitParams(
      id: callId,
      nameCaller: callerName,
      appName: 'N42 Chat',
      avatar: callerAvatarUrl,
      handle: callerId,
      type: isVideo ? 1 : 0, // 1 = video, 0 = audio
      textAccept: textAccept,
      textDecline: textDecline,
      missedCallNotification: NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: missedCallText,
        callbackText: callbackText,
      ),
      duration: durationSeconds * 1000,
      extra: <String, dynamic>{
        'callerId': callerId,
        'roomId': roomId,
        ...?extra,
      },
      headers: <String, dynamic>{
        'platform': Platform.isIOS ? 'ios' : 'android',
      },
      android: buildIncomingCallAndroidParams(
        ringtonePreference: ringtonePreference,
        avatarUrl: callerAvatarUrl,
        incomingCallChannelName: incomingCallChannelName,
        missedCallChannelName: missedCallChannelName,
      ),
      ios: buildIncomingCallIOSParams(ringtonePreference: ringtonePreference),
    );

    await FlutterCallkitIncoming.showCallkitIncoming(params);

    debugLog(
      'CallNotificationService: Showing incoming call $callId from $callerName',
    );

    return callId;
  }

  /// 显示正在通话（对于去电）
  Future<String> showOutgoingCall({
    required String calleeId,
    required String calleeName,
    String? calleeAvatarUrl,
    bool isVideo = false,
    String? roomId,
  }) async {
    final callId = _uuid.v4();
    _currentCallId = callId;

    final params = CallKitParams(
      id: callId,
      nameCaller: calleeName,
      appName: 'N42 Chat',
      avatar: calleeAvatarUrl,
      handle: calleeId,
      type: isVideo ? 1 : 0,
      extra: <String, dynamic>{'calleeId': calleeId, 'roomId': roomId},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: true,
        backgroundColor: '#0955fa',
        actionColor: '#4CAF50',
        textColor: '#ffffff',
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
      ),
    );

    await FlutterCallkitIncoming.startCall(params);

    debugLog(
      'CallNotificationService: Starting outgoing call $callId to $calleeName',
    );

    return callId;
  }

  /// 更新通话状态为已连接
  Future<void> setCallConnected(String callId) async {
    await FlutterCallkitIncoming.setCallConnected(callId);
    debugLog('CallNotificationService: Call $callId connected');
  }

  /// 结束通话
  Future<void> endCall(String callId) async {
    await FlutterCallkitIncoming.endCall(callId);
    _currentCallId = null;
    debugLog('CallNotificationService: Call $callId ended');
  }

  /// 结束所有通话
  Future<void> endAllCalls() async {
    await FlutterCallkitIncoming.endAllCalls();
    _currentCallId = null;
    debugLog('CallNotificationService: All calls ended');
  }

  /// 获取当前活动通话
  Future<List<dynamic>> getActiveCalls() async {
    final calls = await FlutterCallkitIncoming.activeCalls();
    return (calls as List<dynamic>?) ?? [];
  }

  /// 检查是否有来电权限（主要用于 iOS）
  Future<bool> checkPermissions() async {
    // flutter_callkit_incoming 会自动处理权限
    return true;
  }

  /// 显示未接来电通知
  Future<void> showMissedCall({
    required String callerId,
    required String callerName,
    String? callerAvatarUrl,
    bool isVideo = false,
    // 本地化字符串参数
    String? missedVideoCallText,
    String? missedVoiceCallText,
    String callbackText = 'Call back',
  }) async {
    final subtitle = isVideo
        ? (missedVideoCallText ?? 'Missed video call')
        : (missedVoiceCallText ?? 'Missed voice call');

    final params = CallKitParams(
      id: _uuid.v4(),
      nameCaller: callerName,
      avatar: callerAvatarUrl,
      handle: callerId,
      type: isVideo ? 1 : 0,
      missedCallNotification: NotificationParams(
        showNotification: true,
        isShowCallback: true,
        subtitle: subtitle,
        callbackText: callbackText,
      ),
    );

    await FlutterCallkitIncoming.showMissCallNotification(params);
    debugLog('CallNotificationService: Showing missed call from $callerName');
  }

  /// 清除未接来电通知
  Future<void> clearMissedCalls() async {
    // 实现清除未接来电通知的逻辑
    debugLog('CallNotificationService: Cleared missed calls');
  }

  /// 释放资源
  void dispose() {
    // 单例在同一进程内会被重复复用，不能把事件流永久关闭。
    _callKitSubscription?.cancel();
    _callKitSubscription = null;
    _currentCallId = null;
    _pendingAcceptAction = null;
    _pendingAcceptTime = null;
  }
}
