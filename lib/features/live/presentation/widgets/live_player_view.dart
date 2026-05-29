import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../services/live_video_service.dart';

/// LiveKit 视频渲染层。监听 [LiveVideoService] 的会话变化，
/// 全屏渲染主播轨道（观众端）或本地预览（主播端）。
class LivePlayerView extends StatelessWidget {
  const LivePlayerView({
    super.key,
    required this.videoService,
    this.showLocal = false,
  });

  final LiveVideoService videoService;

  /// true：渲染本地摄像头预览（主播端）；false：渲染主播远端轨道（观众端）。
  final bool showLocal;

  @override
  Widget build(BuildContext context) {
    final listenable = videoService.listenable;
    if (listenable == null) {
      return const _Placeholder(text: '连接中…');
    }
    return ListenableBuilder(
      listenable: listenable,
      builder: (context, _) {
        final track = showLocal
            ? videoService.localVideoTrack
            : videoService.primaryVideoTrack;
        if (track == null) {
          return const _Placeholder(text: '等待画面…');
        }
        return VideoTrackRenderer(track, fit: VideoViewFit.cover);
      },
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Text(text, style: const TextStyle(color: Colors.white54)),
      ),
    );
  }
}
