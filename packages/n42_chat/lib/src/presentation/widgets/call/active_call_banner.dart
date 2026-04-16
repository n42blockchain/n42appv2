import 'package:flutter/material.dart';

import '../../../domain/entities/video_room_entity.dart';
import '../../../n42_chat.dart';

/// 活动通话 banner：
///
/// 监听 [CallManager.activeRoomStream]，当存在活动群语音 / 视频通话时显示一条
/// 横向条目，点击可重新进入通话屏幕。
///
/// 使用方式：在 [Scaffold] 的 `body` 顶部或会话列表头部放入该 widget 即可。
class ActiveCallBanner extends StatelessWidget {
  const ActiveCallBanner({
    super.key,
    this.onlyForConversationId,
    this.onTap,
  });

  /// 如果指定，则只在当前活动通话属于该会话时显示（用于群聊头部）。
  final String? onlyForConversationId;

  /// 点击回调；默认无，调用方可自己处理（例如重新调起 group call 屏幕）。
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final manager = N42Chat.callManager;
    if (manager == null) return const SizedBox.shrink();

    return StreamBuilder<VideoRoomEntity?>(
      stream: manager.activeRoomStream,
      initialData: manager.currentActiveRoom,
      builder: (context, snapshot) {
        final room = snapshot.data;
        if (room == null || !room.isActive) return const SizedBox.shrink();
        if (onlyForConversationId != null &&
            room.conversationId != onlyForConversationId) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final icon = room.hasVideo ? Icons.videocam : Icons.call;
        return Material(
          color: theme.colorScheme.primaryContainer,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${room.displayName} · ${room.participantCount} 人正在通话',
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '返回',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
