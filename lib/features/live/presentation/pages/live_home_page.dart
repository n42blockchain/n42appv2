import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/live_chat_service.dart';

/// 直播广场。提供：① 输入 roomId 进房；② 加载直播列表（已加入的房间）；
/// ③ 开始直播。完整目录后端见 task#6。
class LiveHomePage extends StatefulWidget {
  const LiveHomePage({super.key});

  @override
  State<LiveHomePage> createState() => _LiveHomePageState();
}

class _LiveHomePageState extends State<LiveHomePage> {
  final TextEditingController _roomController = TextEditingController();
  final LiveChatService _chat = LiveChatService();
  Stream<List<LiveRoomSummary>>? _rooms;
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
      final stream = await _chat.watchRooms();
      if (mounted) setState(() => _rooms = stream);
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
        title: const Text('N42 Live'),
        actions: [
          IconButton(
            tooltip: '开始直播',
            icon: const Icon(Icons.videocam),
            onPressed: () => context.push('/live/go'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _roomController,
                    decoration: const InputDecoration(
                      labelText: 'Room ID',
                      hintText: '!xxxxx:m.si46.world',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: _enterRoom,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _enterRoom(_roomController.text),
                  child: const Text('进入'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('直播列表', style: TextStyle(fontSize: 16)),
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
                  label: const Text('加载'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildRoomList()),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomList() {
    if (_roomsError != null) {
      return Center(
        child: Text(
          '加载失败：$_roomsError',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.redAccent),
        ),
      );
    }
    if (_rooms == null) {
      return const Center(child: Text('点击"加载"查看直播间'));
    }
    return StreamBuilder<List<LiveRoomSummary>>(
      stream: _rooms,
      builder: (context, snapshot) {
        final rooms = snapshot.data ?? const <LiveRoomSummary>[];
        if (rooms.isEmpty) {
          return const Center(child: Text('暂无直播间'));
        }
        return ListView.separated(
          itemCount: rooms.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final r = rooms[i];
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.live_tv)),
              title: Text(r.name, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${r.memberCount} 人'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _enterRoom(r.id),
            );
          },
        );
      },
    );
  }
}
