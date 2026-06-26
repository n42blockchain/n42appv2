import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../../../core/di/injection.dart';
import '../../../core/utils/matrix_utils.dart' as mx_utils;
import '../../../data/datasources/matrix/matrix_client_manager.dart';
import '../../../core/utils/debug_log.dart';

/// 媒体项数据
class MediaItem {
  final String url;
  final String? thumbnailUrl;
  final String? heroTag;
  final bool isVideo;
  final String? caption;
  final String? senderName;
  final DateTime? sentAt;

  const MediaItem({
    required this.url,
    this.thumbnailUrl,
    this.heroTag,
    this.isVideo = false,
    this.caption,
    this.senderName,
    this.sentAt,
  });
}

/// 全屏媒体预览页面
///
/// 支持图片缩放/平移和视频播放
/// 手势：上滑关闭、左右切换
class MediaPreviewPage extends StatefulWidget {
  final List<MediaItem> items;
  final int initialIndex;
  final VoidCallback? onDownload;
  final void Function(int index)? onForward;

  const MediaPreviewPage({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.onDownload,
    this.onForward,
  });

  @override
  State<MediaPreviewPage> createState() => _MediaPreviewPageState();
}

class _MediaPreviewPageState extends State<MediaPreviewPage> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showToolbar = true;
  VideoPlayerController? _videoController;
  // 累计创建的临时文件，在 dispose 时统一清理
  final _tempFiles = <File>[];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    if (widget.items[_currentIndex].isVideo) {
      _initVideoPlayer(widget.items[_currentIndex].url);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    for (final f in _tempFiles) {
      f.delete().ignore();
    }
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _initVideoPlayer(String url) async {
    unawaited(_videoController?.dispose());
    _videoController = null;

    final headers = mx_utils.MatrixUtils.buildAuthenticatedMediaHeaders(
      url,
      client: getIt<MatrixClientManager>().client,
    );

    VideoPlayerController controller;
    // iOS：AVFoundation 在 HTTP 重定向时丢弃 Authorization header，
    // 需要先将视频流式下载至临时文件再播放。
    if (Platform.isIOS && headers.isNotEmpty) {
      try {
        final request = http.Request('GET', Uri.parse(url));
        request.headers.addAll(headers);
        final httpClient = http.Client();
        final streamResponse = await httpClient.send(request);
        if (streamResponse.statusCode == 200) {
          final dir = await getTemporaryDirectory();
          final file = File(
            '${dir.path}/preview_${DateTime.now().millisecondsSinceEpoch}.mp4',
          );
          final sink = file.openWrite();
          await streamResponse.stream.pipe(sink);
          await sink.close();
          httpClient.close();
          _tempFiles.add(file);
          controller = VideoPlayerController.file(file);
        } else {
          httpClient.close();
          debugLog(
            'iOS video download returned ${streamResponse.statusCode}, falling back',
          );
          controller = VideoPlayerController.networkUrl(Uri.parse(url));
        }
      } catch (e) {
        debugLog('iOS video download error, falling back: $e');
        controller = VideoPlayerController.networkUrl(Uri.parse(url));
      }
    } else {
      controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: headers,
      );
    }

    _videoController = controller;
    try {
      await controller.initialize();
      await controller.play();
      if (mounted) setState(() {});
    } catch (e) {
      debugLog('Video player init failed: $e');
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    _videoController?.pause();
    _videoController?.dispose();
    _videoController = null;

    if (widget.items[index].isVideo) {
      _initVideoPlayer(widget.items[index].url);
    }
  }

  void _toggleToolbar() {
    setState(() {
      _showToolbar = !_showToolbar;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 媒体内容
          GestureDetector(
            onTap: _toggleToolbar,
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity!.abs() > 300) {
                Navigator.of(context).pop();
              }
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.items.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return item.isVideo ? _buildVideoView() : _buildImageView(item);
              },
            ),
          ),

          // 顶部工具栏
          if (_showToolbar)
            Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),

          // 底部工具栏
          if (_showToolbar)
            Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomBar()),

          // 页码指示器
          if (widget.items.length > 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 56,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  '${_currentIndex + 1} / ${widget.items.length}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageView(MediaItem item) {
    return InteractiveViewer(
      minScale: 0.5,
      maxScale: 4.0,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: item.url,
          fit: BoxFit.contain,
          placeholder: (_, _) => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
          errorWidget: (_, _, _) => const Center(
            child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoView() {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_videoController!),
            GestureDetector(
              onTap: () {
                setState(() {
                  _videoController!.value.isPlaying
                      ? _videoController!.pause()
                      : _videoController!.play();
                });
              },
              child: AnimatedOpacity(
                opacity: _videoController!.value.isPlaying ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ),
            // 视频进度条
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _videoController!,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.white,
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.white10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final item = widget.items[_currentIndex];
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.senderName != null)
                  Text(
                    item.senderName!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (item.sentAt != null)
                  Text(
                    _formatDate(item.sentAt!),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: widget.onDownload,
          ),
          IconButton(
            icon: const Icon(Icons.forward, color: Colors.white),
            onPressed: widget.onForward != null
                ? () => widget.onForward!(_currentIndex)
                : null,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
