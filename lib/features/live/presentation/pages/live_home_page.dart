import 'package:n42_wallet/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

import '../../services/live_chat_service.dart';

/// 直播广场。提供：① 输入 roomId 进房；② 从 Matrix 公共目录发现正在直播的
/// 公开房间；③ 开始直播。
class LiveHomePage extends StatefulWidget {
  const LiveHomePage({super.key});

  @override
  State<LiveHomePage> createState() => _LiveHomePageState();
}

class _LiveHomePageState extends State<LiveHomePage> {
  final TextEditingController _roomController = TextEditingController();
  final LiveChatService _chat = LiveChatService();
  List<LiveRoomSummary>? _rooms;
  bool _loadingRooms = false;
  String? _roomsError;

  @override
  void dispose() {
    _roomController.dispose();
    super.dispose();
  }

  void _enterRoom(String roomId) {
    final id = roomId.trim();
    if (id.isEmpty) return;
    context.push('/live/room/${Uri.encodeComponent(id)}');
  }

  Future<void> _loadRooms() async {
    setState(() {
      _loadingRooms = true;
      _roomsError = null;
    });
    try {
      final rooms = await _chat.discoverPublicLiveRooms();
      if (mounted) setState(() => _rooms = rooms);
    } catch (e) {
      if (mounted) setState(() => _roomsError = '$e');
    } finally {
      if (mounted) setState(() => _loadingRooms = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 嵌入主 App（从聊天「发现」进入）时关闭返回；独立运行时 maybePop 无副作用。
        leading: IconButton(
          tooltip: S.of(context).g_a11y_close,
          icon: const Icon(Icons.close),
          onPressed: () =>
              Navigator.of(context, rootNavigator: true).maybePop(),
        ),
        title: const Text('N42 Live'),
        actions: [
          IconButton(
            tooltip: S.of(context).g_ui3_live_start,
            icon: const Icon(Icons.videocam),
            onPressed: () => context.push('/live/go'),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(AppSpacing.space8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _roomController,
                    decoration: InputDecoration(
                      labelText: S.of(context).g_ui_room_id,
                      hintText: '!xxxxx:m.si46.world',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: _enterRoom,
                  ),
                ),
                SizedBox(width: AppSpacing.space4),
                FilledButton(
                  onPressed: () => _enterRoom(_roomController.text),
                  child: Text(S.of(context).g_ui3_live_enter),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.space8),
            Row(
              children: [
                Text(
                  S.of(context).g_ui3_live_list,
                  style: AppTypography.headline.copyWith(
                    color: AppColorTokens.of(context).textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _loadingRooms ? null : _loadRooms,
                  icon: _loadingRooms
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: Text(S.of(context).g_key_bridge_refresh),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.space4),
            Expanded(child: _buildRoomList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomList(BuildContext context) {
    if (_roomsError != null) {
      return Center(
        child: Text(
          S.of(context).g_ui3_live_load_failed('$_roomsError'),
          textAlign: TextAlign.center,
          style: AppTypography.bodySm.copyWith(
            color: AppColorTokens.of(context).danger,
          ),
        ),
      );
    }
    if (_rooms == null) {
      return AppEmptyState(
        icon: Icons.live_tv,
        title: S.of(context).g_ui3_live_browse_title,
        message: S.of(context).g_ui3_live_browse_hint,
      );
    }
    final rooms = _rooms!;
    if (rooms.isEmpty) {
      return AppEmptyState(
        icon: Icons.inbox_outlined,
        title: S.of(context).g_ui3_live_empty,
      );
    }
    return ListView.separated(
      itemCount: rooms.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final r = rooms[i];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.live_tv)),
          title: Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(S.of(context).g_ui3_live_viewers(r.memberCount)),
          trailing: const _LiveBadge(),
          onTap: () => _enterRoom(r.id),
        );
      },
    );
  }
}

/// 直播中徽标（红点 + LIVE）。
class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    final danger = AppColorTokens.of(context).danger;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.space4,
        vertical: AppSpacing.space2,
      ),
      decoration: BoxDecoration(
        color: danger.withValues(alpha: 0.15),
        borderRadius: AppRadius.brPill,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: danger, shape: BoxShape.circle),
          ),
          SizedBox(width: AppSpacing.space2),
          Text(
            S.of(context).g_key_badge_live,
            style: AppTypography.captionSm.copyWith(
              color: danger,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
