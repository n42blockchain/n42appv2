import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n42_chat/n42_chat.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../prediction/domain/prediction_market.dart';
import '../../prediction/providers/prediction_providers.dart';
import '../../prediction/widgets/create_prediction_sheet.dart';
import '../../prediction/widgets/resolve_prediction_sheet.dart';
import '../../services/live_bootstrap.dart';
import '../../services/live_chat_service.dart';
import '../../services/live_video_service.dart';
import '../widgets/danmu_overlay.dart';
import '../widgets/live_player_view.dart';

/// 开播端：申请摄像头/麦克风权限 → 创建 Matrix 直播间 → 以主播身份发布
/// 摄像头 + 麦克风。主播同屏可见观众弹幕与在线人数；roomId 可分享给观众。
class GoLivePage extends StatefulWidget {
  const GoLivePage({super.key});

  @override
  State<GoLivePage> createState() => _GoLivePageState();
}

class _GoLivePageState extends State<GoLivePage> {
  final LiveVideoService _video = LiveVideoService();
  final LiveChatService _chat = LiveChatService();
  Stream<List<LiveDanmu>>? _danmu;

  bool _starting = false;
  bool _live = false;
  String? _roomId;
  String? _error;

  Future<void> _startLive() async {
    if (_starting) return;
    setState(() {
      _starting = true;
      _error = null;
    });
    try {
      // 1. 权限
      final statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();
      final granted = statuses.values.every((s) => s.isGranted);
      if (!granted) {
        throw StateError('需要摄像头与麦克风权限才能开播');
      }

      // 2. 登录 + 创建直播间（Matrix room）
      await ensureLiveChatReady();
      await ensureAnonymousLogin();
      final roomId = await N42Chat.createGroup(
        name: '直播 ${DateTime.now().toIso8601String()}',
      );

      // 3. 弹幕 + 以主播身份发布
      await _chat.join(roomId);
      _danmu = _chat.watchDanmu(roomId);
      await _video.joinAsBroadcaster(roomId);

      if (mounted) {
        setState(() {
          _live = true;
          _roomId = roomId;
          _starting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _starting = false;
          _error = '$e';
        });
      }
    }
  }

  Future<void> _endLive() async {
    await _video.leave();
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    _video.leave();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _live ? _buildLiveView() : _buildPrepareView(),
    );
  }

  Widget _buildPrepareView() {
    return SafeArea(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.videocam, color: Colors.white70, size: 64),
                const SizedBox(height: 24),
                if (_error != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                FilledButton.icon(
                  onPressed: _starting ? null : _startLive,
                  icon: _starting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.fiber_manual_record),
                  label: Text(_starting ? '开播中…' : '开始直播'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 本地摄像头预览
        LivePlayerView(videoService: _video, showLocal: true),

        // 顶部：roomId（可分享）+ 在线人数 + 结束
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(child: _RoomIdChip(roomId: _roomId ?? '')),
                if (_video.listenable != null)
                  ListenableBuilder(
                    listenable: _video.listenable!,
                    builder: (context, _) =>
                        _OnlineBadge(count: _video.participantCount),
                  ),
                IconButton(
                  icon: const Icon(Icons.stop_circle, color: Colors.redAccent),
                  onPressed: _endLive,
                ),
              ],
            ),
          ),
        ),

        // 弹幕层（主播可见观众评论）
        if (_danmu != null)
          Positioned(
            left: 12,
            right: 0,
            bottom: 96,
            child: DanmuOverlay(stream: _danmu!),
          ),

        // 开预测 / 开奖
        if (_roomId != null)
          Positioned(
            left: 12,
            bottom: 24,
            child: _BroadcasterPredictionButton(roomId: _roomId!),
          ),

        // 主播控制：切换摄像头 / 麦克风
        Positioned(
          right: 12,
          bottom: 24,
          child: Column(
            children: [
              _CircleButton(
                icon: Icons.cameraswitch,
                onTap: _video.switchCamera,
              ),
              const SizedBox(height: 16),
              ListenableBuilder(
                listenable: _video.listenable ?? const _NullListenable(),
                builder: (context, _) => _CircleButton(
                  icon: _video.isMuted ? Icons.mic_off : Icons.mic,
                  onTap: _video.toggleMicrophone,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoomIdChip extends StatelessWidget {
  const _RoomIdChip({required this.roomId});
  final String roomId;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: roomId));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('已复制房间号')));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.copy, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                roomId,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnlineBadge extends StatelessWidget {
  const _OnlineBadge({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.remove_red_eye, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            '$count',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

/// 空 [Listenable]，service 未就绪时占位。
class _NullListenable extends Listenable {
  const _NullListenable();
  @override
  void addListener(VoidCallback listener) {}
  @override
  void removeListener(VoidCallback listener) {}
}

/// 主播预测控制：无活跃市场→开预测；有进行中/待开奖市场→开奖管理。
class _BroadcasterPredictionButton extends ConsumerWidget {
  const _BroadcasterPredictionButton({required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markets =
        ref.watch(roomMarketsProvider(roomId)).asData?.value ??
        const <PredictionMarket>[];
    PredictionMarket? active;
    for (final m in markets) {
      if (m.status == MarketStatus.open || m.status == MarketStatus.closed) {
        active = m; // 列表按时间倒序，取最近的活跃市场
        break;
      }
    }
    final hasActive = active != null;
    return FilledButton.icon(
      style: FilledButton.styleFrom(backgroundColor: Colors.black54),
      onPressed: () {
        if (hasActive) {
          ResolvePredictionSheet.show(context, marketId: active!.id);
        } else {
          CreatePredictionSheet.show(context, roomId: roomId);
        }
      },
      icon: Icon(hasActive ? Icons.gavel : Icons.add_chart),
      label: Text(hasActive ? '开奖' : '开预测'),
    );
  }
}
