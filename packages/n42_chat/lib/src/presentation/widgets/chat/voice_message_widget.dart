import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/di/injection.dart';
import '../../../core/extensions/context_extension.dart';
import '../../../core/services/voice_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/debug_log.dart';

/// 语音转文字回调
typedef VoiceToTextCallback = Future<String?> Function();

/// 语音消息组件
///
/// 特点：
/// - 点击播放/暂停
/// - 播放动画
/// - 时长显示
/// - 已读/未读状态（红点）
/// - 语音转文字功能
class VoiceMessageWidget extends StatefulWidget {
  /// 语音时长（秒）
  final int duration;

  /// 是否是自己发送的
  final bool isSelf;

  /// 语音URL
  final String? voiceUrl;

  /// 是否已读
  final bool isRead;

  /// 点击回调（自定义播放逻辑时使用）
  final VoidCallback? onTap;

  /// 语音转文字回调
  final VoiceToTextCallback? onConvertToText;

  /// 请求外部触发转文字
  final VoidCallback? onRequestTranscription;

  /// 转换后的文字（如果已经转换过）
  final String? convertedText;

  /// 是否正在由外部状态管理转文字
  final bool isTranscribing;

  /// 外部转文字是否失败
  final bool transcriptionFailed;

  /// E2EE 解密 key（base64url）
  final String? encryptKey;

  /// E2EE 解密 IV（base64）
  final String? encryptIv;

  /// E2EE SHA-256 校验（base64）
  final String? encryptSha256;

  /// 语音服务（测试或宿主注入）
  final VoiceService? voiceService;

  const VoiceMessageWidget({
    super.key,
    required this.duration,
    required this.isSelf,
    this.voiceUrl,
    this.isRead = true,
    this.onTap,
    this.onConvertToText,
    this.onRequestTranscription,
    this.convertedText,
    this.isTranscribing = false,
    this.transcriptionFailed = false,
    this.encryptKey,
    this.encryptIv,
    this.encryptSha256,
    this.voiceService,
  });

  @override
  State<VoiceMessageWidget> createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late final VoiceService _voiceService;
  late final bool _ownsVoiceService;

  bool _isPlaying = false;
  bool _isConverting = false;
  String? _convertedText;
  StreamSubscription<PlaybackState>? _playbackSubscription;

  @override
  void initState() {
    super.initState();
    _voiceService =
        widget.voiceService ??
        (getIt.isRegistered<VoiceService>()
            ? getIt<VoiceService>()
            : VoiceService());
    _ownsVoiceService =
        widget.voiceService == null && !getIt.isRegistered<VoiceService>();
    unawaited(_voiceService.initialize());

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _convertedText = widget.convertedText;

    // 监听播放状态
    _playbackSubscription = _voiceService.playbackStateStream.listen((state) {
      if (mounted) {
        final isThisPlaying =
            state.isPlaying &&
            state.url != null &&
            state.url == widget.voiceUrl;

        if (_isPlaying != isThisPlaying) {
          setState(() {
            _isPlaying = isThisPlaying;
          });

          if (_isPlaying) {
            _animationController.repeat();
          } else {
            _animationController.stop();
            _animationController.reset();
          }
        }
      }
    });
  }

