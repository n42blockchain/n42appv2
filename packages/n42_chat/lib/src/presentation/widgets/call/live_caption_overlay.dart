import 'package:flutter/material.dart';

import '../../../services/voip/processing/live_caption_service.dart';

/// 通话实时字幕覆盖层。
///
/// 半透明黑底白字，固定在屏幕底部，实时显示 [LiveCaptionService.captionStream]
/// 的最新输出。最多显示 2 行，旧字幕淡出。
class LiveCaptionOverlay extends StatelessWidget {
  const LiveCaptionOverlay({
    super.key,
    required this.captionService,
  });

  final LiveCaptionService captionService;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 100,
      child: StreamBuilder<CaptionSegment>(
        stream: captionService.captionStream,
        builder: (context, snapshot) {
          final segment = snapshot.data;
          if (segment == null) return const SizedBox.shrink();

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(segment.timestamp.millisecondsSinceEpoch),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (segment.speakerName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        segment.speakerName!,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Text(
                    segment.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
