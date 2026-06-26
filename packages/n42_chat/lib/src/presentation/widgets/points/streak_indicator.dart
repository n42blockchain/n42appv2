import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';

/// Streak indicator widget showing consecutive active days.
///
/// Features:
/// - Flame icon with pulse animation for active streaks
/// - 7-day calendar strip showing active/inactive days
/// - Streak multiplier display (2x bonus after 7+ days)
class StreakIndicator extends StatefulWidget {
  /// Number of consecutive active days.
  final int streakDays;

  /// Whether the user has been active today.
  final bool isActiveToday;

  /// Optional set of active weekdays (0 = Monday, 6 = Sunday) for
  /// the 7-day strip. If null, the strip infers from [streakDays].
  final Set<int>? activeDays;

  const StreakIndicator({
    super.key,
    required this.streakDays,
    this.isActiveToday = false,
    this.activeDays,
  });

  @override
  State<StreakIndicator> createState() => _StreakIndicatorState();
}

class _StreakIndicatorState extends State<StreakIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.streakDays > 0 && widget.isActiveToday) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StreakIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streakDays > 0 && widget.isActiveToday) {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        children: [
          // Header row: flame icon + streak count + multiplier
          Row(
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Icon(
                  Icons.local_fire_department_rounded,
                  size: 28,
                  color: widget.streakDays > 0
                      ? const Color(0xFFFF6B35)
                      : context.textTertiary,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.streakDays} Day Streak',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    widget.isActiveToday
                        ? 'Keep it going!'
                        : 'Be active today to continue',
                    style: TextStyle(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (_multiplier > 1)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_multiplier}x',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // 7-day calendar strip
          _buildCalendarStrip(isDark),
        ],
      ),
    );
  }

  /// Multiplier based on streak length.
  int get _multiplier {
    if (widget.streakDays >= 30) return 5;
    if (widget.streakDays >= 14) return 3;
    if (widget.streakDays >= 7) return 2;
    return 1;
  }

  Widget _buildCalendarStrip(bool isDark) {
    final now = DateTime.now();
    // Show the last 7 days (today at the right end)
    final days = List.generate(7, (i) {
      return now.subtract(Duration(days: 6 - i));
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: days.map((day) {
        final isActive = _isDayActive(day);
        final isToday = day.day == now.day &&
            day.month == now.month &&
            day.year == now.year;

        return _DayDot(
          label: _weekdayLabel(day.weekday),
          isActive: isActive,
          isToday: isToday,
          isDark: isDark,
        );
      }).toList(),
    );
  }

  bool _isDayActive(DateTime day) {
    if (widget.activeDays != null) {
      // weekday: 1=Mon -> 0, 7=Sun -> 6
      return widget.activeDays!.contains(day.weekday - 1);
    }
    // Infer from streak: the last N days (including today if active) are active.
    final now = DateTime.now();
    final daysDiff = DateTime(now.year, now.month, now.day)
        .difference(DateTime(day.year, day.month, day.day))
        .inDays;

    final effectiveStreak =
        widget.isActiveToday ? widget.streakDays : (widget.streakDays > 0 ? widget.streakDays - 1 : 0);
    if (widget.isActiveToday) {
      return daysDiff < effectiveStreak;
    } else {
      // If not active today, the streak ended yesterday
      return daysDiff >= 1 && daysDiff <= effectiveStreak;
    }
  }

  String _weekdayLabel(int weekday) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[weekday - 1];
  }
}

// =============================================================================
// Private widgets
// =============================================================================

class _DayDot extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isToday;
  final bool isDark;

  const _DayDot({
    required this.label,
    required this.isActive,
    required this.isToday,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
            color: isToday
                ? AppColors.primary
                : context.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? const Color(0xFFFF6B35)
                : (isDark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF0F0F0)),
            border: isToday
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          child: Center(
            child: isActive
                ? const Icon(
                    Icons.local_fire_department_rounded,
                    size: 14,
                    color: Colors.white,
                  )
                : Icon(
                    Icons.circle_outlined,
                    size: 14,
                    color: context.textTertiary,
                  ),
          ),
        ),
      ],
    );
  }
}
