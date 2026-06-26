import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../domain/entities/voice_room_entity.dart';
import 'speaking_avatar.dart';

/// 按角色分区的参与者网格
class ParticipantGrid extends StatelessWidget {
  final VoiceRoomEntity room;
  final VoiceRoomRole myRole;
  final void Function(VoiceRoomParticipant participant)? onParticipantTap;
  final void Function(VoiceRoomParticipant participant)? onParticipantLongPress;

  const ParticipantGrid({
    super.key,
    required this.room,
    this.myRole = VoiceRoomRole.listener,
    this.onParticipantTap,
    this.onParticipantLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 主持人区
          if (room.hosts.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              s?.voiceRoomHost ?? 'Host',
              theme,
            ),
            _buildGrid(
              context,
              room.hosts,
              crossAxisCount: 3,
              avatarRadius: 32,
            ),
            const SizedBox(height: 16),
          ],

          // 发言者区
          if (room.speakers.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              s?.voiceRoomSpeakers ?? 'Speakers',
              theme,
            ),
            _buildGrid(
              context,
              room.speakers,
              crossAxisCount: 3,
              avatarRadius: 28,
            ),
            const SizedBox(height: 16),
          ],

          // 听众区
          if (room.listeners.isNotEmpty) ...[
            _buildSectionHeader(
              context,
              '${s?.voiceRoomListeners ?? 'Listeners'} (${room.listeners.length})',
              theme,
            ),
            _buildGrid(
              context,
              room.listeners,
              crossAxisCount: 4,
              avatarRadius: 22,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildGrid(
    BuildContext context,
    List<VoiceRoomParticipant> participants, {
    required int crossAxisCount,
    required double avatarRadius,
  }) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: participants.map((participant) {
        return SpeakingAvatar(
          participant: participant,
          radius: avatarRadius,
          onTap: onParticipantTap != null
              ? () => onParticipantTap!(participant)
              : null,
          onLongPress: onParticipantLongPress != null
              ? () => onParticipantLongPress!(participant)
              : null,
        );
      }).toList(),
    );
  }
}
