import 'package:flutter/material.dart';

import '../../../core/di/injection.dart';
import '../../../domain/entities/call_enhancement_settings.dart';
import '../../../services/voip/processing/audio_processing_service.dart';
import '../../../services/voip/processing/video_processing_service.dart';

/// 通话中可用的增强控制：降噪 + 虚拟背景。
///
/// 以 bottom sheet 形式放在通话屏幕中——UI 侧仅读取/修改偏好状态，
/// 真正生效由各 Service 在下次渲染/采集帧时应用。
class CallEnhancementControls extends StatefulWidget {
  const CallEnhancementControls({super.key});

  static Future<void> showAsSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const Padding(
        padding: EdgeInsets.all(16),
        child: CallEnhancementControls(),
      ),
    );
  }

  @override
  State<CallEnhancementControls> createState() =>
      _CallEnhancementControlsState();
}

class _CallEnhancementControlsState extends State<CallEnhancementControls> {
  late final AudioProcessingService _audio = getIt<AudioProcessingService>();
  late final VideoProcessingService _video = getIt<VideoProcessingService>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CallEnhancementSettings>(
      valueListenable: _audio.settings,
      builder: (context, audioSettings, _) {
        return ValueListenableBuilder<CallEnhancementSettings>(
          valueListenable: _video.settings,
          builder: (context, videoSettings, __) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '通话增强',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildBackgroundSection(videoSettings.background),
                const Divider(height: 32),
                _buildNoiseSection(audioSettings.noiseSuppression),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('回声消除'),
                  value: audioSettings.echoCancellation,
                  contentPadding: EdgeInsets.zero,
                  onChanged: _audio.setEchoCancellation,
                ),
                SwitchListTile(
                  title: const Text('自动增益 (AGC)'),
                  value: audioSettings.autoGainControl,
                  contentPadding: EdgeInsets.zero,
                  onChanged: _audio.setAutoGainControl,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBackgroundSection(VirtualBackground current) {
    String label(VirtualBackground bg) => switch (bg) {
          VirtualBackgroundNone() => '无',
          VirtualBackgroundBlur() => '模糊',
          VirtualBackgroundImage() => '图片',
        };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('虚拟背景', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('无'),
              selected: current is VirtualBackgroundNone,
              onSelected: (_) =>
                  _video.setBackground(const VirtualBackground.none()),
            ),
            ChoiceChip(
              label: const Text('模糊'),
              selected: current is VirtualBackgroundBlur,
              onSelected: (_) => _video.setBackground(
                const VirtualBackground.blur(sigma: 8),
              ),
            ),
            ChoiceChip(
              label: const Text('强模糊'),
              selected: current is VirtualBackgroundBlur &&
                  (current).sigma >= 15,
              onSelected: (_) => _video.setBackground(
                const VirtualBackground.blur(sigma: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '当前：${label(current)}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildNoiseSection(NoiseSuppressionLevel level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AI 降噪', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: NoiseSuppressionLevel.values.map((lvl) {
            final label = switch (lvl) {
              NoiseSuppressionLevel.off => '关闭',
              NoiseSuppressionLevel.low => '低',
              NoiseSuppressionLevel.medium => '中',
              NoiseSuppressionLevel.high => '高',
            };
            return ChoiceChip(
              label: Text(label),
              selected: level == lvl,
              onSelected: (_) => _audio.setNoiseSuppression(lvl),
            );
          }).toList(),
        ),
      ],
    );
  }
}
