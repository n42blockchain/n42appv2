import 'package:flutter/material.dart';
import 'package:n42_wallet/generated/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';

import '../../prediction/widgets/prediction_card.dart';
import '../../services/live_chat_service.dart';
import '../../services/live_video_service.dart';
import '../widgets/danmu_input_bar.dart';
import '../widgets/danmu_overlay.dart';
import '../widgets/enter_room_banner.dart';
import '../widgets/gift_overlay.dart';
import '../widgets/gift_picker_sheet.dart';
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
  Stream<LiveEvent>? _gifts;
  bool _joining = true;
  bool _ended = false;
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
    // 死房判定：主播已结束/崩溃失活的房间不让观众空等画面。
    final live = await _chat.isRoomLive(widget.roomId);
    if (mounted) {
      setState(() {
        _ended = !live;
        _joining = false;
      });
    }
  }

  Future<void> _joinChat() async {
    try {
      await _chat.join(widget.roomId);
      _danmu = _chat.watchDanmu(widget.roomId);
      _enter = _chat.watchEnter(widget.roomId);
      _gifts = _chat.watchNewEvents(widget.roomId);
    } catch (_) {
      // 弹幕不可用时仍展示视频。
    }
  }

  /// 打开礼物面板（金币计价）。选中后由经济服务按金币扣费并广播给全房
  /// （含自己，作即时反馈）。
  void _openGiftPicker() {
    GiftPickerSheet.show(context, roomId: widget.roomId);
  }

  /// 显式关闭：先离会、再退出 Matrix 房间，最后返回
  /// （dispose 里的 leave 是异步未 await 的兜底）。
  Future<void> _close() async {
    await _video.leave();
    await _chat.leave(widget.roomId);
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _likes.dispose();
    _video.leave();
    // 观众退房：退出 Matrix room，避免匿名账号永久滞留导致成员数虚高、
    // 死房堆积在直播列表。失败静默（已在 LiveChatService.leave 内吞掉）。
    _chat.leave(widget.roomId);
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

          // 礼物动画层（跨端广播的礼物 emoji 飞行 + "X 送出 Y"提示）
          if (_gifts != null) GiftOverlay(giftStream: _gifts!),

          // 顶部栏
          if (_video.listenable != null)
            ListenableBuilder(
              listenable: _video.listenable!,
              builder: (context, _) => LiveTopBar(
                title: widget.roomId,
                onlineCount: _video.participantCount,
                onClose: () {
                  _close();
                },
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
              left: AppSpacing.space6,
              child: EnterRoomBanner(enterStream: _enter!),
            ),

          // 预测市场卡片
          Positioned(
            top: 100,
            left: AppSpacing.space4,
            right: AppSpacing.space4,
            child: PredictionCard(roomId: widget.roomId),
          ),

          // 右侧操作栏
          Positioned(
            right: AppSpacing.space6,
            bottom: 180,
            child: LiveSideActions(
              onLike: _likes.burst,
              onGift: _openGiftPicker,
            ),
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
                      padding: EdgeInsets.only(
                        left: AppSpacing.space6,
                        bottom: AppSpacing.space2,
                      ),
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
    if (_ended) return const _EndedView();
    return LivePlayerView(videoService: _video);
  }
}

/// 直播已结束（房间失活）时替代"等待画面…"的明确反馈。
class _EndedView extends StatelessWidget {
  const _EndedView();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.videocam_off,
              color: AppColorTokens.onOverlaySecondary,
              size: 48,
            ),
            SizedBox(height: AppSpacing.space6),
            Text(
              S.of(context).g_live_ended,
              style: AppTypography.body.copyWith(
                color: AppColorTokens.onOverlaySecondary,
              ),
            ),
          ],
        ),
      ),
    );
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
          padding: EdgeInsets.all(AppSpacing.space12),
          child: Text(
            S.of(context).g_live_enter_room_failed(message),
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: AppColorTokens.onOverlaySecondary,
            ),
          ),
        ),
      ),
    );
  }
}
