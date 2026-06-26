import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_icons.dart';

/// WeChat-inspired slide-to-confirm payment button.
///
/// The user must drag the thumb from left to right to trigger [onConfirmed].
/// Releasing before completion springs the thumb back — preventing accidental
/// payment confirmations from a simple tap.
///
/// Usage:
/// ```dart
/// SlideToPayButton(
///   label: S.of(context)!.slideToPayLabel,
///   confirmingLabel: S.of(context)!.slideToPayConfirming,
///   onConfirmed: _send,
/// )
/// ```
class SlideToPayButton extends StatefulWidget {
  /// Called once when the user slides the thumb to the end.
  final VoidCallback onConfirmed;

  /// Label shown inside the track before sliding (e.g. "→→→ Slide to confirm").
  final String label;

  /// Label shown after the threshold is reached (e.g. "Confirming...").
  final String confirmingLabel;

  /// Primary color used for the track fill and icon.
  final Color trackColor;

  final double height;

  const SlideToPayButton({
    super.key,
    required this.onConfirmed,
    required this.label,
    required this.confirmingLabel,
    this.trackColor = const Color(0xFFF9A825),
    this.height = 56,
  });

  @override
  State<SlideToPayButton> createState() => _SlideToPayButtonState();
}

class _SlideToPayButtonState extends State<SlideToPayButton>
    with SingleTickerProviderStateMixin {
  // 0.0 → left (start), 1.0 → right (end)
  double _dragProgress = 0.0;
  bool _isCompleted = false;

  late AnimationController _resetController;
  late CurvedAnimation _resetCurve;

  // Stored at the moment spring-back starts, so _onReset() can interpolate.
  double _springStart = 0.0;

  static const double _thumbSize = 48.0;
  static const double _padding = 4.0;
  // Completion fires at 92% to feel snappy, not requiring pixel-perfect drag.
  static const double _completionThreshold = 0.92;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    )
      ..addListener(_onReset)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _resetController.reset();
      });
    _resetCurve = CurvedAnimation(
      parent: _resetController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _resetCurve.dispose();
    _resetController.dispose();
    super.dispose();
  }

  // ─── Gesture handlers ────────────────────────────────────────────────────

  void _onDragUpdate(DragUpdateDetails details, double maxOffset) {
    if (_isCompleted) return;
    setState(() {
      _dragProgress =
          (_dragProgress + details.delta.dx / maxOffset).clamp(0.0, 1.0);
    });
    if (_dragProgress >= _completionThreshold) {
      _complete();
    }
  }

  void _onDragEnd(DragEndDetails _) {
    if (!_isCompleted) _springBack();
  }

  void _complete() {
    if (_isCompleted) return;
    setState(() {
      _isCompleted = true;
      _dragProgress = 1.0;
    });
    HapticFeedback.heavyImpact();
    widget.onConfirmed();
  }

  void _springBack() {
    _springStart = _dragProgress;
    _resetController
      ..reset()
      ..forward();
  }

  void _onReset() {
    if (mounted && !_isCompleted) {
      setState(() {
        // Ease from _springStart → 0 as controller goes 0 → 1
        _dragProgress = _springStart * (1.0 - _resetCurve.value);
      });
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final trackWidth = constraints.maxWidth;
        final maxOffset = trackWidth - _thumbSize - _padding * 2;
        final thumbLeft = _dragProgress * maxOffset + _padding;
        final fillWidth = thumbLeft + _thumbSize / 2;

        return SizedBox(
          height: widget.height,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // ── Track background
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.trackColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(widget.height / 2),
                    border: Border.all(
                      color: widget.trackColor.withValues(alpha: 0.35),
                    ),
                  ),
                ),
              ),

              // ── Filled portion (follows thumb)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: fillWidth.clamp(0.0, trackWidth),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.trackColor
                        .withValues(alpha: (_dragProgress * 0.55).clamp(0.0, 0.55)),
                    borderRadius: BorderRadius.circular(widget.height / 2),
                  ),
                ),
              ),

              // ── Center label — fades out as thumb advances
              if (!_isCompleted)
                Center(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: (1.0 - _dragProgress * 2.0).clamp(0.0, 1.0),
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          color: widget.trackColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),

              // ── "Confirming..." state
              if (_isCompleted)
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: widget.trackColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.confirmingLabel,
                        style: TextStyle(
                          color: widget.trackColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Draggable thumb
              Positioned(
                left: thumbLeft,
                top: _padding,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: (d) => _onDragUpdate(d, maxOffset),
                  onHorizontalDragEnd: _onDragEnd,
                  child: _Thumb(
                    size: _thumbSize,
                    color: widget.trackColor,
                    isCompleted: _isCompleted,
                    progress: _dragProgress,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Private thumb widget ────────────────────────────────────────────────────

class _Thumb extends StatelessWidget {
  final double size;
  final Color color;
  final bool isCompleted;
  final double progress;

  const _Thumb({
    required this.size,
    required this.color,
    required this.isCompleted,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isCompleted ? color : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        isCompleted ? Icons.check_rounded : AppIcons.chevron,
        color: isCompleted ? Colors.white : color,
        size: 24,
      ),
    );
  }
}
