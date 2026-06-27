import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/social/social_recommendation.dart';

/// Simple force-directed-style graph visualization widget.
///
/// Renders the current user as a central node surrounded by recommended
/// connections. Lines between nodes have thickness proportional to the
/// similarity score. Tap a node to select it.
class SocialGraphVisualization extends StatefulWidget {
  /// The current user's display name (ENS or short address).
  final String centerLabel;

  /// Recommended connections to display around the center.
  final List<SocialRecommendation> recommendations;

  /// Called when a recommendation node is tapped (index into [recommendations]).
  final ValueChanged<int>? onNodeTapped;

  /// Currently selected node index, or -1 / null for none.
  final int? selectedIndex;

  const SocialGraphVisualization({
    super.key,
    required this.centerLabel,
    this.recommendations = const [],
    this.onNodeTapped,
    this.selectedIndex,
  });

  @override
  State<SocialGraphVisualization> createState() =>
      _SocialGraphVisualizationState();
}

class _SocialGraphVisualizationState extends State<SocialGraphVisualization>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            return GestureDetector(
              onTapDown: (details) =>
                  _handleTap(details.localPosition, size),
              child: CustomPaint(
                size: size,
                painter: _GraphPainter(
                  centerLabel: widget.centerLabel,
                  recommendations: widget.recommendations,
                  selectedIndex: widget.selectedIndex ?? -1,
                  isDark: isDark,
                  animationValue: _scaleAnim.value,
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _handleTap(Offset position, Size size) {
    if (widget.onNodeTapped == null) return;
    if (widget.recommendations.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.35;
    final count = widget.recommendations.length;
    const nodeRadius = 22.0;

    for (var i = 0; i < count; i++) {
      final angle = (2 * pi * i / count) - pi / 2;
      final nodeCenter = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if ((position - nodeCenter).distance <= nodeRadius + 8) {
        widget.onNodeTapped!(i);
        return;
      }
    }
  }
}

class _GraphPainter extends CustomPainter {
  final String centerLabel;
  final List<SocialRecommendation> recommendations;
  final int selectedIndex;
  final bool isDark;
  final double animationValue;

  _GraphPainter({
    required this.centerLabel,
    required this.recommendations,
    required this.selectedIndex,
    required this.isDark,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.35 * animationValue;
    final count = recommendations.length;

    // Draw edges first (behind nodes)
    for (var i = 0; i < count; i++) {
      final angle = (2 * pi * i / count) - pi / 2;
      final nodeCenter = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      final score = recommendations[i].similarityScore;

      final linePaint = Paint()
        ..color = (isDark ? Colors.white24 : Colors.black12)
        ..strokeWidth = 1.0 + score * 3.0
        ..style = PaintingStyle.stroke;

      if (i == selectedIndex) {
        linePaint.color = AppColors.primary.withValues(alpha: 0.5);
        linePaint.strokeWidth += 1;
      }

      canvas.drawLine(center, nodeCenter, linePaint);
    }

    // Draw outer nodes
    for (var i = 0; i < count; i++) {
      final angle = (2 * pi * i / count) - pi / 2;
      final nodeCenter = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      _drawNode(
        canvas,
        nodeCenter,
        label: recommendations[i].profile.displayName,
        isSelected: i == selectedIndex,
        score: recommendations[i].similarityScore,
        address: recommendations[i].profile.address,
        nodeRadius: 22,
      );
    }

    // Draw center node on top
    _drawCenterNode(canvas, center);
  }

  void _drawCenterNode(Canvas canvas, Offset center) {
    const nodeRadius = 28.0;

    // Glow
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, nodeRadius + 6, glowPaint);

    // Circle
    final circlePaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(center, nodeRadius, circlePaint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, nodeRadius, borderPaint);

    // Label
    _drawText(
      canvas,
      center,
      _truncateLabel(centerLabel, 6),
      Colors.white,
      11,
      FontWeight.w600,
    );
  }

  void _drawNode(
    Canvas canvas,
    Offset center, {
    required String label,
    required bool isSelected,
    required double score,
    required String address,
    required double nodeRadius,
  }) {
    final color = _addressColor(address);

    // Selection highlight
    if (isSelected) {
      final highlightPaint = Paint()
        ..color = AppColors.primary.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawCircle(center, nodeRadius + 4, highlightPaint);
    }

    // Circle fill
    final fillPaint = Paint()
      ..color = isSelected ? AppColors.primary : color.withValues(alpha: 0.15);
    canvas.drawCircle(center, nodeRadius, fillPaint);

    // Border
    final borderPaint = Paint()
      ..color = isSelected ? AppColors.primary : color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.5 : 1.5;
    canvas.drawCircle(center, nodeRadius, borderPaint);

    // Label
    final textColor = isSelected
        ? Colors.white
        : AppColors.textPrimaryOf(isDark);
    _drawText(
      canvas,
      center,
      _truncateLabel(label, 5),
      textColor,
      10,
      FontWeight.w500,
    );
  }

  void _drawText(
    Canvas canvas,
    Offset center,
    String text,
    Color color,
    double fontSize,
    FontWeight weight,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  String _truncateLabel(String label, int maxLen) {
    if (label.length <= maxLen) return label;
    return '${label.substring(0, maxLen)}..';
  }

  Color _addressColor(String address) {
    if (address.length < 6) return AppColors.primary;
    final hash = address.codeUnits.fold<int>(0, (sum, c) => sum + c);
    return AppColorPalettes.avatarColors[
        hash % AppColorPalettes.avatarColors.length];
  }

  @override
  bool shouldRepaint(covariant _GraphPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.recommendations.length != recommendations.length;
  }
}
