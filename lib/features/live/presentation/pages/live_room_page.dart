import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../prediction/widgets/prediction_card.dart';
import '../../services/live_chat_service.dart';
import '../../services/live_video_service.dart';
import '../widgets/danmu_input_bar.dart';
import '../widgets/danmu_overlay.dart';
import '../widgets/enter_room_banner.dart';
import '../widgets/like_burst.dart';
import '../widgets/live_player_view.dart';
import '../widgets/live_side_actions.dart';
import '../widgets/live_top_bar.dart';

/// 观看端直播间（全屏竖屏）。主播视频铺底 + 顶部栏 + 右侧操作 + 透明弹幕 + 输入框。
class LiveRoomPage extends StatefulWidget {
  const LiveRoomPage({super.key, required this.roomId});

  /// Matrix room id；同时用于推导 LiveKit 房间名（`buildLiveKitRoomName`）。
  final String roomId;

  @override
  State<LiveRoomPage> createState() => _LiveRoomPageState();
}

class _LiveRoomPageState extends State<LiveRoomPage> {
  final LiveVideoService _video = LiveVideoService();
  final LiveChatService _chat = LiveChatService();
  final LikeBurstController _likes = LikeBurstController();
  Stream<List<LiveDanmu>>? _danmu;
  Stream<String>? _enter;
  bool _joining = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _join();
  }

  Future<void> _join() async {
    final chatFuture = _joinChat();
    try {
      await _video.joinAsViewer(widget.roomId);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
    await chatFuture;
    if (mounted) setState(() => _joining = false);
  }

  Future<void> _joinChat() async {
    try {
      await _chat.join(widget.roomId);
      _danmu = _chat.watchDanmu(widget.roomId);
      _enter = _chat.watchEnter(widget.roomId);
    } catch (_) {
      // 弹幕不可用时仍展示视频。
    }
  }

  @override
  void dispose() {
    _likes.dispose();
    _video.leave();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 视频层（双击点赞）
          GestureDetector(onDoubleTap: _likes.burst, child: _buildVideoLayer()),

          // 点赞飘心层
          LikeBurstLayer(controller: _likes),

          // 顶部栏
          if (_video.listenable != null)
            ListenableBuilder(
              listenable: _video.listenable!,
              builder: (context, _) => LiveTopBar(
                title: widget.roomId,
                onlineCount: _video.participantCount,
                onClose: () => context.pop(),
              ),
            )
          else
            LiveTopBar(
              title: widget.roomId,
              onlineCount: 0,
              onClose: () => context.pop(),
            ),

          // 进场横幅
          if (_enter != null)
            Positioned(
              top: 60,
              left: 12,
              child: EnterRoomBanner(enterStream: _enter!),
            ),

          // 预测市场卡片
          Positioned(
            top: 100,
            left: 8,
            right: 8,
            child: PredictionCard(roomId: widget.roomId),
          ),

          // 右侧操作栏
          Positioned(
            right: 12,
            bottom: 180,
            child: LiveSideActions(onLike: _likes.burst),
          ),

          // 底部：弹幕层 + 输入框（随键盘上移）
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_danmu != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 4),
                      child: DanmuOverlay(stream: _danmu!),
                    ),
                  DanmuInputBar(
                    onSend: (text) => _chat.send(widget.roomId, text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoLayer() {
    if (_error != null) return _ErrorView(message: _error!);
    if (_joining) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return LivePlayerView(videoService: _video);
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            '进入直播间失败\n$message',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54),
          ),
        ),
      ),
    );
  }
}
