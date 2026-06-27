import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/matrix_utils.dart' as mx_utils;
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../domain/entities/moment_entity.dart';
import '../../../domain/repositories/moment_repository.dart';

/// 短视频沉浸式 Feed（TikTok 风格竖向 PageView）
///
/// 取动态中含视频的条目，逐页全屏播放：当前页自动播放并循环，
/// 滑走自动暂停；点屏暂停/播放；右侧点赞/评论计数，底部作者+文案。
class VideoFeedPage extends StatefulWidget {
  const VideoFeedPage({super.key});

  @override
  State<VideoFeedPage> createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  final PageController _pageController = PageController();
  List<MomentEntity> _videos = const [];
  bool _loading = true;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final moments =
          await getIt<IMomentRepository>().getMoments(limit: 50);
      final vids = moments.where((m) => m.hasVideo && !m.isDeleted).toList();
      if (mounted) {
        setState(() {
          _videos = vids;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleLike(int index) async {
    final m = _videos[index];
    final liked = m.isLikedByMe;
    // 乐观更新
    setState(() {
      final likes = List<MomentLike>.from(m.likes);
      if (liked) {
        if (likes.isNotEmpty) likes.removeLast();
      } else {
        likes.add(MomentLike(
          userId: 'me',
          userName: 'Me',
          timestamp: DateTime.now(),
        ));
      }
      _videos[index] = m.copyWith(likes: likes, isLikedByMe: !liked);
    });
    try {
      final repo = getIt<IMomentRepository>();
      if (liked) {
        await repo.unlikeMoment(m.id);
      } else {
        await repo.likeMoment(m.id);
      }
    } catch (_) {
      // 失败回滚
      if (mounted) setState(() => _videos[index] = m);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white))
          : _videos.isEmpty
              ? _buildEmpty()
              : Stack(
                  children: [
                    PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      itemCount: _videos.length,
                      onPageChanged: (i) => setState(() => _current = i),
                      itemBuilder: (ctx, i) => _VideoFeedItem(
                        moment: _videos[i],
                        isActive: i == _current,
                        onLike: () => _toggleLike(i),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmpty() {
    return Stack(
      children: [
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.video_collection_outlined,
                  size: 56, color: Colors.white38),
              SizedBox(height: 12),
              Text('No videos yet',
                  style: TextStyle(color: Colors.white54, fontSize: 15)),
            ],
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ],
    );
  }
}

/// 单个短视频页
class _VideoFeedItem extends StatefulWidget {
  final MomentEntity moment;
  final bool isActive;
  final VoidCallback onLike;

  const _VideoFeedItem({
    required this.moment,
    required this.isActive,
    required this.onLike,
  });

  @override
  State<_VideoFeedItem> createState() => _VideoFeedItemState();
}

class _VideoFeedItemState extends State<_VideoFeedItem> {
  VideoPlayerController? _vc;
  bool _initialized = false;
  bool _userPaused = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(covariant _VideoFeedItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) _applyActive();
  }

  @override
  void dispose() {
    _vc?.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final video = widget.moment.media.firstWhere(
      (m) => m.isVideo,
      orElse: () => widget.moment.media.first,
    );
    final client = MatrixClientManager.instance.client;
    final url = video.httpUrl ??
        mx_utils.MatrixUtils.getMediaDownloadUrl(video.url, client: client);
    if (url == null || url.isEmpty) return;
    final headers =
        mx_utils.MatrixUtils.buildAuthenticatedMediaHeaders(url, client: client);
    final vc = VideoPlayerController.networkUrl(
      Uri.parse(url),
      httpHeaders: headers,
    );
    _vc = vc;
    unawaited(vc.setLooping(true));
    try {
      await vc.initialize();
      if (!mounted) {
        unawaited(vc.dispose());
        return;
      }
      setState(() => _initialized = true);
      if (widget.isActive) unawaited(vc.play());
    } catch (_) {
      // 初始化失败：保留占位
    }
  }

  void _applyActive() {
    final vc = _vc;
    if (vc == null || !_initialized) return;
    if (widget.isActive && !_userPaused) {
      vc.play();
    } else {
      vc.pause();
    }
  }

  void _togglePlay() {
    final vc = _vc;
    if (vc == null || !_initialized) return;
    setState(() => _userPaused = !_userPaused);
    _userPaused ? vc.pause() : vc.play();
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.moment;
    return GestureDetector(
      onTap: _togglePlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 视频 / 占位
          if (_initialized && _vc != null)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _vc!.value.size.width,
                height: _vc!.value.size.height,
                child: VideoPlayer(_vc!),
              ),
            )
          else
            const ColoredBox(
              color: Colors.black,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white24),
              ),
            ),

          // 暂停图标
          if (_userPaused)
            const Center(
              child: Icon(Icons.play_arrow_rounded,
                  size: 72, color: Colors.white70),
            ),

          // 底部渐变
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 220,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 右侧操作栏
          Positioned(
            right: 10,
            bottom: 90,
            child: _buildSidebar(m),
          ),

          // 底部作者 + 文案
          Positioned(
            left: 14,
            right: 80,
            bottom: 28,
            child: _buildCaption(m),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(MomentEntity m) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _action(
          icon: m.isLikedByMe ? Icons.favorite : Icons.favorite_border,
          color: m.isLikedByMe ? AppColors.error : Colors.white,
          label: '${m.likeCount}',
          onTap: widget.onLike,
        ),
        const SizedBox(height: 18),
        _action(
          icon: Icons.mode_comment_outlined,
          color: Colors.white,
          label: '${m.commentCount}',
          onTap: null,
        ),
      ],
    );
  }

  Widget _action({
    required IconData icon,
    required Color color,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 34),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCaption(MomentEntity m) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              backgroundImage:
                  (m.userAvatarUrl != null && m.userAvatarUrl!.isNotEmpty)
                      ? CachedNetworkImageProvider(m.userAvatarUrl!)
                      : null,
              child: (m.userAvatarUrl == null || m.userAvatarUrl!.isEmpty)
                  ? Text(m.userInitials,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 13))
                  : null,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                m.userName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        if (m.hasContent) ...[
          const SizedBox(height: 8),
          Text(
            m.content!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
          ),
        ],
      ],
    );
  }
}
