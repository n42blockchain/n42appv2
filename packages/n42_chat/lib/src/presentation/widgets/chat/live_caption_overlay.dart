import 'package:flutter/material.dart';

import '../../../core/services/live_caption_service.dart';

/// 实时字幕浮层
///
/// 绑定 [LiveCaptionService.captions]，在通话/视频底部显示最近几条字幕。
/// 叠在视频上，固定深色半透明底 + 白字（不随主题，保证视频上可读）。
class LiveCaptionOverlay extends StatelessWidget {
  final LiveCaptionService service;

  /// 显示最近几条
  final int maxLines;

  const LiveCaptionOverlay({
    super.key,
    required this.service,
    this.maxLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<LiveCaption>>(
      valueListenable: service.captions,
      builder: (ctx, caps, _) {
        if (caps.isEmpty) return const SizedBox.shrink();
        final recent =
            caps.length > maxLines ? caps.sublist(caps.length - maxLines) : caps;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: recent
                .map((c) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Text(
                        c.speaker == null ? c.text : '${c.speaker}: ${c.text}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}