  @override
  void didUpdateWidget(VoiceMessageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.convertedText != oldWidget.convertedText) {
      _convertedText = widget.convertedText;
    }
  }

  @override
  void dispose() {
    _playbackSubscription?.cancel();
    _animationController.dispose();
    if (_ownsVoiceService) {
      unawaited(_voiceService.dispose());
    }
    super.dispose();
  }

  /// 根据时长计算宽度（微信样式）
  double _calculateWidth() {
    // 最短80dp，最长200dp
    const minWidth = 80.0;
    const maxWidth = 200.0;
    const maxDuration = 60;

    final ratio = (widget.duration / maxDuration).clamp(0.0, 1.0);
    return minWidth + (maxWidth - minWidth) * ratio;
  }

  void _handleTap() {
    debugLog(
      'VoiceMessageWidget: _handleTap called, voiceUrl=${widget.voiceUrl}, isSelf=${widget.isSelf}',
    );

    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }

    // 默认播放逻辑
    if (widget.voiceUrl == null || widget.voiceUrl!.isEmpty) {
      debugLog('VoiceMessageWidget: voiceUrl is null or empty, cannot play');
      // 提示用户
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            S.of(context)?.commonVoiceLoading ??
                'Voice loading, please try again later',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    if (_isPlaying) {
      debugLog('VoiceMessageWidget: stopping playback');
      _voiceService.stop();
    } else {
      debugLog('VoiceMessageWidget: starting playback: ${widget.voiceUrl}');
      _voiceService.play(
        widget.voiceUrl!,
        encryptKey: widget.encryptKey,
        encryptIv: widget.encryptIv,
        encryptSha256: widget.encryptSha256,
      );
    }
  }

  Future<void> _convertToText() async {
    if (_isConverting || widget.isTranscribing) {
      return;
    }

    if (widget.onRequestTranscription != null) {
      widget.onRequestTranscription!();
      return;
    }

    if (widget.onConvertToText == null) {
      return;
    }

    setState(() {
      _isConverting = true;
    });

    try {
      final text = await widget.onConvertToText!();
      if (mounted && text != null) {
        setState(() {
          _convertedText = text;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              S.of(context)?.commonVoiceToTextFailed ?? 'Voice to text failed',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConverting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = _calculateWidth();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = widget.isSelf
        ? AppColors.sentText(isDark)
        : AppColors.primary;
    final textColor = widget.isSelf
        ? AppColors.sentText(isDark)
        : context.textPrimary;
    final isConverting = _isConverting || widget.isTranscribing;
    final canConvertToText =
        widget.onRequestTranscription != null || widget.onConvertToText != null;
    final convertLabel = isConverting
        ? '...'
        : widget.transcriptionFailed
        ? (S.of(context)?.commonRetry ?? 'Retry')
        : (S.of(context)?.commonConvertToText ?? 'To text');
    final convertColor = widget.transcriptionFailed
        ? AppColors.error
        : AppColors.textSecondary;

    return Column(
      crossAxisAlignment: widget.isSelf
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        // 语音消息主体
        GestureDetector(
          onTap: _handleTap,
          behavior: HitTestBehavior.opaque,
          onLongPress:
              (widget.onConvertToText != null ||
                  widget.onRequestTranscription != null)
              ? _showContextMenu
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 未读红点（对方消息，在左侧显示）
              if (!widget.isSelf && !widget.isRead)
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.badge,
                    shape: BoxShape.circle,
                  ),
                ),

              // 语音内容
              SizedBox(
                width: width,
                child: Row(
                  mainAxisAlignment: widget.isSelf
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    // 左侧图标（对方消息）
                    if (!widget.isSelf)
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) =>
                            _buildVoiceIcon(iconColor, isReversed: false),
                      ),

                    // 时长
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${widget.duration}"',
                        style: TextStyle(fontSize: 16, color: textColor),
                      ),
                    ),

                    // 右侧图标（自己的消息）
                    if (widget.isSelf)
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) =>
                            _buildVoiceIcon(iconColor, isReversed: true),
                      ),
                  ],
                ),
              ),

              // 未读红点（自己的消息，在右侧显示）
              if (widget.isSelf && !widget.isRead)
                Container(
                  margin: const EdgeInsets.only(left: 4),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.badge,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),

        // 转换的文字
        if (_convertedText != null && _convertedText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.placeholder.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _convertedText!,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.isSelf
                      ? AppColors.sentText(isDark)
                      : (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary),
                  height: 1.4,
                ),
              ),
            ),
          ),

        // 转文字按钮（仅在没有转换文字时显示）
        if (_convertedText == null && canConvertToText)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: GestureDetector(
              onTap: isConverting ? null : _convertToText,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isConverting)
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation(
                          AppColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    Icon(
                      widget.transcriptionFailed
                          ? Icons.refresh
                          : Icons.text_fields,
                      size: 14,
                      color: convertColor,
                    ),
                  const SizedBox(width: 4),
                  Text(
                    convertLabel,
                    style: TextStyle(fontSize: 12, color: convertColor),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showContextMenu() {
    final isConverting = _isConverting || widget.isTranscribing;
    final canConvertToText =
        widget.onRequestTranscription != null || widget.onConvertToText != null;
    final convertLabel = isConverting
        ? '...'
        : widget.transcriptionFailed
        ? (S.of(context)?.commonRetry ?? 'Retry')
        : (S.of(context)?.commonConvertToText ?? 'To text');

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (_convertedText == null && canConvertToText)
                ListTile(
                  leading: Icon(
                    widget.transcriptionFailed
                        ? Icons.refresh
                        : Icons.text_fields,
                  ),
                  title: Text(convertLabel),
                  onTap: () {
                    Navigator.pop(ctx);
                    _convertToText();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: Text(S.of(context)?.commonCancel ?? 'Cancel'),
                onTap: () => Navigator.pop(ctx),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceIcon(Color color, {required bool isReversed}) {
    if (!_isPlaying) {
      return Transform.flip(
        flipX: isReversed,
        child: Icon(Icons.wifi, size: 20, color: color),
      );
    }

    // 播放动画：三条线依次闪烁
    final value = _animationController.value;
    final line1Opacity = _calculateLineOpacity(value, 0);
    final line2Opacity = _calculateLineOpacity(value, 0.33);
    final line3Opacity = _calculateLineOpacity(value, 0.66);

    return Transform.flip(
      flipX: isReversed,
      child: SizedBox(
        width: 20,
        height: 20,
        child: CustomPaint(
          painter: _VoiceWavePainter(
            color: color,
            line1Opacity: line1Opacity,
            line2Opacity: line2Opacity,
            line3Opacity: line3Opacity,
          ),
        ),
      ),
    );
  }

  double _calculateLineOpacity(double value, double offset) {
    final adjustedValue = (value + offset) % 1.0;
    if (adjustedValue < 0.5) {
      return adjustedValue * 2;
    } else {
      return (1 - adjustedValue) * 2;
    }
  }
}

class _VoiceWavePainter extends CustomPainter {
  final Color color;
  final double line1Opacity;
  final double line2Opacity;
  final double line3Opacity;

  _VoiceWavePainter({
    required this.color,
    required this.line1Opacity,
    required this.line2Opacity,
    required this.line3Opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final centerY = size.height / 2;

    // 第一条线（最短）
    paint.color = color.withValues(alpha: line1Opacity);
    canvas.drawLine(Offset(4, centerY - 3), Offset(4, centerY + 3), paint);

    // 第二条线（中等）
    paint.color = color.withValues(alpha: line2Opacity);
    canvas.drawLine(Offset(9, centerY - 5), Offset(9, centerY + 5), paint);

    // 第三条线（最长）
    paint.color = color.withValues(alpha: line3Opacity);
    canvas.drawLine(Offset(14, centerY - 7), Offset(14, centerY + 7), paint);
  }

  @override
  bool shouldRepaint(covariant _VoiceWavePainter oldDelegate) {
    return oldDelegate.line1Opacity != line1Opacity ||
        oldDelegate.line2Opacity != line2Opacity ||
        oldDelegate.line3Opacity != line3Opacity;
  }
}
