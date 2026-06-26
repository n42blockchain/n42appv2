library;

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/voip/livekit_service.dart';
import '../../../services/voip/voip_config.dart';
import '../../../services/voip/webrtc_service.dart';

abstract class CallEnhancementController {
  AudioProcessingConfig get audioProcessingConfig;

  bool get supportsEnhancedAudio;
  bool get isEnhancedAudioEnabled;

  bool get supportsBackgroundBlur;
  bool get canUseBackgroundBlur;
  bool get isBackgroundBlurEnabled;

  bool get supportsRecording;
  String get recordingFeatureName;

  Future<void> toggleNoiseSuppression();
  Future<void> toggleEchoCancellation();
  Future<void> toggleAutoGainControl();
  Future<void> toggleEnhancedAudio();
  Future<void> toggleBackgroundBlur();
  Future<bool> startRecording();
}

class WebRTCCallEnhancementController implements CallEnhancementController {
  WebRTCCallEnhancementController(this.service);

  final WebRTCService service;

  @override
  AudioProcessingConfig get audioProcessingConfig =>
      service.audioProcessingConfig;

  @override
  bool get supportsEnhancedAudio => false;

  @override
  bool get isEnhancedAudioEnabled => audioProcessingConfig.enhancedMode;

  @override
  bool get supportsBackgroundBlur => false;

  @override
  bool get canUseBackgroundBlur => false;

  @override
  bool get isBackgroundBlurEnabled => false;

  @override
  bool get supportsRecording => false;

  @override
  String get recordingFeatureName => 'Call recording';

  @override
  Future<void> toggleNoiseSuppression() => service.toggleNoiseSuppression();

  @override
  Future<void> toggleEchoCancellation() => service.toggleEchoCancellation();

  @override
  Future<void> toggleAutoGainControl() => service.toggleAutoGainControl();

  @override
  Future<void> toggleEnhancedAudio() async {}

  @override
  Future<void> toggleBackgroundBlur() async {}

  @override
  Future<bool> startRecording() async => false;
}

class LiveKitCallEnhancementController implements CallEnhancementController {
  LiveKitCallEnhancementController(this.service);

  final LiveKitService service;

  @override
  AudioProcessingConfig get audioProcessingConfig =>
      service.audioProcessingConfig;

  @override
  bool get supportsEnhancedAudio => true;

  @override
  bool get isEnhancedAudioEnabled => audioProcessingConfig.enhancedMode;

  @override
  bool get supportsBackgroundBlur => true;

  @override
  bool get canUseBackgroundBlur => service.isVideoEnabled;

  @override
  bool get isBackgroundBlurEnabled =>
      service.isBackgroundProcessingEnabled &&
      service.backgroundProcessingConfig.mode == BackgroundMode.blur;

  @override
  bool get supportsRecording => true;

  @override
  String get recordingFeatureName => 'Cloud recording';

  @override
  Future<void> toggleNoiseSuppression() => service.toggleNoiseSuppression();

  @override
  Future<void> toggleEchoCancellation() => service.toggleEchoCancellation();

  @override
  Future<void> toggleAutoGainControl() => service.toggleAutoGainControl();

  @override
  Future<void> toggleEnhancedAudio() => service.toggleEnhancedMode();

  @override
  Future<void> toggleBackgroundBlur() => service.toggleBackgroundBlur();

  @override
  Future<bool> startRecording() => service.startRecording();
}

Future<void> showCallEnhancementSheet({
  required BuildContext context,
  required CallEnhancementController controller,
  required VoidCallback onChanged,
  String? title,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CallEnhancementSheet(
      controller: controller,
      onChanged: onChanged,
      title: title,
    ),
  );
}

class CallEnhancementSheet extends StatefulWidget {
  const CallEnhancementSheet({
    super.key,
    required this.controller,
    required this.onChanged,
    this.title,
  });

  final CallEnhancementController controller;
  final VoidCallback onChanged;
  final String? title;

  @override
  State<CallEnhancementSheet> createState() => _CallEnhancementSheetState();
}

class _CallEnhancementSheetState extends State<CallEnhancementSheet> {
  bool _isBusy = false;

