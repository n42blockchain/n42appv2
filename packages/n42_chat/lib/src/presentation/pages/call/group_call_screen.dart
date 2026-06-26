/// 多人视频会议页面
///
/// 支持多人音视频会议，包含网格布局、屏幕共享、参与者管理等功能
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livekit_client/livekit_client.dart'
    show VideoTrackRenderer, VideoViewFit;
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../services/voip/livekit_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../widgets/chat/in_call_chat_panel.dart';
import '../../widgets/call/call_enhancement_sheet.dart';
import '../../widgets/common/n42_avatar.dart';

/// 多人会议页面
class GroupCallScreen extends StatefulWidget {
  final LiveKitService liveKitService;
  final String roomName;

  const GroupCallScreen({
    super.key,
    required this.liveKitService,
    required this.roomName,
  });

  @override
  State<GroupCallScreen> createState() => _GroupCallScreenState();
}

class _GroupCallScreenState extends State<GroupCallScreen> {
  MeetingState _state = MeetingState.idle;
  List<MeetingParticipant> _participants = [];
  Duration _duration = Duration.zero;

  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isScreenSharing = false;
  bool _showControls = true;
  bool _showParticipantsList = false;

  // 当前焦点参与者（全屏显示）
  MeetingParticipant? _focusedParticipant;

  Timer? _hideControlsTimer;

  late final LiveKitCallEnhancementController _enhancementController;

  // 保存原始回调以在 dispose 时恢复
  void Function(MeetingState)? _previousOnStateChanged;
  void Function(List<MeetingParticipant>)? _previousOnParticipantsChanged;
  void Function(Duration)? _previousOnDurationUpdate;
  void Function(MeetingErrorType, [String?])? _previousOnError;

  @override
  void initState() {
    super.initState();

    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // 保存原始回调
    _previousOnStateChanged = widget.liveKitService.onStateChanged;
    _previousOnParticipantsChanged = widget.liveKitService.onParticipantsChanged;
    _previousOnDurationUpdate = widget.liveKitService.onDurationUpdate;
    _previousOnError = widget.liveKitService.onError;

    // 监听状态
    widget.liveKitService.onStateChanged = _onStateChanged;
    widget.liveKitService.onParticipantsChanged = _onParticipantsChanged;
    widget.liveKitService.onDurationUpdate = _onDurationUpdate;
    widget.liveKitService.onError = _onError;

    _enhancementController = LiveKitCallEnhancementController(
      widget.liveKitService,
    );

    _state = widget.liveKitService.state;
    _participants = widget.liveKitService.participants;
    _syncControlsFromService();

    _startHideControlsTimer();
  }

  @override
  void dispose() {
    // 恢复原始回调而非置 null
    widget.liveKitService.onStateChanged = _previousOnStateChanged;
    widget.liveKitService.onParticipantsChanged = _previousOnParticipantsChanged;
    widget.liveKitService.onDurationUpdate = _previousOnDurationUpdate;
    widget.liveKitService.onError = _previousOnError;
    _hideControlsTimer?.cancel();
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _onStateChanged(MeetingState state) {
    if (!mounted) return;
    setState(() {
      _state = state;
      _syncControlsFromService();
    });

    if (state == MeetingState.disconnected || state == MeetingState.failed) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  void _onParticipantsChanged(List<MeetingParticipant> participants) {
    if (!mounted) return;
    setState(() {
      _participants = participants;
    });
  }

  void _onDurationUpdate(Duration duration) {
    if (!mounted) return;
    setState(() {
      _duration = duration;
    });
  }

  void _onError(MeetingErrorType type, [String? details]) {
    if (mounted) {
      final s = S.of(context);
      final errorDetails = details ?? '';
      String message;
      switch (type) {
        case MeetingErrorType.serverNotConfigured:
          message = s?.callLivekitNotConfigured ?? 'LiveKit not configured';
        case MeetingErrorType.joinFailed:
          message =
              s?.callJoinMeetingFailed(errorDetails) ??
              'Failed to join meeting';
        case MeetingErrorType.screenShareFailed:
          message =
              s?.callScreenShareFailed(errorDetails) ?? 'Screen share failed';
        case MeetingErrorType.connectionLost:
          message = s?.commonConnectionFailed ?? 'Connection failed';
        case MeetingErrorType.unknown:
          message = details ?? (s?.qrcodeUnknownError ?? 'Unknown error');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.error),
      );
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _state == MeetingState.connected) {
        setState(() {
          _showControls = false;
        });
      }
    });
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
    _isMuted = widget.liveKitService.isMuted;
    _isVideoEnabled = widget.liveKitService.isVideoEnabled;
    _isScreenSharing = widget.liveKitService.isScreenSharing;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // 参与者视频网格
            _buildVideoGrid(),

