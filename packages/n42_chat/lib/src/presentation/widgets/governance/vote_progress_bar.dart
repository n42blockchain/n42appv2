import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// A reusable progress bar widget for displaying vote results.
///
/// Shows the choice name, vote count with percentage, and an animated
/// progress bar. The winning choice is highlighted with the accent color.
class VoteProgressBar extends StatelessWidget {
  /// The name of the voting choice
  final String choiceName;

  /// Number of votes (or voting power) for this choice
  final double voteCount;

  /// Total votes across all choices (used to calculate percentage)
  final double totalVotes;

  /// Whether this choice is the current winner
  final bool isWinner;

  /// Whether this choice is selected by the current user
  final bool isSelected;

  /// Animation duration for the progress bar width transition
  final Duration animationDuration;

  const VoteProgressBar({
    super.key,
    required this.choiceName,
    required this.voteCount,
    required this.totalVotes,
    this.isWinner = false,
    this.isSelected = false,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  double get _percentage => totalVotes > 0 ? voteCount / totalVotes : 0;

  String get _percentageText =>
      '${(_percentage * 100).toStringAsFixed(1)}%';

  String get _voteCountText => voteCount >= 1000
      ? '${(voteCount / 1000).toStringAsFixed(1)}k'
      : voteCount.toStringAsFixed(voteCount == voteCount.roundToDouble() ? 0 : 1);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final barColor = isWinner
        ? AppColors.primary
        : isSelected
            ? AppColors.info
            : (isDark ? const Color(0xFF3D3D3D) : const Color(0xFFE0E0E0));

    final textColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final secondaryTextColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final trackColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Choice name and percentage row
          Row(
            children: [
              if (isSelected)
                const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              Expanded(
                child: Text(
                  choiceName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isWinner ? FontWeight.w600 : FontWeight.w400,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$_voteCountText votes',
                style: TextStyle(
                  fontSize: 12,
                  color: secondaryTextColor,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 48,
                child: Text(
                  _percentageText,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isWinner ? AppColors.primary : textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Stack(
                children: [
                  // Track
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: trackColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  // Progress fill
                  AnimatedFractionallySizedBox(
                    duration: animationDuration,
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.centerLeft,
                    widthFactor: _percentage.clamp(0, 1),
                    child: Container(
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A [FractionallySizedBox] that animates its [widthFactor] changes.
class AnimatedFractionallySizedBox extends ImplicitlyAnimatedWidget {
  final AlignmentGeometry alignment;
  final double? widthFactor;
  final double? heightFactor;
  final Widget? child;

  const AnimatedFractionallySizedBox({
    super.key,
    required super.duration,
    super.curve,
    this.alignment = Alignment.center,
    this.widthFactor,
    this.heightFactor,
    this.child,
  });

  @override
  AnimatedFractionallySizedBoxState createState() =>
      AnimatedFractionallySizedBoxState();
}

class AnimatedFractionallySizedBoxState
    extends AnimatedWidgetBaseState<AnimatedFractionallySizedBox> {
  Tween<double>? _widthFactor;
  Tween<double>? _heightFactor;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _widthFactor = visitor(
      _widthFactor,
      widget.widthFactor ?? 0,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;

    _heightFactor = visitor(
      _heightFactor,
      widget.heightFactor ?? 1,
      (dynamic value) => Tween<double>(begin: value as double),
    ) as Tween<double>?;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: widget.alignment,
      widthFactor: _widthFactor?.evaluate(animation),
      heightFactor: _heightFactor?.evaluate(animation),
      child: widget.child,
    );
  }
}
