import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:n42_chat/n42_chat.dart';
import 'package:n42_wallet/core/design_system/design_system.dart';
import 'package:n42_wallet/features/live/presentation/widgets/online_badge.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../prediction/domain/prediction_market.dart';
import '../../prediction/providers/prediction_providers.dart';
import '../../prediction/widgets/create_prediction_sheet.dart';
import '../../prediction/widgets/resolve_prediction_sheet.dart';
import '../../services/live_bootstrap.dart';
import '../../services/live_chat_service.dart';
import '../../services/live_video_service.dart';
import '../widgets/danmu_overlay.dart';
import '../widgets/gift_overlay.dart';
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
  Stream<LiveEvent>? _gifts;
  Timer? _heartbeat;

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

      // 3. 弹幕 + 以主播身份发布。任一步失败则回滚（离开刚建的房间），
      //    否则每次重试都会新建 Matrix room，遗留一堆空直播间。
      try {
        await _chat.join(roomId);
        _danmu = _chat.watchDanmu(roomId);
        _gifts = _chat.watchNewEvents(roomId);
        await _video.joinAsBroadcaster(roomId);
      } catch (_) {
        await _chat.leave(roomId);
        rethrow;
      }

      // 发布成功后开始上报直播心跳：立即一拍 + 周期刷新房间 topic 时间戳，
      // 使本房在直播列表判活；停播/崩溃后心跳停止，liveTtl 内自动失活。
      _startHeartbeat(roomId);

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

  /// 开始/刷新直播心跳。立即上报一拍，之后每 [LiveChatService.heartbeatInterval]
  /// 刷新一次房间 topic 时间戳。
  void _startHeartbeat(String roomId) {
    _heartbeat?.cancel();
    unawaited(_chat.markLive(roomId));
    _heartbeat = Timer.periodic(
      LiveChatService.heartbeatInterval,
      (_) => unawaited(_chat.markLive(roomId)),
    );
  }

  Future<void> _endLive() async {
    final roomId = _roomId;
    _heartbeat?.cancel();
    _heartbeat = null;
    await _video.leave();
    if (roomId != null) {
      // 标记直播结束使房间立即从列表失活，并退出 Matrix room 清理成员占用。
      await _chat.markEnded(roomId);
      await _chat.leave(roomId);
    }
    if (mounted) context.pop();
  }

  @override
  void dispose() {
    // 页面被直接销毁（未走 _endLive，如系统返回）时的兜底：停止心跳并失活房间。
    _heartbeat?.cancel();
    final roomId = _roomId;
    _video.leave();
    if (roomId != null) {
      _chat.markEnded(roomId);
      _chat.leave(roomId);
    }
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
              icon: const Icon(
                Icons.close,
                color: AppColorTokens.onOverlayPrimary,
              ),
              onPressed: () => context.pop(),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.videocam,
                  color: AppColorTokens.onOverlaySecondary,
                  size: 64,
                ),
                SizedBox(height: AppSpacing.space12),
                if (_error != null) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.space12,
                    ),
                    child: Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: AppColorTokens.dangerOnOverlay,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.space8),
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

        // 礼物动画层（观众送出的礼物，主播同屏可见）
        if (_gifts != null) GiftOverlay(giftStream: _gifts!),

        // 顶部：roomId（可分享）+ 在线人数 + 结束
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.space4,
              vertical: AppSpacing.space2,
            ),
            child: Row(
              children: [
                Expanded(child: _RoomIdChip(roomId: _roomId ?? '')),
                if (_video.listenable != null)
                  ListenableBuilder(
                    listenable: _video.listenable!,
                    builder: (context, _) =>
                        OnlineBadge(
                          count: _video.participantCount,
                          margin: EdgeInsets.symmetric(
                            horizontal: AppSpacing.space4,
                          ),
                        ),
                  ),
                IconButton(
                  icon: const Icon(
                    Icons.stop_circle,
                    color: AppColorTokens.dangerOnOverlay,
                  ),
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
    return Material(
      color: AppColorTokens.overlay,
      borderRadius: AppRadius.brLg,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: roomId));
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('已复制房间号')));
        },
        child: ConstrainedBox(
          // 抬高到可用触控高度（原 ≈26dp < 44dp）。
          constraints: const BoxConstraints(minHeight: 44),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.space4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.copy,
                  color: AppColorTokens.onOverlaySecondary,
                  size: 14,
                ),
                SizedBox(width: AppSpacing.space2),
                Flexible(
                  child: Text(
                    roomId,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.caption.copyWith(
                      color: AppColorTokens.onOverlayPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
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
          color: AppColorTokens.overlay,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColorTokens.onOverlayPrimary),
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
      style: FilledButton.styleFrom(
        backgroundColor: AppColorTokens.overlay,
        foregroundColor: AppColorTokens.onOverlayPrimary,
      ),
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