            // 屏幕共享覆盖层
            if (_hasScreenShare) _buildScreenShareOverlay(),

            // 顶部栏
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: _buildTopBar(),
            ),

            // 底部控制栏
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: _buildBottomBar(),
            ),

            // 参与者列表
            if (_showParticipantsList) _buildParticipantsList(),

            // 连接中状态
            if (_state == MeetingState.connecting) _buildConnectingOverlay(),
          ],
        ),
      ),
    );
  }

  bool get _hasScreenShare {
    return _participants.any((p) => p.isScreenSharing);
  }

  Widget _buildVideoGrid() {
    final visibleParticipants = List<MeetingParticipant>.from(_participants);

    if (visibleParticipants.isEmpty) {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: Text(
            S.of(context)?.callWaitingForParticipants ??
                'Waiting for participants to join...',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white54, fontSize: 16, height: 1.4),
          ),
        ),
      );
    }

    // 焦点模式：一个大视频 + 小视频条
    final focusedParticipant =
        _focusedParticipant != null &&
            visibleParticipants.any((p) => p.id == _focusedParticipant!.id)
        ? _focusedParticipant
        : null;
    if (focusedParticipant != null) {
      return _buildFocusedLayout(visibleParticipants, focusedParticipant);
    }

    // 网格布局
    final crossAxisCount = _getGridColumns(visibleParticipants.length);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 16 / 9,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: visibleParticipants.length,
      itemBuilder: (context, index) {
        return _buildParticipantTile(visibleParticipants[index]);
      },
    );
  }

  Widget _buildFocusedLayout(
    List<MeetingParticipant> participants,
    MeetingParticipant focusedParticipant,
  ) {
    final others = participants
        .where((p) => p.id != focusedParticipant.id)
        .toList();

    return Column(
      children: [
        // 焦点视频
        Expanded(
          child: GestureDetector(
            onDoubleTap: () {
              setState(() {
                _focusedParticipant = null;
              });
            },
            child: _buildParticipantTile(focusedParticipant, showName: true),
          ),
        ),

        // 其他参与者横向列表
        if (others.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: others.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 160,
                  child: _buildParticipantTile(others[index], compact: true),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildParticipantTile(
    MeetingParticipant participant, {
    bool showName = true,
    bool compact = false,
  }) {
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          _focusedParticipant = participant;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          border: participant.isSpeaking
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            // 视频
            if (participant.isVideoEnabled && participant.videoTrack != null)
              Positioned.fill(
                child: VideoTrackRenderer(
                  participant.videoTrack!,
                  fit: VideoViewFit.cover,
                ),
              )
            else
              // 无视频时显示头像
              Positioned.fill(
                child: Container(
                  color: Colors.grey[850],
                  child: Center(
                    child: N42Avatar(
                      name: participant.name,
                      imageUrl: participant.avatarUrl,
                      size: compact ? 40 : 80,
                      borderRadius: compact ? 20 : 40,
                    ),
                  ),
                ),
              ),

            // 名称和状态
            if (showName)
              Positioned(
                left: 8,
                bottom: 8,
                right: 8,
                child: Row(
                  children: [
                    // 静音图标
                    if (participant.isMuted)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.mic_off,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),

                    const SizedBox(width: 4),

                    // 名称
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          participant.isLocal
                              ? (S
                                        .of(context)
                                        ?.callParticipantMe(participant.name) ??
                                    '${participant.name} (Me)')
                              : participant.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 屏幕共享标识
            if (participant.isScreenSharing)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.screen_share,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        S.of(context)?.callSharingLabel ?? 'Sharing',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenShareOverlay() {
    final sharer = _participants.firstWhere(
      (p) => p.isScreenSharing,
      orElse: () => _participants.first,
    );

    return Positioned.fill(
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // 屏幕共享内容
            if (sharer.screenTrack != null)
              Positioned.fill(
                child: VideoTrackRenderer(
                  sharer.screenTrack!,
                  fit: VideoViewFit.contain,
                ),
              ),

            // 共享者信息
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.screen_share,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        S.of(context)?.callScreenSharingBy(sharer.name) ??
                            '${sharer.name} is sharing screen',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 小视频窗口（右下角）
            Positioned(
              bottom: 120,
              right: 16,
              child: SizedBox(
                width: 120,
                height: 80,
                child: _buildParticipantTile(sharer, compact: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          bottom: 8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
          ),
        ),
        child: Row(
          children: [
            // 返回按钮
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => _showLeaveDialog(),
            ),

            // 房间信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.roomName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          S
                                  .of(context)
                                  ?.callParticipantCount(_participants.length) ??
                              '${_participants.length} participants',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDuration(_duration),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                          height: 1.3,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 切换布局
            IconButton(
              icon: Icon(
                _focusedParticipant != null
                    ? Icons.grid_view
                    : Icons.fullscreen,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  if (_focusedParticipant != null) {
                    _focusedParticipant = null;
                  } else if (_participants.isNotEmpty) {
                    _focusedParticipant = _participants.first;
                  }
                });
              },
            ),

            if (_state == MeetingState.connected)
              IconButton(
                icon: const Icon(Icons.tune, color: Colors.white),
                onPressed: _openCallEnhancementTools,
              ),

            // 参与者列表
            IconButton(
              icon: const Icon(Icons.people, color: Colors.white),
              onPressed: () {
                setState(() {
                  _showParticipantsList = !_showParticipantsList;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 静音
            _buildControlButton(
              icon: _isMuted ? Icons.mic_off : Icons.mic,
              label: _isMuted
                  ? (S.of(context)?.callUnmuteLabel ?? 'Unmute')
                  : (S.of(context)?.callMuteLabel ?? 'Mute'),
              isActive: _isMuted,
              activeColor: AppColors.error,
              onPressed: _toggleMute,
            ),

            // 视频
            _buildControlButton(
              icon: _isVideoEnabled ? Icons.videocam : Icons.videocam_off,
              label: _isVideoEnabled
                  ? (S.of(context)?.callTurnOffVideo ?? 'Turn off video')
                  : (S.of(context)?.callTurnOnVideo ?? 'Turn on video'),
              isActive: !_isVideoEnabled,
              activeColor: AppColors.error,
              onPressed: _toggleVideo,
            ),

            // 屏幕共享
            _buildControlButton(
              icon: Icons.screen_share,
              label: _isScreenSharing
                  ? (S.of(context)?.callStopSharing ?? 'Stop sharing')
                  : (S.of(context)?.callShareScreen ?? 'Share screen'),
              isActive: _isScreenSharing,
              activeColor: AppColors.primary,
              onPressed: _toggleScreenShare,
            ),

            // 通话中聊天
            _buildControlButton(
              icon: Icons.chat_bubble_outline,
              label: S.of(context)?.callChatLabel ?? 'Chat',
              onPressed: _openInCallChat,
            ),

            // 切换摄像头
            _buildControlButton(
              icon: Icons.cameraswitch,
              label: S.of(context)?.callSwitchCameraLabel ?? 'Switch',
              onPressed: _switchCamera,
            ),

            // 离开
            _buildControlButton(
              icon: Icons.call_end,
              label: S.of(context)?.callLeaveLabel ?? 'Leave',
              backgroundColor: AppColors.error,
              onPressed: _showLeaveDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    bool isActive = false,
    Color? activeColor,
    Color? backgroundColor,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  backgroundColor ??
                  (isActive
                      ? (activeColor ?? Colors.white)
                      : Colors.white.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 11,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsList() {
    return Positioned(
      right: 0,
      top: 0,
      bottom: 0,
      child: Container(
        width: 280,
        color: Colors.black.withValues(alpha: 0.9),
        child: Column(
          children: [
            // 标题栏
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    S.of(context)?.callParticipantsLabel ?? 'Participants',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_participants.length}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(AppIcons.close, color: Colors.white, size: 22),
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                    onPressed: () {
                      setState(() {
                        _showParticipantsList = false;
                      });
                    },
                  ),
                ],
              ),
            ),

            // 参与者列表
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _participants.length,
                itemBuilder: (context, index) {
                  final participant = _participants[index];
                  return _buildParticipantListItem(participant);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantListItem(MeetingParticipant participant) {
    return ListTile(
      leading: N42Avatar(
        name: participant.name,
        imageUrl: participant.avatarUrl,
        size: 40,
        borderRadius: 20,
      ),
      title: Text(
        participant.isLocal
            ? (S.of(context)?.callParticipantMe(participant.name) ??
                  '${participant.name} (Me)')
            : participant.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (participant.isMuted)
            const Icon(Icons.mic_off, color: AppColors.error, size: 18),
          if (!participant.isVideoEnabled)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.videocam_off, color: AppColors.error, size: 18),
            ),
          if (participant.isScreenSharing)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.screen_share,
                color: AppColors.primary,
                size: 18,
              ),
            ),
        ],
      ),
      onTap: () {
        setState(() {
          _focusedParticipant = participant;
          _showParticipantsList = false;
        });
      },
    );
  }

  Widget _buildConnectingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.8),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 24),
              Text(
                S.of(context)?.callJoiningMeeting ?? 'Joining meeting...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getGridColumns(int count) {
    if (count <= 1) return 1;
    if (count <= 4) return 2;
    if (count <= 9) return 3;
    return 4;
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

  void _toggleMute() async {
    await widget.liveKitService.toggleMicrophone();
    if (!mounted) return;
    setState(() {
      _syncControlsFromService();
    });
  }

  void _toggleVideo() async {
    await widget.liveKitService.toggleCamera();
    if (!mounted) return;
    setState(() {
      _syncControlsFromService();
    });
  }

  void _toggleScreenShare() async {
    await widget.liveKitService.toggleScreenShare();
    if (!mounted) return;
    setState(() {
      _syncControlsFromService();
    });
  }

  void _openInCallChat() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InCallChatPanel(liveKitService: widget.liveKitService),
    );
  }

  void _switchCamera() {
    widget.liveKitService.switchCamera();
  }

  Future<void> _openCallEnhancementTools() async {
    await showCallEnhancementSheet(
      context: context,
      controller: _enhancementController,
      title: 'Meeting tools',
      onChanged: () {
        if (!mounted) return;
        setState(() {
          _syncControlsFromService();
        });
      },
    );
  }

  void _showLeaveDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context)?.callLeaveMeeting ?? 'Leave Meeting'),
        content: Text(
          S.of(context)?.callLeaveMeetingConfirm ??
              'Are you sure you want to leave the meeting?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(S.of(context)?.commonCancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _leaveMeeting();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(S.of(context)?.callLeaveLabel ?? 'Leave'),
          ),
        ],
      ),
    );
  }

  void _leaveMeeting() {
    widget.liveKitService.leaveMeeting();
    Navigator.of(context).pop();
  }
}
