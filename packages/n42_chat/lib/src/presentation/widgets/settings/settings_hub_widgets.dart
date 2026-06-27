import 'package:flutter/material.dart';

import '../../../core/extensions/context_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../common/common_widgets.dart';

class SettingsHubOverviewCard extends StatelessWidget {
  final String? avatarUrl;
  final String? avatarName;
  final String title;
  final String subtitle;
  final List<String> chips;

  const SettingsHubOverviewCard({
    super.key,
    this.avatarUrl,
    this.avatarName,
    required this.title,
    required this.subtitle,
    this.chips = const [],
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final cardColor = context.surfaceColor;
    final titleColor = AppColors.textPrimaryOf(isDark);
    final subtitleColor = context.textSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          N42Avatar(imageUrl: avatarUrl, name: avatarName ?? title, size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: subtitleColor),
                ),
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: chips
                        .map((chip) => SettingsHubChip(label: chip))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsHubSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsHubSection({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.textSecondary,
              ),
            ),
          ),
          ...List.generate(children.length * 2 - 1, (index) {
            if (index.isOdd) {
              return Padding(
                padding: const EdgeInsets.only(left: 60),
                child: Divider(
                  height: 1,
                  color: context.dividerColor,
                ),
              );
            }
            return children[index ~/ 2];
          }),
        ],
      ),
    );
  }
}

class SettingsHubActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const SettingsHubActionTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Opacity(
                  opacity: onTap == null ? 0.55 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textPrimaryOf(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: context.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsHubChip extends StatelessWidget {
  final String label;

  const SettingsHubChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimaryOf(isDark),
        ),
      ),
    );
  }
}