  CallEnhancementController get _controller => widget.controller;

  Future<void> _runAction(Future<void> Function() action) async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
    });

    try {
      await action();
      widget.onChanged();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to update call settings: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _handleRecordingTap() async {
    if (_isBusy) return;

    setState(() {
      _isBusy = true;
    });

    try {
      final started = await _controller.startRecording();
      if (!mounted) return;

      if (started) {
        widget.onChanged();
        context.showSuccessSnackBar('Recording started');
      } else {
        final s = S.of(context);
        context.showSnackBar(
          s?.commonFeatureComingSoon(_controller.recordingFeatureName) ??
              '${_controller.recordingFeatureName} coming soon',
        );
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Failed to start recording: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final backgroundColor = context.surfaceColor;
    final dividerColor = Colors.white.withValues(alpha: isDark ? 0.10 : 0.08);
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final audioConfig = _controller.audioProcessingConfig;
    final canToggleBackgroundBlur =
        !_isBusy &&
        (_controller.canUseBackgroundBlur ||
            _controller.isBackgroundBlurEnabled);

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: dividerColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title ?? 'Call tools',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Tune audio and video quality without leaving the call.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: subtitleColor),
            ),
            const SizedBox(height: 24),
            const _SectionTitle(title: 'Audio enhancement'),
            _SwitchTile(
              icon: Icons.graphic_eq,
              title: 'Noise suppression',
              subtitle: 'Reduce keyboard and background noise.',
              value: audioConfig.noiseSuppression,
              enabled: !_isBusy,
              onChanged: (_) => _runAction(_controller.toggleNoiseSuppression),
            ),
            _SwitchTile(
              icon: Icons.hearing,
              title: 'Echo cancellation',
              subtitle: 'Prevent speaker feedback from re-entering the mic.',
              value: audioConfig.echoCancellation,
              enabled: !_isBusy,
              onChanged: (_) => _runAction(_controller.toggleEchoCancellation),
            ),
            _SwitchTile(
              icon: Icons.mic,
              title: 'Auto gain control',
              subtitle: 'Keep microphone volume more stable.',
              value: audioConfig.autoGainControl,
              enabled: !_isBusy,
              onChanged: (_) => _runAction(_controller.toggleAutoGainControl),
            ),
            if (_controller.supportsEnhancedAudio)
              _SwitchTile(
                icon: Icons.auto_awesome,
                title: 'Enhanced voice isolation',
                subtitle: 'Use a stronger noise reduction profile.',
                value: _controller.isEnhancedAudioEnabled,
                enabled: !_isBusy,
                onChanged: (_) => _runAction(_controller.toggleEnhancedAudio),
              ),
            if (_controller.supportsBackgroundBlur) ...[
              const SizedBox(height: 20),
              const _SectionTitle(title: 'Video'),
              _SwitchTile(
                icon: Icons.blur_on,
                title: 'Background blur (beta)',
                subtitle: _controller.canUseBackgroundBlur
                    ? 'Preference is wired. Visual blur still depends on the video processor rollout.'
                    : _controller.isBackgroundBlurEnabled
                    ? 'Blur preference is saved and will apply when camera processing is available.'
                    : 'Turn on your camera after background processing is available.',
                value: _controller.isBackgroundBlurEnabled,
                enabled: canToggleBackgroundBlur,
                onChanged: (_) => _runAction(_controller.toggleBackgroundBlur),
              ),
            ],
            if (_controller.supportsRecording) ...[
              const SizedBox(height: 20),
              const _SectionTitle(title: 'Recording'),
              _ActionTile(
                icon: Icons.fiber_manual_record,
                iconColor: Colors.redAccent,
                title: _controller.recordingFeatureName,
                subtitle:
                    'Requires server-side egress before recordings can be saved.',
                enabled: !_isBusy,
                onTap: _handleRecordingTap,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final tileColor = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.03);
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: enabled ? onChanged : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        secondary: Icon(
          icon,
          color: enabled ? AppColors.primary : subtitleColor,
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: subtitleColor),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final tileColor = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.03);
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        enabled: enabled,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: iconColor ?? AppColors.primary),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: subtitleColor),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
