import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../n42_chat.dart';
import '../../blocs/moment/moment_bloc.dart';
import '../../blocs/contact/contact_bloc.dart';
import 'create_moment_page.dart';

import '../../../core/services/authenticated_video_source.dart';
import '../../widgets/common/n42_avatar.dart';
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
  final bool creatorActions;
  final String? userId;
  const VideoFeedPage({super.key, this.creatorActions = false, this.userId});

  @override
  State<VideoFeedPage> createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  final PageController _pageController = PageController();
  List<MomentEntity> _videos = const [];
  bool _loading = true;
  StreamSubscription<List<MomentEntity>>? _subscription;
  int _current = 0;
  bool _creatorRouteOpen = false;
  int _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _subscription = getIt<IMomentRepository>().watchMoments().listen(
      (_) {
        // Remove revoked content while fresh permissions are being resolved.
        _loadGeneration++;
        if (mounted) setState(() => _videos = []);
        _load();
      },
      onError: (Object _) {
        _loadGeneration++;
        if (mounted) {
          setState(() {
            _videos = [];
            _loading = false;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final generation = ++_loadGeneration;
    try {
      final repository = getIt<IMomentRepository>();
      final moments = widget.userId == null
          ? await repository.getMoments(limit: 50)
          : await repository.getUserMoments(widget.userId!, limit: 50);
      final vids = moments.where((m) => m.hasVideo && !m.isDeleted).toList();
      if (mounted && generation == _loadGeneration) {
        setState(() {
          _videos = vids;
          _current = _current.clamp(0, vids.isEmpty ? 0 : vids.length - 1);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted && generation == _loadGeneration) {
        setState(() {
          _loading = false;
          _videos = [];
        });
      }
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
        likes.add(
          MomentLike(userId: 'me', userName: 'Me', timestamp: DateTime.now()),
        );
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
      if (mounted && index < _videos.length && _videos[index].id == m.id) {
        setState(() => _videos[index] = m);
      }
    }
  }

  Future<void> _create({required bool live}) async {
    if (_creatorRouteOpen) return;
    setState(() => _creatorRouteOpen = true);
    try {
      if (live) {
        final opened = await N42Chat.invokeGoLive(context);
        if (!opened && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                S.of(context)?.videoLiveUnavailable ??
                    'Live broadcasting is unavailable',
              ),
            ),
          );
        }
      } else {
        final contacts = context.read<ContactBloc?>();
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => MultiBlocProvider(
              providers: [
                BlocProvider<MomentBloc>(
                  create: (_) => MomentBloc(getIt<IMomentRepository>()),
                ),
                if (contacts != null)
                  BlocProvider<ContactBloc>.value(value: contacts),
              ],
              child: const CreateMomentPage(videoOnly: true),
            ),
          ),
        );
        if (mounted) await _load();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context)?.commonLoadFailed ?? 'Failed to load'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _creatorRouteOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: widget.creatorActions
          ? AppBar(
              title: Text(
                S.of(context)?.discoverVideoChannels ?? 'Video Channels',
              ),
            )
          : null,
      bottomNavigationBar: widget.creatorActions
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _creatorRouteOpen
                            ? null
                            : () => _create(live: false),
                        icon: const Icon(Icons.video_call),
                        label: Text(
                          S.of(context)?.videoPublish ?? 'Publish video',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _creatorRouteOpen
                            ? null
                            : () => _create(live: true),
                        icon: const Icon(Icons.live_tv),
                        label: Text(S.of(context)?.videoGoLive ?? 'Go live'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
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
                    key: ValueKey(_videos[i].id),
                    moment: _videos[i],
                    isActive: i == _current && !_creatorRouteOpen,
                    onLike: () => _toggleLike(i),
                  ),
                ),
                if (!widget.creatorActions)
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
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
              Icon(
                Icons.video_collection_outlined,
                size: 56,
                color: Colors.white38,
              ),
              SizedBox(height: 12),
              Text(
                'No videos yet',
                style: TextStyle(color: Colors.white54, fontSize: 15),
              ),
            ],
          ),
        ),
        if (!widget.creatorActions)
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
    super.key,
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
  bool _failed = false;
  int _generation = 0;
  AuthenticatedVideoSource? _mediaSource;
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
    _generation++;
    _vc?.dispose();
    unawaited(_mediaSource?.dispose());
    super.dispose();
  }

  Future<void> _init() async {
    final generation = ++_generation;
    final previous = _vc;
    _vc = null;
    await previous?.dispose();
    await _mediaSource?.dispose();
    if (!mounted || generation != _generation) return;
    setState(() {
      _initialized = false;
      _failed = false;
    });
    VideoPlayerController? vc;
    try {
      final video = widget.moment.media.firstWhere((m) => m.isVideo);
      final client = MatrixClientManager.instance.client;
      final url = video.url.startsWith('mxc://')
          ? mx_utils.MatrixUtils.getMediaDownloadUrl(video.url, client: client)
          : video.httpUrl ?? video.url;
      if (url == null || url.isEmpty) throw StateError('Video URL unavailable');
      final headers = mx_utils.MatrixUtils.buildAuthenticatedMediaHeaders(
        url,
        client: client,
      );
      if (headers.isNotEmpty) {
        final source = AuthenticatedVideoSource();
        _mediaSource = source;
        final file = await source
            .load(Uri.parse(url), headers)
            .timeout(const Duration(minutes: 2));
        if (!mounted || generation != _generation) {
          await source.dispose();
          return;
        }
        vc = VideoPlayerController.file(file);
      } else {
        vc = VideoPlayerController.networkUrl(Uri.parse(url));
      }
      _vc = vc;
      await vc.initialize().timeout(const Duration(seconds: 30));
      if (!mounted || generation != _generation) {
        await vc.dispose();
        return;
      }
      await vc.setLooping(true);
      setState(() => _initialized = true);
      if (widget.isActive && !_userPaused) await vc.play();
    } catch (_) {
      await vc?.dispose();
      if (!mounted || generation != _generation) return;
      _vc = null;
      await _mediaSource?.dispose();
      if (mounted) setState(() => _failed = true);
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
          else if (_failed)
            Center(
              child: TextButton.icon(
                onPressed: _init,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: Text(
                  '${S.of(context)?.commonLoadFailed ?? 'Failed to load'} · ${S.of(context)?.commonRetry ?? 'Retry'}',
                  style: const TextStyle(color: Colors.white),
                ),
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
              child: Icon(
                Icons.play_arrow_rounded,
                size: 72,
                color: Colors.white70,
              ),
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
          Positioned(right: 10, bottom: 90, child: _buildSidebar(m)),

          // 底部作者 + 文案
          Positioned(left: 14, right: 80, bottom: 28, child: _buildCaption(m)),
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
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCaption(MomentEntity m) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () => N42Chat.openUserProfile(m.userId, context: context),
          child: Row(
            children: [
              N42Avatar(imageUrl: m.userAvatarUrl, name: m.userName, size: 32),
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
