/// 1对1 语音/视频通话页面
///
/// 微信风格的通话界面，支持语音通话和视频通话
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../services/voip/call_manager.dart';
import '../../../services/voip/webrtc_service.dart';
import '../../widgets/call/call_enhancement_sheet.dart';
import '../../widgets/common/n42_avatar.dart';
import '../../../core/utils/debug_log.dart';

/// 通话页面
class CallScreen extends StatefulWidget {
  final WebRTCService webRTCService;
  final CallSession? session;
  final bool isIncoming;

  const CallScreen({
    super.key,
    required this.webRTCService,
    this.session,
    this.isIncoming = false,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  CallState _state = CallState.idle;
  Duration _duration = Duration.zero;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isSpeakerOn = false;
  bool _showControls = true;

  Timer? _hideControlsTimer;

  // 保存 session 信息（防止挂断后 webRTCService 的 session 被清除）
  CallSession? _cachedSession;

  late final WebRTCCallEnhancementController _enhancementController;

  // 保存原来的回调（用于 dispose 时恢复）
  void Function(CallState)? _originalStateCallback;
  void Function(Duration)? _originalDurationCallback;
  void Function(String)? _originalErrorCallback;

  // 微信风格的颜色
  static const Color _bgColor = Color(0xFF1F1F1F);
  static const Color _controlBgColor = Color(0xFF3D3D3D);
  static const Color _controlActiveBgColor = Colors.white;
  static const Color _hangupColor = Color(0xFFFA5151);
  static const Color _answerColor = Color(0xFF07C160);

  @override
  void initState() {
    super.initState();

    // 脉冲动画（等待接听时）
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 保持屏幕常亮
    WakelockPlus.enable();

    _enhancementController = WebRTCCallEnhancementController(
      widget.webRTCService,
    );

    // 保存原来的回调
    _originalStateCallback = widget.webRTCService.onStateChanged;
    _originalDurationCallback = widget.webRTCService.onDurationUpdate;
    _originalErrorCallback = widget.webRTCService.onError;

    // 监听通话状态（包装原来的回调）
    widget.webRTCService.onStateChanged = _onStateChanged;
    widget.webRTCService.onDurationUpdate = _onDurationUpdate;
    widget.webRTCService.onError = _onError;

    _state = widget.webRTCService.state;
    _syncControlsFromService();

    // 缓存 session 信息
    _cachedSession = widget.session ?? widget.webRTCService.currentSession;

    if (_state == CallState.ringing || _state == CallState.incoming) {
      _pulseController.repeat(reverse: true);
    }

    // 设置状态栏为透明
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    // 恢复原来的回调（CallManager 的回调）
    widget.webRTCService.onStateChanged = _originalStateCallback;
    widget.webRTCService.onDurationUpdate = _originalDurationCallback;
    widget.webRTCService.onError = _originalErrorCallback;

    _pulseController.dispose();
    _hideControlsTimer?.cancel();
    WakelockPlus.disable();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  void _onStateChanged(CallState state) {
    // 先调用原来的回调（CallManager）
    _originalStateCallback?.call(state);

    if (!mounted) return;

    setState(() {
      _state = state;
      _syncControlsFromService();
    });

    if (state == CallState.connected) {
      _pulseController.stop();
      _startHideControlsTimer();
      // 确保 iOS 上音频路由初始状态正确（听筒模式）
      try {
        Helper.setSpeakerphoneOn(false);
      } catch (e) {
        debugLog('CallScreen: Failed to set initial audio route: $e');
      }
    } else if (state == CallState.ended || state == CallState.failed) {
      // 延迟关闭页面
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  void _onDurationUpdate(Duration duration) {
    // 先调用原来的回调
    _originalDurationCallback?.call(duration);

    if (!mounted) return;

    setState(() {
      _duration = duration;
    });
  }

  void _onError(String error) {
    // 先调用原来的回调
    _originalErrorCallback?.call(error);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: _hangupColor),
      );
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    if (_isVideoCall) {
      _hideControlsTimer = Timer(const Duration(seconds: 5), () {
        if (mounted && _state == CallState.connected) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  void _syncControlsFromService() {
    _isMuted = widget.webRTCService.isMuted;
    _isVideoEnabled = widget.webRTCService.isVideoEnabled;
    _isSpeakerOn = widget.webRTCService.isSpeakerOn;
  }

  bool get _isVideoCall =>
      widget.session?.type == CallType.video ||
      widget.webRTCService.currentSession?.type == CallType.video;

  CallSession? get _session =>
      _cachedSession ?? widget.session ?? widget.webRTCService.currentSession;

  @override
  Widget build(BuildContext context) {
    if (_isVideoCall) {
      return _buildVideoCallUI();
    }
    return _buildVoiceCallUI();
  }

  /// 语音通话界面 - 微信风格
  Widget _buildVoiceCallUI() {
    final l10n = S.of(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // 主内容
            Column(
              children: [
                SizedBox(height: statusBarHeight + 16),

                // 顶部栏：返回按钮
                _buildTopBar(),

                const Spacer(flex: 1),

                // 头像
                _buildAvatar(),

                const SizedBox(height: 20),

                // 用户名
                Text(
                  _session?.peerName ?? (l10n?.commonUnknownUser ?? 'Unknown'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                // 状态文字或通话时长
                Text(
                  _state == CallState.connected
                      ? _formatDuration(_duration)
                      : _getStatusText(context),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 15,
                  ),
                ),

                const Spacer(flex: 2),

                // 控制按钮
                if (_state == CallState.incoming)
                  _buildIncomingControlsWeChat()
                else
                  _buildVoiceControlsWeChat(),

                const SizedBox(height: 60),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 视频通话界面
  Widget _buildVideoCallUI() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _state == CallState.connected ? _toggleControls : null,
        child: Stack(
          children: [
            // 远程视频（全屏）
            _buildRemoteVideo(),

            // 本地视频（画中画）
            if (_state == CallState.connected) _buildLocalVideo(),

            // 顶部渐变遮罩
            if (_showControls)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 120,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

            // 底部渐变遮罩
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 200,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

            // 顶部信息
            if (_showControls || _state != CallState.connected)
              _buildVideoTopInfo(),

            // 控制按钮
            if (_showControls || _state != CallState.connected)
              _buildVideoControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 最小化按钮
          _buildTopActionButton(
            icon: Icons.keyboard_arrow_down,
            onTap: () => Navigator.of(context).pop(),
            backgroundColor: _controlBgColor,
          ),
          const Spacer(),
          if (_state == CallState.connected)
            _buildTopActionButton(
              icon: Icons.tune,
              onTap: _openCallEnhancementTools,
              backgroundColor: _controlBgColor,
              iconSize: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildTopActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color backgroundColor,
    double iconSize = 24,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }

  Widget _buildAvatar() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale =
            (_state == CallState.ringing || _state == CallState.incoming)
            ? _pulseAnimation.value
            : 1.0;
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 3,
          ),
        ),
        child: ClipOval(
          child: N42Avatar(
            name: _session?.peerName ?? '',
            imageUrl: _session?.peerAvatarUrl,
            size: 114,
            borderRadius: 57,
          ),
        ),
      ),
    );
  }

  /// 语音通话控制按钮 - 微信风格
  Widget _buildVoiceControlsWeChat() {
    final l10n = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 上行：功能按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 静音
              _buildWeChatControlButton(
                icon: _isMuted ? Icons.mic_off : Icons.mic,
                label: _isMuted
                    ? (l10n?.callUnmuteLabel ?? 'Unmute')
                    : (l10n?.callMuteLabel ?? 'Mute'),
                isActive: _isMuted,
                onTap: _toggleMute,
              ),

              // 扬声器
              _buildWeChatControlButton(
                icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                label: _isSpeakerOn
                    ? (l10n?.chatSpeakerOff ?? 'Speaker Off')
                    : (l10n?.chatSpeakerOn ?? 'Speaker'),
                isActive: _isSpeakerOn,
                onTap: _toggleSpeaker,
              ),

              _buildWeChatControlButton(
                icon: Icons.chat_bubble_outline,
                label: l10n?.callChatLabel ?? 'Chat',
                onTap: _backToChat,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 下行：挂断按钮居中
          _buildWeChatHangupButton(),
        ],
      ),
    );
  }

  /// 来电控制按钮 - 微信风格
  Widget _buildIncomingControlsWeChat() {
    final l10n = S.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 拒绝
          _buildWeChatActionButton(
            icon: Icons.call_end,
            label: l10n?.callDecline ?? '拒绝',
            color: _hangupColor,
            onTap: _rejectCall,
          ),

          // 接听
          _buildWeChatActionButton(
            icon: Icons.call,
            label: l10n?.callAnswer ?? '接听',
            color: _answerColor,
            onTap: _answerCall,
          ),
        ],
      ),
    );
  }

  Widget _buildWeChatControlButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? _controlActiveBgColor : _controlBgColor,
            ),
            child: Icon(
              icon,
              color: isActive ? _bgColor : Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeChatHangupButton() {
    final l10n = S.of(context);
    return GestureDetector(
      onTap: _hangup,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _hangupColor,
            ),
            child: const Icon(Icons.call_end, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 10),
          Text(
            l10n?.chatHangUp ?? 'Hang Up',
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildWeChatActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoteVideo() {
    return Positioned.fill(
      child: RTCVideoView(
        widget.webRTCService.remoteRenderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        mirror: false,
      ),
    );
  }

  Widget _buildLocalVideo() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 60,
      right: 16,
      child: GestureDetector(
        onTap: () {},
        child: Container(
          width: 100,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: _isVideoEnabled
                ? RTCVideoView(
                    widget.webRTCService.localRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    mirror: true,
                  )
                : Container(
                    color: _bgColor,
                    child: const Center(
                      child: Icon(
                        Icons.videocam_off,
                        color: Colors.white54,
                        size: 28,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoTopInfo() {
    final l10n = S.of(context);
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return Positioned(
      top: statusBarHeight + 16,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // 返回按钮
          _buildTopActionButton(
            icon: Icons.keyboard_arrow_down,
            onTap: () => Navigator.of(context).pop(),
            backgroundColor: Colors.black.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 12),
          // 用户名和状态
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _session?.peerName ?? (l10n?.commonUnknownUser ?? 'Unknown'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _state == CallState.connected
                      ? _formatDuration(_duration)
                      : _getStatusText(context),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (_state == CallState.connected)
            _buildTopActionButton(
              icon: Icons.tune,
              onTap: _openCallEnhancementTools,
              backgroundColor: Colors.black.withValues(alpha: 0.3),
              iconSize: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    if (_state == CallState.incoming) {
      return Positioned(
        bottom: 60,
        left: 0,
        right: 0,
        child: _buildIncomingControlsWeChat(),
      );
    }

    final l10n = S.of(context);
    return Positioned(
      bottom: 60,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 上行：功能按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 静音
                _buildWeChatControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  label: _isMuted
                      ? (l10n?.callUnmuteLabel ?? 'Unmute')
                      : (l10n?.callMuteLabel ?? 'Mute'),
                  isActive: _isMuted,
                  onTap: _toggleMute,
                ),

                // 视频开关
                _buildWeChatControlButton(
                  icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
                  label: _isVideoEnabled
                      ? (l10n?.chatCameraOff ?? 'Camera Off')
                      : (l10n?.chatCameraOn ?? 'Camera On'),
                  isActive: !_isVideoEnabled,
                  onTap: _toggleVideo,
                ),

                // 切换摄像头
                _buildWeChatControlButton(
                  icon: Icons.cameraswitch,
                  label: l10n?.callSwitchCameraLabel ?? 'Switch',
                  onTap: _switchCamera,
                ),

                _buildWeChatControlButton(
                  icon: Icons.chat_bubble_outline,
                  label: l10n?.callChatLabel ?? 'Chat',
                  onTap: _backToChat,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 下行：挂断按钮居中
            _buildWeChatHangupButton(),
          ],
        ),
      ),
    );
  }

  String _getStatusText(BuildContext context) {
    final l10n = S.of(context);
    switch (_state) {
      case CallState.ringing:
        return l10n?.chatCalling ?? '正在呼叫...';
      case CallState.incoming:
        return _isVideoCall
            ? (l10n?.callIncomingVideoCall ?? '视频通话邀请')
            : (l10n?.callIncomingVoiceCall ?? '语音通话邀请');
      case CallState.connecting:
        return l10n?.chatConnectingCall ?? '连接中...';
      case CallState.connected:
        return _isVideoCall
            ? (l10n?.callVideoCallInProgress ?? '视频通话中')
            : (l10n?.callVoiceCallInProgress ?? '语音通话中');
      case CallState.reconnecting:
        return l10n?.callReconnectingCall ?? '重新连接中...';
      case CallState.ended:
        return l10n?.callEnded ?? '通话已结束';
      case CallState.failed:
        return l10n?.callFailed ?? '通话失败';
      case CallState.idle:
        return '';
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void _toggleMute() {
    widget.webRTCService.toggleMute();
    setState(() {
      _syncControlsFromService();
    });
  }

  Future<void> _toggleSpeaker() async {
    await widget.webRTCService.toggleSpeaker();
    if (!mounted) return;
    setState(() {
      _syncControlsFromService();
    });
  }

  void _toggleVideo() {
    widget.webRTCService.toggleVideo();
    setState(() {
      _syncControlsFromService();
    });
  }

  void _switchCamera() {
    widget.webRTCService.switchCamera();
  }

  Future<void> _openCallEnhancementTools() async {
    await showCallEnhancementSheet(
      context: context,
      controller: _enhancementController,
      title: 'Call tools',
      onChanged: () {
        if (!mounted) return;
        setState(() {
          _syncControlsFromService();
        });
      },
    );
  }

  Future<void> _answerCall() async {
    // 先停止铃声
    await CallManager().stopRingtone();
    // 接听
    await widget.webRTCService.answerCall();
  }

  Future<void> _rejectCall() async {
    // 停止铃声
    await CallManager().stopRingtone();
    await widget.webRTCService.rejectCall();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _hangup() async {
    // 停止铃声/通知
    await CallManager().stopRingtone();
    await widget.webRTCService.hangup();
  }

  void _backToChat() {
    Navigator.of(context).maybePop();
  }
}
