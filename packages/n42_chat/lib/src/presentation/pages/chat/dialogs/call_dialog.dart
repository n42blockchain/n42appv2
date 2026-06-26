// Copyright 2021-2026 N42 Inc. All rights reserved.
// Use of this source code is governed by a dual license:
// Apache License 2.0 and MIT License.
// See LICENSE file in the project root for full license information.

import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/debug_log.dart';
import '../../../../services/voip/call_manager.dart';
import '../../../../services/voip/webrtc_service.dart';

/// 通话对话框（轻量浮层）
///
/// 作为通话发起后的过渡 UI 使用。真正的通话控制通过 CallManager 单例
/// 和底层 WebRTCService 执行，保证与 CallScreen（全屏通话页）使用同一
/// 服务实例，避免状态不一致。
///
/// 注意：此 Dialog 仅在调用方还没有路由到 CallScreen 的短暂窗口内显示。
/// 完整的通话 UI 请参考 call_screen.dart。
class CallDialog extends StatefulWidget {
  final String contactName;
  final String? contactAvatar;
  final bool isVideoCall;
  final VoidCallback onEnd;
  final String? roomId;

  const CallDialog({
    super.key,
    required this.contactName,
    this.contactAvatar,
    required this.isVideoCall,
    required this.onEnd,
    this.roomId,
  });

  @override
  State<CallDialog> createState() => _CallDialogState();
}

class _CallDialogState extends State<CallDialog> {
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isCameraOff = false;
  int _callDuration = 0;
  bool _isConnecting = true;
  String? _callStatusKey;
  Timer? _durationTimer;

  /// 获取底层 WebRTCService 实例（通过 CallManager 单例）。
  /// 返回 null 表示通话尚未初始化，按钮动作应静默忽略。
  WebRTCService? get _webRTCService => CallManager().webRTCService;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  Future<void> _initCall() async {
    debugLog(
      'CallDialog: Initiating ${widget.isVideoCall ? "video" : "voice"} call',
    );
    debugLog('CallDialog: Contact: ${widget.contactName}');
    debugLog('CallDialog: Room ID: ${widget.roomId ?? "N/A"}');

    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _callStatusKey = 'connecting');
    }

    await Future<void>.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _callStatusKey = 'ringing');
    }

    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _isConnecting = false;
        _callStatusKey = 'inCall';
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && !_isConnecting) {
        setState(() => _callDuration++);
      }
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getCallStatusText(BuildContext context) {
    switch (_callStatusKey) {
      case 'connecting':
        return S.of(context)?.chatConnectingCall ?? 'Connecting...';
      case 'ringing':
        return S.of(context)?.chatRinging ?? 'Ringing...';
      case 'inCall':
        return S.of(context)?.chatInCall ?? 'In call';
      default:
        return S.of(context)?.chatCalling ?? 'Calling...';
    }
  }

  void _toggleMute() {
    final service = _webRTCService;
    if (service == null) {
      debugLog('CallDialog: toggleMute skipped — WebRTCService not ready');
      return;
    }
    service.toggleMute();
    setState(() => _isMuted = service.isMuted);
    debugLog('CallDialog: Mute ${_isMuted ? "on" : "off"}');
  }

  Future<void> _toggleSpeaker() async {
    final service = _webRTCService;
    if (service == null) {
      debugLog('CallDialog: toggleSpeaker skipped — WebRTCService not ready');
      return;
    }
    await service.toggleSpeaker();
    if (!mounted) return;
    setState(() => _isSpeakerOn = service.isSpeakerOn);
    debugLog('CallDialog: Speaker ${_isSpeakerOn ? "on" : "off"}');
  }

  void _toggleCamera() {
    final service = _webRTCService;
    if (service == null) {
      debugLog('CallDialog: toggleCamera skipped — WebRTCService not ready');
      return;
    }
    // toggleVideo 控制本地视频轨道的 enabled 状态
    service.toggleVideo();
    setState(() => _isCameraOff = !service.isVideoEnabled);
    debugLog('CallDialog: Camera ${_isCameraOff ? "off" : "on"}');
  }

  Future<void> _endCall() async {
    debugLog('CallDialog: Ending call, duration: $_callDuration seconds');
    _durationTimer?.cancel();
    try {
      // 通过 CallManager 挂断，确保信令发送、通知清除等逻辑统一执行
      await CallManager().hangupCall();
    } catch (e) {
      debugLog('CallDialog: Error during hangup: $e');
    }
    widget.onEnd();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black87,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),

            // 联系人头像
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.3),
                border: Border.all(color: AppColors.primary, width: 3),
              ),
              child: widget.contactAvatar != null
                  ? ClipOval(
                      child: Image.network(
                        widget.contactAvatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildAvatarPlaceholder(),
                      ),
                    )
                  : _buildAvatarPlaceholder(),
            ),

            const SizedBox(height: 24),

            // 联系人名字
            Text(
              widget.contactName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // 通话状态
            Text(
              _isConnecting
                  ? _getCallStatusText(context)
                  : _formatDuration(_callDuration),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
              ),
            ),

            const Spacer(),

            // 控制按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  label: _isMuted
                      ? (S.of(context)?.commonUnmute ?? 'Unmute')
                      : (S.of(context)?.chatMuteCall ?? 'Mute'),
                  isActive: _isMuted,
                  onTap: _toggleMute,
                ),
                _buildControlButton(
                  icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                  label: _isSpeakerOn
                      ? (S.of(context)?.chatSpeakerOff ?? 'Speaker Off')
                      : (S.of(context)?.chatSpeakerOn ?? 'Speaker'),
                  isActive: _isSpeakerOn,
                  // ignore: avoid_void_async — GestureDetector requires VoidCallback;
                  // _toggleSpeaker is async to await platform speaker API
                  onTap: () => _toggleSpeaker(),
                ),
                if (widget.isVideoCall)
                  _buildControlButton(
                    icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                    label: _isCameraOff
                        ? (S.of(context)?.chatCameraOn ?? 'Camera On')
                        : (S.of(context)?.chatCameraOff ?? 'Camera Off'),
                    isActive: _isCameraOff,
                    onTap: _toggleCamera,
                  ),
              ],
            ),

            const SizedBox(height: 40),

            // 挂断按钮
            GestureDetector(
              // ignore: avoid_void_async
              onTap: () => _endCall(),
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              S.of(context)?.chatHangUp ?? 'Hang Up',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Center(
      child: Text(
        widget.contactName.isNotEmpty
            ? widget.contactName[0].toUpperCase()
            : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.black : Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
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
}
