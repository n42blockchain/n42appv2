import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../../domain/entities/moment_entity.dart';
import '../../blocs/moment/moment_bloc.dart';
import '../../blocs/moment/moment_state.dart';
import '../../blocs/moment/moment_event.dart';

/// 短视频 Feed 页面 —— 沉浸式全屏上下滑动。
///
/// 从 [MomentBloc] 获取带视频的动态，用 [PageView] 实现 TikTok 风格滑动。
class VideoFeedPage extends StatefulWidget {
  const VideoFeedPage({super.key});

  @override
  State<VideoFeedPage> createState() => _VideoFeedPageState();
}

class _VideoFeedPageState extends State<VideoFeedPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<MomentBloc>().add(const LoadMoments());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('视频', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<MomentBloc, MomentState>(
        builder: (context, state) {
          final videoMoments = state.moments
              .where((m) => m.media.any((media) => media.isVideo))
              .toList();

          if (videoMoments.isEmpty) {
            return const Center(
              child: Text(
                '暂无视频内容',
                style: TextStyle(color: Colors.white60, fontSize: 16),
              ),
            );
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: videoMoments.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return _VideoFeedItem(
                moment: videoMoments[index],
                isActive: index == _currentIndex,
              );
            },
          );
        },
      ),
    );
  }
}

class _VideoFeedItem extends StatefulWidget {
  const _VideoFeedItem({
    required this.moment,
    required this.isActive,
  });

  final MomentEntity moment;
  final bool isActive;

  @override
  State<_VideoFeedItem> createState() => _VideoFeedItemState();
}

class _VideoFeedItemState extends State<_VideoFeedItem> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  MomentMedia get _video =>
      widget.moment.media.firstWhere((m) => m.isVideo);

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final url = _video.httpUrl ?? _video.url;
    if (url.isEmpty) return;

    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await _controller!.initialize();
      await _controller!.setLooping(true);
      if (widget.isActive) {
        await _controller!.play();
      }
      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      debugPrint('VideoFeed: init failed - $e');
    }
  }

  @override
  void didUpdateWidget(covariant _VideoFeedItem old) {
    super.didUpdateWidget(old);
    if (widget.isActive && !old.isActive) {
      _controller?.play();
    } else if (!widget.isActive && old.isActive) {
      _controller?.pause();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _showCommentSheet(BuildContext context, MomentEntity moment) {
    final controller = TextEditingController();
    final bloc = context.read<MomentBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
          ),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      maxLines: 3,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: '写评论…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;
                      bloc.add(CommentMoment(
                        momentId: moment.id,
                        content: text,
                      ));
                      Navigator.of(sheetCtx).pop();
                    },
                    child: const Text('发送'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _shareMomentLink(BuildContext context, MomentEntity moment) {
    // 分享链接走标准 share sheet；若平台不支持则降级显示链接。
    // 后端生成的 moment deeplink 形如 n42://moment/<id>
    final link = 'n42://moment/${moment.id}';
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetCtx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('复制链接'),
                subtitle: Text(
                  link,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: link));
                  if (sheetCtx.mounted) {
                    Navigator.of(sheetCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已复制到剪贴板')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 视频层
        if (_initialized && _controller != null)
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          )
        else
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),

        // 渐变底部遮罩
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 200,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
              ),
            ),
          ),
        ),

        // 底部信息
        Positioned(
          left: 16,
          right: 80,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: widget.moment.userAvatarUrl != null
                        ? NetworkImage(widget.moment.userAvatarUrl!)
                        : null,
                    child: widget.moment.userAvatarUrl == null
                        ? Text(widget.moment.userName.isNotEmpty
                            ? widget.moment.userName[0]
                            : '?')
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.moment.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              if (widget.moment.content != null &&
                  widget.moment.content!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.moment.content!,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),

        // 右侧互动栏
        Positioned(
          right: 8,
          bottom: MediaQuery.of(context).padding.bottom + 80,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ActionButton(
                icon: widget.moment.isLikedByMe
                    ? Icons.favorite
                    : Icons.favorite_border,
                label: '${widget.moment.likes.length}',
                color: widget.moment.isLikedByMe ? Colors.red : Colors.white,
                onTap: () {
                  final bloc = context.read<MomentBloc>();
                  if (widget.moment.isLikedByMe) {
                    bloc.add(UnlikeMoment(widget.moment.id));
                  } else {
                    bloc.add(LikeMoment(widget.moment.id));
                  }
                },
              ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: Icons.comment_outlined,
                label: '${widget.moment.comments.length}',
                onTap: () => _showCommentSheet(context, widget.moment),
              ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: Icons.share_outlined,
                label: '分享',
                onTap: () => _shareMomentLink(context, widget.moment),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.color = Colors.white,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
