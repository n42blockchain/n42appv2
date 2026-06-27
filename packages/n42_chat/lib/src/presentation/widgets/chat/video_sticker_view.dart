import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// 视频贴纸渲染（WebM / MP4，循环静音自动播放）。
///
/// 对标 Telegram 的 WebM/VP9 视频贴纸。
///
/// ## 平台说明（诚实标注）
///
/// - **Android**：ExoPlayer 支持 WebM(VP8/VP9) 与 MP4，正常播放。
/// - **iOS / macOS**：AVPlayer **不原生支持 WebM**，WebM 贴纸会初始化失败，
///   本控件回退为静态占位（不崩溃）。MP4 在各端均可。
/// - 每个可见视频贴纸持有一个 [VideoPlayerController]，离屏即 dispose；
///   贴纸包内视频数量通常很少，开销可接受。
class VideoStickerView extends StatefulWidget {
  const VideoStickerView({
    super.key,
    required this.url,
    this.headers = const {},
    this.fit = BoxFit.contain,
  });

  final String url;
  final Map<String, String> headers;
  final BoxFit fit;

  /// 是否为视频贴纸（按 mimeType 或扩展名判断）。
  static bool isVideoSticker({String? mimeType, String? url}) {
    final m = mimeType?.toLowerCase() ?? '';
    if (m.startsWith('video/')) return true;
    final u = url?.toLowerCase() ?? '';
    final clean = u.split('?').first;
    return clean.endsWith('.webm') || clean.endsWith('.mp4');
  }

  @override
  State<VideoStickerView> createState() => _VideoStickerViewState();
}

class _VideoStickerViewState extends State<VideoStickerView> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      httpHeaders: widget.headers,
    );
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (_) {
      // WebM-on-iOS 等编解码不支持：回退静态占位，不崩溃。
      await controller.dispose();
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (_failed) {
      return const Center(child: Icon(Icons.movie_outlined));
    }
    if (controller == null || !controller.value.isInitialized) {
      return const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return FittedBox(
      fit: widget.fit,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}
