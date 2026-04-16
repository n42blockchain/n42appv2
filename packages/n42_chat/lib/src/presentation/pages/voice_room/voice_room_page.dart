import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../domain/entities/voice_room_entity.dart';
import '../../blocs/voice_room/voice_room_bloc.dart';
import '../../blocs/voice_room/voice_room_event.dart';
import '../../blocs/voice_room/voice_room_state.dart';
import '../../widgets/voice_room/participant_grid.dart';

/// 语音房间内页面
///
/// 布局：
/// [房间名称] [话题] [...按钮]
/// ─── 主持人 ─── (大头像，说话动画)
/// ─── 发言者 ─── (中等头像，2行网格)
/// ─── 听众 ─── (小头像，4列网格)
/// [举手] [静音/取消静音] [离开]
class VoiceRoomPage extends StatelessWidget {
  final String roomId;

  const VoiceRoomPage({
    super.key,
    required this.roomId,
  });

  @override
  Widget build(BuildContext context) {
    return const _VoiceRoomView();
  }
}

class _VoiceRoomView extends StatelessWidget {
  const _VoiceRoomView();

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<VoiceRoomBloc, VoiceRoomState>(
          listenWhen: (previous, current) =>
              previous.isConnected && !current.isConnected,
          listener: (context, state) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        BlocListener<VoiceRoomBloc, VoiceRoomState>(
          listenWhen: (previous, current) =>
              previous.error != current.error &&
              current.error != null &&
              current.error!.isNotEmpty,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          },
        ),
      ],
      child: BlocBuilder<VoiceRoomBloc, VoiceRoomState>(
        builder: (context, state) {
        final room = state.room;

        if (room == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: state.isLoading
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(s?.voiceRoomConnecting ?? 'Connecting...'),
                      ],
                    )
                  : Text(state.error ?? 'Room not found'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: const TextStyle(fontSize: 16),
                ),
                if (room.topic != null)
                  Text(
                    room.topic!,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
            actions: [
              // 直播标识
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      s?.voiceRoomLive ?? 'LIVE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // 参与者网格
              Expanded(
                child: ParticipantGrid(
                  room: room,
                  myRole: state.myRole,
                  onParticipantLongPress: state.isHost
                      ? (participant) =>
                          _showParticipantOptions(context, participant, state)
                      : null,
                ),
              ),

              // 底部控制栏
              _buildControlBar(context, state),
            ],
          ),
        );
        },
      ),
    );
  }

  Widget _buildControlBar(BuildContext context, VoiceRoomState state) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 16 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 举手/放下手（仅听众可见）
          if (state.myRole == VoiceRoomRole.listener)
            _buildControlButton(
              context,
              icon: state.isHandRaised
                  ? Icons.back_hand
                  : Icons.back_hand_outlined,
              label: state.isHandRaised
                  ? (s?.voiceRoomLowerHand ?? 'Lower Hand')
                  : (s?.voiceRoomRaiseHand ?? 'Raise Hand'),
              color: state.isHandRaised ? Colors.orange : null,
              onTap: () {
                final bloc = context.read<VoiceRoomBloc>();
                if (state.isHandRaised) {
                  bloc.add(const LowerHand());
                } else {
                  bloc.add(const RaiseHand());
                }
              },
            ),

          // 静音/取消静音（发言者和主持人可见）
          if (state.canSpeak)
            _buildControlButton(
              context,
              icon: state.isMuted ? Icons.mic_off : Icons.mic,
              label: state.isMuted
                  ? (s?.voiceRoomUnmute ?? 'Unmute')
                  : (s?.voiceRoomMute ?? 'Mute'),
              color: state.isMuted ? Colors.red : theme.colorScheme.primary,
              onTap: () {
                context.read<VoiceRoomBloc>().add(const ToggleMute());
              },
            ),

          // 结束房间（仅主持人可见）
          if (state.isHost)
            _buildControlButton(
              context,
              icon: Icons.cancel_outlined,
              label: s?.voiceRoomEnd ?? 'End Room',
              color: Colors.red,
              onTap: () => _confirmEndRoom(context),
            ),

          // 离开
          _buildControlButton(
            context,
            icon: Icons.exit_to_app,
            label: s?.voiceRoomLeave ?? 'Leave',
            color: Colors.red.shade300,
            onTap: () {
              context.read<VoiceRoomBloc>().add(const LeaveVoiceRoom());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final effectiveColor = color ?? theme.colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: effectiveColor, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: effectiveColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showParticipantOptions(
    BuildContext context,
    VoiceRoomParticipant participant,
    VoiceRoomState state,
  ) {
    final s = S.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: participant.avatarUrl != null
                    ? NetworkImage(participant.avatarUrl!)
                    : null,
              ),
              title: Text(participant.displayName),
              subtitle: Text(participant.role.name),
            ),
            const Divider(),
            if (participant.role == VoiceRoomRole.listener)
              ListTile(
                leading: const Icon(Icons.mic),
                title: Text(s?.voiceRoomApprove ?? 'Approve to speak'),
                onTap: () {
                  context.read<VoiceRoomBloc>().add(
                        ApproveSpeaker(participant.userId),
                      );
                  Navigator.pop(sheetContext);
                },
              ),
            if (participant.role == VoiceRoomRole.speaker)
              ListTile(
                leading: const Icon(Icons.mic_off),
                title: Text(s?.voiceRoomDemote ?? 'Move to listener'),
                onTap: () {
                  context.read<VoiceRoomBloc>().add(
                        DemoteToListener(participant.userId),
                      );
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _confirmEndRoom(BuildContext context) {
    final s = S.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(s?.voiceRoomEnd ?? 'End Room'),
        content: const Text('Are you sure you want to end this voice room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(MaterialLocalizations.of(dialogContext).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () {
              context.read<VoiceRoomBloc>().add(const EndVoiceRoom());
              Navigator.pop(dialogContext);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(s?.voiceRoomEnd ?? 'End Room'),
          ),
        ],
      ),
    );
  }
}
